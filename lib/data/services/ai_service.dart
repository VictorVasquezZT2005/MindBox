import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final String _apiKey = 'AIzaSyA8Vjj8vsCvKtDDSORS4MYvrHXJeUiCe2M';
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
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
      final prompt = 'Resume el siguiente texto manteniendo los puntos clave. Devuelve solo el resumen en formato Markdown:\n\n$text';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'La IA no pudo generar un resumen.';
    } catch (e) {
      return 'Error al resumir: $e';
    }
  }

  Future<String> fixGrammar(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      final prompt = 'Corrige la gramática y ortografía del siguiente texto, mejorando la redacción sin cambiar el significado original. Devuelve solo el texto corregido en Markdown:\n\n$text';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? text;
    } catch (e) {
      return 'Error al corregir: $e';
    }
  }

  Future<String> continueWriting(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      final prompt = 'Actúa como un asistente de escritura. Continúa desarrollando la idea del siguiente texto de forma natural y coherente. Devuelve solo la continuación en Markdown:\n\n$text';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'La IA no pudo continuar el texto.';
    } catch (e) {
      return 'Error al continuar: $e';
    }
  }

  Future<String> customPrompt(String text, String userPrompt) async {
    if (text.trim().isEmpty || userPrompt.trim().isEmpty) return '';
    try {
      final prompt = 'Instrucción: $userPrompt\n\nTexto base sobre el cual aplicar la instrucción:\n\n$text\n\nRespuesta en Markdown:';
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'La IA no devolvió resultados para esta instrucción.';
    } catch (e) {
      return 'Error de instrucción personalizada: $e';
    }
  }
}
