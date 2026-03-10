class ReceiptScanResultModel {
  final bool isSuccess;
  final String recognizedText;
  final String? errorMessage;

  const ReceiptScanResultModel({
    required this.isSuccess,
    required this.recognizedText,
    this.errorMessage,
  });

  bool get hasText => recognizedText.trim().isNotEmpty;
}