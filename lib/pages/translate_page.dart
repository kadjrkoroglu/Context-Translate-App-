import 'package:flutter/material.dart';
import 'package:translate_app/components/dropdown.dart';
import 'package:translate_app/gemini_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  Future<void> _handleTranslate() async {
    setState(() => _isLoading = true);
    try {
      final response = await _geminiService.translateText(
        _textController.text,
        _selectedLanguage,
      );
      setState(() {
        _outputController.text = response.join('\n\n');
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = e.toString();

      if (errorMessage.contains('429')) {
        errorMessage =
            'Çok hızlı gittiniz! Lütfen 1 dakika bekleyip tekrar deneyin (Kota Sınırı).';
      } else {
        errorMessage = 'Bir hata oluştu: $e';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color.fromARGB(255, 201, 64, 64),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  final GeminiService _geminiService = GeminiService();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _selectedLanguage = 'İngilizce';
  bool _isLoading = false;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => setState(() {}),
      onError: (errorNotification) => setState(() {}),
    );
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            'Context Translate',
            style: GoogleFonts.caveat(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  Stack(
                    children: [
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(24),
                            ),
                          ),
                          hintText: 'Enter text to translate',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical:
                                20, // Alt ve üst eşitlendi, boyut sabit kaldı
                          ),
                        ),
                        maxLines: 7,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          onPressed: () => _textController.clear(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 55,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: !_speechEnabled || _isLoading
                                ? null
                                : () {
                                    if (_speechToText.isListening) {
                                      _stopListening();
                                    } else {
                                      _startListening();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Icon(
                              _speechToText.isListening
                                  ? Icons.stop
                                  : Icons.mic_none,
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              size: 26,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 2,
                          child: Stack(
                            children: [
                              LanguageDropdown(
                                value: _selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                  });
                                },
                              ),
                              if (_speechToText.isListening)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.mic,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.inversePrimary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Dinleniyor...',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.inversePrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleTranslate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              padding: EdgeInsets.zero,
                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.translate,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                    size: 26,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _outputController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.primary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                      ),
                      hintText: 'Translation will appear here',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    maxLines: 7,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
