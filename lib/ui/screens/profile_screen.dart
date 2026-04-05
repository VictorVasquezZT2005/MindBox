import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1A237E),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Usuario',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Preferencias de Tema', style: TextStyle(fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.palette_outlined),
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: const Text('Automático (Sistema)'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Modo Claro'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Modo Oscuro'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(firebaseServiceProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
