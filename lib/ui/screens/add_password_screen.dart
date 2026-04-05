import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/models/password.dart';
import '../../data/services/otp_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../theme/colors.dart';

class AddPasswordScreen extends ConsumerStatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  ConsumerState<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends ConsumerState<AddPasswordScreen> {
  final _serviceController = TextEditingController();
  final _emailController = TextEditingController();
  final _secretController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Acceso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escanea el código QR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final data = barcode.rawValue;
                      if (data != null) {
                        final parsed = OtpHelper.parseQrCode(data);
                        if (parsed != null) {
                          setState(() {
                            _serviceController.text = parsed['service'] ?? '';
                            _emailController.text = parsed['email'] ?? '';
                            _secretController.text = parsed['secret'] ?? '';
                          });
                        }
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Configuración manual',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio',
                prefixIcon: Icon(Icons.apps),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo o Usuario',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _secretController,
              decoration: const InputDecoration(
                labelText: 'Clave Secreta (Key)',
                prefixIcon: Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePassword,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('GUARDAR ACCESO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _savePassword() async {
    if (_serviceController.text.isEmpty || _secretController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final password = Password(
        serviceName: _serviceController.text,
        accountEmail: _emailController.text,
        secretKey: _secretController.text,
      );
      await ref.read(firebaseServiceProvider).addPassword(user.uid, password);
      if (mounted) context.pop();
    }
    setState(() => _isLoading = false);
  }
}
