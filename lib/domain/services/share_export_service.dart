import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareExportService {
  Future<File> savePngBytes({
    required Uint8List pngBytes,
    required String fileName,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pngBytes, flush: true);
    return file;
  }

  Future<void> shareImageFile({
    required File file,
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        files: [XFile(file.path)],
      ),
    );
  }

  Future<Uint8List?> captureBoundaryToPng(
      RenderRepaintBoundary boundary, {
        double pixelRatio = 3.0,
      }) async {
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}