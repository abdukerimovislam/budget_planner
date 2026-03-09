import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/responsive.dart';
import '../../../domain/services/share_card_model.dart';
import '../../../domain/services/share_export_service.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../widgets/adaptive_page_padding.dart';
import '../widgets/monthly_share_card_widget.dart';

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

    setState(() {
      _isExporting = true;
    });

    try {
      final renderObject =
      _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (renderObject == null) {
        throw Exception(l10n.shareCardRenderError);
      }

      final Uint8List? pngBytes =
      await _shareExportService.captureBoundaryToPng(renderObject);

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.shareCardExportError(e.toString()),
          ),
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
    final now = DateTime.now();

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareCardScreenTitle),
      ),
      body: AdaptivePagePadding(
        addBottomSafeArea: false,
        child: ListView(
          children: [
            RepaintBoundary(
              key: _cardKey,
              child: MonthlyShareCardWidget(data: shareData),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.shareCardHintTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.shareCardHintSubtitleReady,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.sectionGap(context)),
            FilledButton.icon(
              onPressed: _isExporting
                  ? null
                  : () => _exportAndShare(context, shareData),
              icon: _isExporting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.ios_share_rounded),
              label: Text(
                _isExporting
                    ? l10n.shareCardPreparingButton
                    : l10n.shareCardShareButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}