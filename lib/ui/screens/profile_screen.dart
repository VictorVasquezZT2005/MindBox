import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/gemini_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _geminiKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    final user = ref.read(currentUserProvider);
    final currentGeminiKey = ref.read(geminiKeyProvider);
    if (!_isEditing) {
      _nameController.text = user?.displayName ?? '';
      _emailController.text = user?.email ?? '';
      _geminiKeyController.text = currentGeminiKey;
      _passwordController.clear();
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final firebaseService = ref.read(firebaseServiceProvider);
    
    try {
      if (_nameController.text.trim().isNotEmpty) {
        await firebaseService.updateDisplayName(_nameController.text.trim());
      }
      
      if (_emailController.text.trim().isNotEmpty && 
          _emailController.text.trim() != ref.read(currentUserProvider)?.email) {
        await firebaseService.updateEmail(_emailController.text.trim());
      }
      
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 6) {
          throw 'La contraseña debe tener al menos 6 caracteres';
        }
        await firebaseService.updatePassword(_passwordController.text);
      }

      // Guardar Gemini API Key
      await ref.read(geminiKeyProvider.notifier).setKey(_geminiKeyController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: BrandRust,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MI PERFIL'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(user),
                const SizedBox(height: 48),
                
                if (_isEditing) 
                  _buildEditForm()
                else 
                  _buildProfileDetails(user),
                
                const SizedBox(height: 32),
                _buildThemeSelector(themeMode, themeNotifier),
                
                const SizedBox(height: 48),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: NetworkBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: NetworkBlue.withOpacity(0.1)),
          ),
          child: const Icon(Icons.account_circle_outlined, color: NetworkBlue, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          _isEditing ? 'EDITAR MI PERFIL' : 'MI CUENTA DIGITAL',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary, 
            fontSize: 24, 
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(user) {
    final geminiKey = ref.watch(geminiKeyProvider);
    final maskedKey = geminiKey.length > 8 
        ? '${geminiKey.substring(0, 4)}••••${geminiKey.substring(geminiKey.length - 4)}'
        : (geminiKey.isNotEmpty ? '••••••••' : 'SIN CONFIGURAR');

    return Column(
      children: [
        _buildInfoCard('NOMBRE COMPLETO', user?.displayName ?? 'SIN NOMBRE', Icons.person_outline, BrandOrange),
        const SizedBox(height: 12),
        _buildInfoCard('CORREO ELECTRÓNICO', user?.email ?? 'USUARIO', Icons.email_outlined, NetworkBlue),
        const SizedBox(height: 12),
        _buildInfoCard('SEGURIDAD', '••••••••••••', Icons.lock_outline, BrandRust),
        const SizedBox(height: 12),
        _buildInfoCard('GEMINI API KEY', maskedKey, Icons.api_outlined, Colors.deepPurple),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _toggleEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('EDITAR PERFIL'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'NOMBRE COMPLETO',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'CORREO ELECTRÓNICO',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'NUEVA CONTRASEÑA (OPCIONAL)',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _geminiKeyController,
          decoration: const InputDecoration(
            labelText: 'GEMINI API KEY',
            prefixIcon: Icon(Icons.api_outlined),
            helperText: 'Proporciona tu propia clave de Google AI Studio',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _toggleEdit,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BrandBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('CANCELAR'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('GUARDAR'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label, 
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    )
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value, 
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeMode themeMode, themeNotifier) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('PREFERENCIAS DE TEMA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
            leading: Icon(Icons.palette_outlined),
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: const Text('SISTEMA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (mode) => themeNotifier.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('MODO CLARO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (mode) => themeNotifier.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('MODO OSCURO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (mode) => themeNotifier.setThemeMode(mode!),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () => ref.read(firebaseServiceProvider).signOut(),
      icon: const Icon(Icons.logout_outlined, size: 18),
      label: const Text('CERRAR SESIÓN'),
      style: TextButton.styleFrom(
        foregroundColor: BrandRust,
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12),
      ),
    );
  }
}
