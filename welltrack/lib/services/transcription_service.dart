import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class TranscriptionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  Function(String)? _onResult;
  Function(String)? _onError;
  
  Future<bool> initialize() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          _onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
      );
      return _speechEnabled;
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      return false;
    }
  }
  
  bool get isAvailable => _speechEnabled;
  bool get isListening => _speechToText.isListening;
  String get lastWords => _lastWords;
  
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
    String? localeId,
  }) async {
    if (!_speechEnabled) {
      onError?.call('Speech recognition not available');
      return;
    }
    
    _onResult = onResult;
    _onError = onError;
    _lastWords = '';
    
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: localeId,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: ListenMode.dictation,
    );
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  Future<void> cancelListening() async {
    await _speechToText.cancel();
    _lastWords = '';
  }
  
  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    _onResult?.call(_lastWords);
    
    if (result.finalResult) {
      debugPrint('Final transcription: $_lastWords');
    }
  }
  
  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_speechEnabled) {
      return [];
    }
    
    try {
      final locales = await _speechToText.locales();
      return locales;
    } catch (e) {
      debugPrint('Error getting locales: $e');
      return [];
    }
  }
  
  void dispose() {
    _speechToText.cancel();
  }
}