import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/appwrite_service.dart';
import '../data/services/firebase_service.dart';
import '../data/services/ai_service.dart';

final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  return AppwriteService();
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});
