class VoiceInputResult {
  final bool isAvailable;
  final bool permissionGranted;
  final String recognizedText;
  final String? errorMessage;

  const VoiceInputResult({
    required this.isAvailable,
    required this.permissionGranted,
    required this.recognizedText,
    this.errorMessage,
  });

  bool get hasText => recognizedText.trim().isNotEmpty;
}