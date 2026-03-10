class ReceiptCandidateAmountModel {
  final double value;
  final String sourceLine;
  final double confidence;

  const ReceiptCandidateAmountModel({
    required this.value,
    required this.sourceLine,
    required this.confidence,
  });
}