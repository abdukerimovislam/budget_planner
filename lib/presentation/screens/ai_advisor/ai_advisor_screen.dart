import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final insights = provider.insightsForMonth(DateTime.now());

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
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Приветствие от ИИ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.sparkles, color: theme.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
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

                  // 2. Список карточек (смещенный вправо, как сообщения в чате)
                  if (insights.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Text(
                        "Пока у меня нет новых наблюдений. Добавьте больше транзакций!",
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    )
                  else
                    ...insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 52),
                      child: InsightCard(insight: insight), // Наш красивый InsightCard!
                    )),
                ],
              ),
            ),

            // 3. Поле ввода (Имитация чата Siri / ChatGPT)
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
                    color: theme.colorScheme.surface.withOpacity(0.6),
                    border: Border(top: BorderSide(color: theme.colorScheme.surfaceVariant.withOpacity(0.5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.chat_bubble_text, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: l10n.aiChatHint,
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 15),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                        ),
                        child: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 24),
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
}