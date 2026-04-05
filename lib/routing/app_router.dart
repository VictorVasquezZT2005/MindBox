import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/dashboard_screen.dart';
import '../ui/screens/notes_screen.dart';
import '../ui/screens/reminders_screen.dart';
import '../ui/screens/passwords_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/new_note_screen.dart';
import '../ui/screens/add_password_screen.dart';
import '../ui/screens/add_reminder_screen.dart';
import '../ui/screens/certificates_screen.dart';
import '../ui/screens/add_certificate_screen.dart';
import '../ui/screens/stats_screen.dart';
import '../ui/screens/document_scanner_screen.dart';
import '../ui/screens/resume_screen.dart';
import '../ui/screens/note_detail_screen.dart';
import '../ui/screens/reminder_detail_screen.dart';
import '../ui/screens/edit_reminder_screen.dart';
import '../ui/screens/certificate_detail_screen.dart';
import '../ui/screens/edit_certificate_screen.dart';
import '../ui/screens/forgot_password_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: Listenable.merge([
      // Add a notifier if you want to refresh on auth changes automatically
    ]),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingInOrRecovering = state.matchedLocation == '/login' || 
                                     state.matchedLocation == '/register' ||
                                     state.matchedLocation == '/forgot_password';

      if (!isLoggedIn && !isLoggingInOrRecovering) return '/login';
      if (isLoggedIn && isLoggingInOrRecovering) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot_password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
      GoRoute(path: '/note_detail/:id', builder: (context, state) => NoteDetailScreen(noteId: state.pathParameters['id']!)),
      GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
      GoRoute(path: '/reminder_detail/:id', builder: (context, state) => ReminderDetailScreen(reminderId: state.pathParameters['id']!)),
      GoRoute(path: '/edit_reminder/:id', builder: (context, state) => EditReminderScreen(reminderId: state.pathParameters['id']!)),
      GoRoute(path: '/passwords', builder: (context, state) => const PasswordsScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/new_note', builder: (context, state) => const NewNoteScreen()),
      GoRoute(path: '/add_password', builder: (context, state) => const AddPasswordScreen()),
      GoRoute(path: '/add_reminder', builder: (context, state) => const AddReminderScreen()),
      GoRoute(path: '/certificates', builder: (context, state) => const CertificatesScreen()),
      GoRoute(path: '/certificate_detail/:id', builder: (context, state) => CertificateDetailScreen(certificateId: state.pathParameters['id']!)),
      GoRoute(path: '/edit_certificate/:id', builder: (context, state) => EditCertificateScreen(certificateId: state.pathParameters['id']!)),
      GoRoute(path: '/add_certificate', builder: (context, state) => const AddCertificateScreen()),
      GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
      GoRoute(path: '/document_scanner', builder: (context, state) => const DocumentScannerScreen()),
      GoRoute(path: '/resume', builder: (context, state) => const ResumeScreen()),
    ],
  );
});
