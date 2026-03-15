import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../data/datasources/local/local_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/premium_background.dart';

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  GenerativeModel? _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAI();
    // Прокручиваем к концу при открытии, если уже есть история
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _initAI() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
          ),
        );
      } else {
        debugPrint('AI Copilot Init Error: GEMINI_API_KEY is missing');
      }
    } catch (e) {
      debugPrint('AI Copilot Init Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<HomeProvider>();

    // Сохраняем сообщение пользователя в провайдер (чтобы не потерять при выходе с экрана)
    provider.addAiChatMessage(true, text);

    setState(() {
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    if (!LocalStorageService.instance.canUseAiAdvisor()) {
      provider.addAiChatMessage(false, "Извините, но дневной лимит советов исчерпан. Мне нужно отдохнуть, возвращайтесь завтра!");
      setState(() => _isLoading = false);
      _scrollToBottom();
      return;
    }

    if (_model == null) {
      provider.addAiChatMessage(false, "Связь с ИИ не установлена. Проверьте ваш API ключ.");
      setState(() => _isLoading = false);
      _scrollToBottom();
      return;
    }

    try {
      final now = DateTime.now();
      final spent = provider.totalSpentThisMonth(now);
      final budget = provider.budget?.currency == provider.activeCurrency ? (provider.budget?.totalBudget ?? 0) : 0.0;
      final currency = provider.activeCurrency;
      final topCat = provider.categoryTotalsForMonth(now).entries.isNotEmpty
          ? provider.categoryTotalsForMonth(now).entries.reduce((a, b) => a.value > b.value ? a : b).key.name
          : 'none';

      final recentExpenses = provider.expenses
          .where((e) => e.date.month == now.month && e.date.year == now.year && !e.isIncome && e.currency == currency)
          .take(30)
          .toList();

      final expensesContext = recentExpenses.isEmpty
          ? 'No transactions yet.'
          : recentExpenses.map((e) => '- ${e.date.day}/${e.date.month}: ${e.category.name}, ${e.amount} ${e.currency} (Merchant: ${e.merchant.isEmpty ? "Unknown" : e.merchant})').join('\n');

      // ИСПРАВЛЕНИЕ: Формируем историю из последних 10 сообщений
      final historyStrings = provider.aiChatHistory.take(10).map((msg) {
        return "${msg['isUser'] ? 'User' : 'Advisor'}: ${msg['text']}";
      }).join('\n');

      final systemPrompt = '''
You are a friendly, expert financial advisor integrated into a budget planner app.
User's current month context:
- Currency: $currency
- Total Spent: $spent
- Budget: ${budget > 0 ? budget : 'Not set'}
- Top spending category: $topCat

Recent transactions (up to 30 this month):
$expensesContext

Conversation History:
$historyStrings

Answer the user's latest message concisely (1-3 short paragraphs). Provide actionable, personalized advice based on their transactions and context. Use the same language the user writes in. Avoid markdown formatting like ** or * if possible, keep it plain and readable.
''';

      final response = await _model!.generateContent([Content.text(systemPrompt)]);

      if (response.text != null) {
        await LocalStorageService.instance.incrementAiAdvisorUsage();
        provider.addAiChatMessage(false, response.text!.trim());
      }
    } catch (e, stackTrace) {
      debugPrint('--- AI ERROR ---');
      debugPrint(e.toString());
      provider.addAiChatMessage(false, "К сожалению, произошла ошибка. Попробуйте сформулировать вопрос иначе.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final insights = provider.insightsForMonth(DateTime.now());
    final chatHistory = provider.aiChatHistory; // Берем из стейта

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.sparkles, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.aiCopilotTitle, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.sparkles, color: theme.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.8),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            l10n.aiGreeting,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (insights.isEmpty && chatHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Text(
                        "Пока у меня нет новых наблюдений. Спросите меня о чем-нибудь!",
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    )
                  else if (chatHistory.isEmpty)
                    ...insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 52),
                      child: InsightCard(insight: insight),
                    )),

                  if (chatHistory.isNotEmpty) ...[
                    if (insights.isNotEmpty) const SizedBox(height: 16),
                    ...chatHistory.map((msg) => _buildChatBubble(msg['isUser'], msg['text'], theme)),
                  ],

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 52),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoActivityIndicator(color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),

            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.6),
                    border: Border(top: BorderSide(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.chat_bubble_text, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _sendMessage(),
                                  decoration: InputDecoration(
                                    hintText: l10n.aiChatHint,
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 15),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _isLoading ? null : _sendMessage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              color: _isLoading ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (!_isLoading)
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                              ]
                          ),
                          child: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String text, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        left: isUser ? 40 : 52,
        right: isUser ? 0 : 40,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface.withValues(alpha: 0.8),
            border: isUser ? null : Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 15,
              fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}