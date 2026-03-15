import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/share_card_model.dart';
import '../../../domain/services/premium_feature.dart';
import '../../../domain/services/share_export_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../widgets/monthly_share_card_widget.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/premium_lock_card.dart';
import '../premium/premium_screen.dart';

class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({super.key});

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final ShareExportService _shareExportService = ShareExportService();

  bool _isExporting = false;

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context);
    final totalMinutes = duration.inMinutes;

    if (totalMinutes <= 0) {
      return l10n.durationMinutesOnly(0);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) return l10n.durationMinutesOnly(minutes);
    if (minutes == 0) return l10n.durationHoursOnly(hours);

    return l10n.durationHoursMinutes(hours, minutes);
  }

  Future<void> _exportAndShare(
      BuildContext context,
      ShareCardModel shareData,
      ) async {
    final l10n = AppLocalizations.of(context);

    HapticFeedback.mediumImpact();
    setState(() {
      _isExporting = true;
    });

    try {
      final renderObject = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (renderObject == null) {
        throw Exception(l10n.shareCardRenderError);
      }

      final Uint8List? pngBytes = await _shareExportService.captureBoundaryToPng(renderObject);

      if (pngBytes == null || pngBytes.isEmpty) {
        throw Exception(l10n.shareCardRenderError);
      }

      final File file = await _shareExportService.savePngBytes(
        pngBytes: pngBytes,
        fileName: 'budget_monthly_card.png',
      );

      await _shareExportService.shareImageFile(
        file: file,
        text: l10n.shareCardShareText,
        subject: l10n.shareCardScreenTitle,
      );

      HapticFeedback.lightImpact();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shareCardExportError(e.toString())),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    if (!provider.canUseFeature(PremiumFeature.shareExport)) {
      return PremiumBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(l10n.shareCardScreenTitle, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: PremiumLockCard(
              title: l10n.premiumLockedShareTitle,
              subtitle: l10n.premiumLockedShareSubtitle,
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PremiumScreen()));
              },
            ),
          ),
        ),
      );
    }

    final report = provider.monthlyReport(now);

    final shareData = ShareCardModel(
      income: report.totalIncome,
      spent: report.totalSpent,
      saved: report.totalSaved,
      healthScore: report.healthScore,
      level: report.level,
      topCategory: report.topCategory,
      lifeSpentText: _formatDuration(context, report.lifeSpent),
    );

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.back, color: CupertinoColors.activeBlue),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(l10n.shareCardScreenTitle, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          centerTitle: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Text(
                'Предпросмотр карточки',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Эффект парящей карточки (тень находится ЗА RepaintBoundary)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -10,
                  ),
                ],
              ),
              // Режется все по краям (чтобы на скриншоте не было белых ушей)
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: MonthlyShareCardWidget(data: shareData),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Стеклянная подсказка
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.sparkles, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.shareCardHintTitle,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.shareCardHintSubtitleReady,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Большая премиум-кнопка экспорта
            GestureDetector(
              onTap: _isExporting ? null : () => _exportAndShare(context, shareData),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _isExporting
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isExporting ? [] : [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Center(
                  child: _isExporting
                      ? const CupertinoActivityIndicator(radius: 12, color: Colors.white)
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.share, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.shareCardShareButton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}