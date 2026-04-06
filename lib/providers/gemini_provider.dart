import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class GeminiKeyNotifier extends Notifier<String> {
  static const _key = 'gemini_api_key';

  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key) ?? '';
  }

  Future<void> setKey(String newKey) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, newKey);
    state = newKey;
  }
  
  void resetToDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_key);
    state = '';
  }
}

final geminiKeyProvider = NotifierProvider<GeminiKeyNotifier, String>(() {
  return GeminiKeyNotifier();
});
