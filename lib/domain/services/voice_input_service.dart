import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

import 'voice_input_result.dart';

class VoiceInputService {
  VoiceInputService();

  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  String? _lastError;

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<VoiceInputResult> initialize() async {
    if (_isInitialized) {
      return VoiceInputResult(
        isAvailable: true,
        permissionGranted: true,
        recognizedText: _recognizedText,
        errorMessage: _lastError,
      );
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) {
        _lastError = error.errorMsg;
        _isListening = false;
      },
      debugLogging: false,
    );

    _isInitialized = available;

    return VoiceInputResult(
      isAvailable: available,
      permissionGranted: available,
      recognizedText: _recognizedText,
      errorMessage: available ? null : _lastError,
    );
  }

  Future<VoiceInputResult> startListening({
    String localeId = '',
    Duration listenFor = const Duration(seconds: 8),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    final init = await initialize();

    if (!init.isAvailable) {
      return VoiceInputResult(
        isAvailable: false,
        permissionGranted: false,
        recognizedText: '',
        errorMessage: _lastError ?? 'Speech recognition unavailable',
      );
    }

    _recognizedText = '';
    _lastError = null;

    // ИСПРАВЛЕНИЕ: Использование современного API (SpeechListenOptions)
    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
      },
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: localeId.isEmpty ? null : localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );

    _isListening = true;

    return VoiceInputResult(
      isAvailable: true,
      permissionGranted: true,
      recognizedText: _recognizedText,
      errorMessage: null,
    );
  }

  Future<VoiceInputResult> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }

    return VoiceInputResult(
      isAvailable: _isInitialized,
      permissionGranted: _isInitialized,
      recognizedText: _recognizedText,
      errorMessage: _lastError,
    );
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  Future<List<LocaleName>> locales() async {
    final init = await initialize();
    if (!init.isAvailable) return const [];
    return _speech.locales();
  }
}