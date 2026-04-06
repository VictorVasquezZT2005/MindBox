import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late final GenerativeModel _model;

  AIService(String apiKey) {
    print('DEBUG AI: Inicializando AIService con modelo gemini-2.5-flash');
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  Future<String> summarize(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      print('DEBUG AI: Solicitando resumen...');
      final prompt = 'Resume el siguiente texto manteniendo los puntos clave. Devuelve solo el resumen en formato Markdown:\n\n$text';
      final response = await _model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 30));
      print('DEBUG AI: Respuesta recibida correctamente');
      return response.text ?? 'La IA no pudo generar un resumen.';
    } catch (e) {
      print('DEBUG AI ERROR (Summarize): $e');
      rethrow;
    }
  }

  Future<String> fixGrammar(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      print('DEBUG AI: Solicitando corrección gramatical...');
      final prompt = 'Corrige la gramática y ortografía del siguiente texto, mejorando la redacción sin cambiar el significado original. Devuelve solo el texto corregido en Markdown:\n\n$text';
      final response = await _model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 30));
      print('DEBUG AI: Respuesta recibida correctamente');
      return response.text ?? text;
    } catch (e) {
      print('DEBUG AI ERROR (Grammar): $e');
      rethrow;
    }
  }

  Future<String> continueWriting(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      print('DEBUG AI: Solicitando continuación de texto...');
      final prompt = 'Actúa como un asistente de escritura. Continúa desarrollando la idea del siguiente texto de forma natural y coherente. Devuelve solo la continuación en Markdown:\n\n$text';
      final response = await _model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 30));
      print('DEBUG AI: Respuesta recibida correctamente');
      return response.text ?? 'La IA no pudo continuar el texto.';
    } catch (e) {
      print('DEBUG AI ERROR (Continue): $e');
      rethrow;
    }
  }

  Future<String> customPrompt(String text, String userPrompt) async {
    if (text.trim().isEmpty || userPrompt.trim().isEmpty) return '';
    try {
      print('DEBUG AI: Solicitando prompt personalizado: $userPrompt');
      final prompt = 'Instrucción: $userPrompt\n\nTexto base sobre el cual aplicar la instrucción:\n\n$text\n\nRespuesta en Markdown:';
      final response = await _model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 30));
      print('DEBUG AI: Respuesta recibida correctamente');
      return response.text ?? 'La IA no devolvió resultados para esta instrucción.';
    } catch (e) {
      print('DEBUG AI ERROR (Custom): $e');
      rethrow;
    }
  }
}
