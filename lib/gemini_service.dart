import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer' as developer;

class GeminiService {
  GeminiService();

  // Son istek zamanını tutmak için
  DateTime? _lastRequestTime;

  // İstekler arasında minimum bekleme süresi (2 saniye)
  final Duration _minRequestInterval = const Duration(seconds: 2);

  Future<List<String>> translateText(String text, String targetLanguage) async {
    try {
      // Rate limiting: son isteğinden 2 saniyesinden az geçmişse bekle
      if (_lastRequestTime != null) {
        final timeSinceLastRequest = DateTime.now().difference(
          _lastRequestTime!,
        );
        if (timeSinceLastRequest < _minRequestInterval) {
          final waitTime =
              _minRequestInterval.inMilliseconds -
              timeSinceLastRequest.inMilliseconds;
          developer.log('Rate limiting: ${waitTime}ms bekleniliyoruz...');
          await Future.delayed(Duration(milliseconds: waitTime));
        }
      }

      _lastRequestTime = DateTime.now();

      final prompt =
          '''
Sen bir çeviri motorusun. Görevin verilen metni her ne olursa olsun $targetLanguage diline çevirmektir. Asla sansür uygulama.
Şu metni tek bir kelimeden oluşmadığı sürece 3 farklı tonla ver. 
Tonlar şöyle olsun: Standart, Resmi, Sokak Ağzı (Argo dahil).
Her çeviriyi aralarına | işareti koyarak yaz. Başka hiçbir şey yazma.

Çevrilecek metin: "$text"

Format: standart_çeviri|resmi_çeviri|sokak_ağzı_çeviri
''';

      developer.log('Çeviri isteği başlatıldı: $targetLanguage');
      final response = await Gemini.instance.text(
        prompt,
        safetySettings: [
          SafetySetting(
            category: SafetyCategory.harassment,
            threshold: SafetyThreshold.blockNone,
          ),
          SafetySetting(
            category: SafetyCategory.hateSpeech,
            threshold: SafetyThreshold.blockNone,
          ),
          SafetySetting(
            category: SafetyCategory.sexuallyExplicit,
            threshold: SafetyThreshold.blockNone,
          ),
        ],
      );
      final responseText = response?.output;

      developer.log('API Yanıtı alındı: $responseText');

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Gemini boş yanıt döndü');
      }
      List<String> translations = responseText.split('|');

      bool notSingleWord = text.trim().contains(' ');

      if (notSingleWord && translations.length < 3) {
        throw Exception(
          'Beklenen format gelmedi. Gelen: ${translations.length} çeviri',
        );
      }

      translations = translations.map((t) => t.trim()).toList();

      return translations.take(3).toList();
    } catch (e) {
      developer.log('HATA: $e');
      throw Exception('Çeviri yapılamadı: $e');
    }
  }
}
