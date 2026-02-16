import 'package:flutter/material.dart';
import 'package:translate_app/data/services/gemini_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translate_app/presentation/viewmodels/history_viewmodel.dart';
import 'package:translate_app/data/services/settings_service.dart';

class GeminiTranslateViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final SpeechToText _speechToText = SpeechToText();
  final SettingsService _settingsService;
  final HistoryViewModel _historyViewModel;

  bool _isLoading = false;
  String? _error;
  late String _selectedLanguage;
  bool _speechEnabled = false;
  final TextEditingController _textController = TextEditingController();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedLanguage => _selectedLanguage;
  bool get speechEnabled => _speechEnabled;
  bool get isListening => _speechToText.isListening;
  TextEditingController get textController => _textController;
  List<String> get recentLanguages => _settingsService.recentLanguages;

  GeminiTranslateViewModel(this._settingsService, this._historyViewModel) {
    _selectedLanguage = _settingsService.geminiTargetLang;
    _initSpeech();
  }

  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    _settingsService.setGeminiTargetLang(language);
    _settingsService.addRecentLanguage(language);
    notifyListeners();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          notifyListeners();
        }
      },
      onError: (error) {
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future<void> startListening(Function(String) onResult) async {
    await _speechToText.listen(
      onResult: (result) {
        _textController.text = result.recognizedWords;
        onResult(result.recognizedWords);
      },
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    notifyListeners();
  }

  Future<void> translate(TextEditingController outputController) async {
    if (_textController.text.isEmpty || _selectedLanguage == '-') {
      if (_textController.text.isEmpty) {
        outputController.text = '';
      }
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _geminiService.translateText(
        _textController.text,
        _selectedLanguage,
      );
      outputController.text = response.map((t) => '● $t').join('\n\n');

      // Save to history with trimmed text
      if (outputController.text.isNotEmpty) {
        final trimmedWord = _textController.text.trim();
        final trimmedTranslation = outputController.text.trim();

        if (trimmedWord.isNotEmpty) {
          _historyViewModel.addHistoryItem(
            word: trimmedWord,
            translation: trimmedTranslation,
          );
        }
      }
    } catch (e) {
      _error = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleError(dynamic e) {
    String message = e.toString().toLowerCase();

    if (message.contains('503') || message.contains('service unavailable')) {
      return 'AI servers are currently overloaded. Please wait a few seconds and try again.';
    }
    if (message.contains('429') || message.contains('too many requests')) {
      return 'Too many requests! Please wait 1 minute and try again (Quota Limit).';
    }
    if (message.contains('quota') || message.contains('exhausted')) {
      return 'Daily AI limit reached. Please try again tomorrow or use Basic mode.';
    }

    return 'An error occurred: $e';
  }

  void clear(TextEditingController outputController) {
    _textController.clear();
    outputController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
