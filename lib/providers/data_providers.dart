import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/note.dart';
import '../data/models/password.dart';
import '../data/models/reminder.dart';
import '../data/models/certificate.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

final notesProvider = StreamProvider<List<Note>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).getNotes(user.uid);
});

final passwordsProvider = StreamProvider<List<Password>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).getPasswords(user.uid);
});

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).getReminders(user.uid);
});

final certificatesProvider = StreamProvider<List<Certificate>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(firebaseServiceProvider).getCertificates(user.uid);
});
