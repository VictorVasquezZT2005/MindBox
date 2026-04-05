import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/service_providers.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;

  Future<void> _handleReset() async {
    if (_emailController.text.isEmpty) return;
    try {
      await ref.read(firebaseServiceProvider).sendPasswordResetEmail(_emailController.text);
      setState(() => _isSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().toUpperCase())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECUPERAR CUENTA'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: Center(
        child: ResponsiveContainer(
          maxWidth: 450,
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'MINDBOX', 
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSent 
                    ? 'REVISA TU CORREO ELECTRÓNICO.' 
                    : 'INGRESA TU CORREO PARA RECUPERAR EL ACCESO.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                    fontSize: 10, 
                    letterSpacing: 1.1, 
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!_isSent) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController, 
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleReset(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleReset,
                      child: const Text('ENVIAR ENLACE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text(
                    'HEMOS ENVIADO LAS INSTRUCCIONES A TU CORREO.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
