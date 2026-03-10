import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/receipt_scan_result_model.dart';

class ReceiptScanService {
  ReceiptScanService();

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

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

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}