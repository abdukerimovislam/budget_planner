import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/receipt_scan_result_model.dart';

class ReceiptScanService {
  ReceiptScanService();

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  // --- ФУНКЦИОНАЛ ДЛЯ ОБЫЧНОГО ФОТО (FALLBACK) ---

  Future<XFile?> pickFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
  }

  Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  Future<ReceiptScanResultModel> scanFile(XFile file) async {
    try {
      final inputImage = InputImage.fromFile(File(file.path));
      final recognized = await _textRecognizer.processImage(inputImage);

      return ReceiptScanResultModel(
        isSuccess: true,
        recognizedText: recognized.text,
      );
    } catch (e) {
      return ReceiptScanResultModel(
        isSuccess: false,
        recognizedText: '',
        errorMessage: e.toString(),
      );
    }
  }

  // --- НОВЫЙ ФУНКЦИОНАЛ ДЛЯ QR-КОДОВ ---

  /// Парсит строку из QR-кода кассового чека (стандарт ФНС)
  /// Пример: t=20231024T1845&s=1500.50&fn=...
  Map<String, dynamic>? parseQrData(String qrContent) {
    if (qrContent.isEmpty) return null;

    try {
      // Разбираем query параметры (s - сумма, t - время)
      final parts = qrContent.split('&');
      final data = <String, String>{};

      for (var part in parts) {
        final pair = part.split('=');
        if (pair.length == 2) {
          data[pair[0]] = pair[1];
        }
      }

      double? amount;
      DateTime? date;

      // Извлекаем сумму (параметр 's' обычно в копейках или рублях с точкой)
      if (data.containsKey('s')) {
        final sStr = data['s']!;
        // В чеках ФНС сумма обычно указывается с двумя знаками (например 1500.50)
        final parsedDouble = double.tryParse(sStr);
        if (parsedDouble != null) {
          amount = parsedDouble;
        }
      }

      // Извлекаем дату (параметр 't', формат: 20231024T1845)
      if (data.containsKey('t')) {
        final tStr = data['t']!;
        if (tStr.length >= 8) {
          final year = int.parse(tStr.substring(0, 4));
          final month = int.parse(tStr.substring(4, 6));
          final day = int.parse(tStr.substring(6, 8));

          int hour = 0;
          int minute = 0;

          // Если есть время (после 'T')
          if (tStr.contains('T') && tStr.length >= 13) {
            final tIndex = tStr.indexOf('T');
            hour = int.parse(tStr.substring(tIndex + 1, tIndex + 3));
            minute = int.parse(tStr.substring(tIndex + 3, tIndex + 5));
          }

          date = DateTime(year, month, day, hour, minute);
        }
      }

      if (amount == null) return null;

      return {
        'amount': amount,
        'date': date ?? DateTime.now(),
        'rawText': qrContent,
      };
    } catch (e) {
      // Если QR-код не от кассового чека (например ссылка на сайт),
      // возвращаем просто текст, пусть разбирается AI парсер
      return {
        'amount': null,
        'date': null,
        'rawText': qrContent,
      };
    }
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}