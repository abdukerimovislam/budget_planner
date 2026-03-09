class ReceiptCandidateAmount {
  final double value;
  final String sourceLine;
  final double confidence;

  const ReceiptCandidateAmount({
    required this.value,
    required this.sourceLine,
    required this.confidence,
  });
}