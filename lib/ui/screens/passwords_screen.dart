import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/password.dart';
import '../../data/services/otp_helper.dart';
import '../../providers/data_providers.dart';
import '../theme/colors.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class PasswordsScreen extends ConsumerStatefulWidget {
  const PasswordsScreen({super.key});

  @override
  ConsumerState<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends ConsumerState<PasswordsScreen> {
  String _searchQuery = '';
  late Timer _timer;
  int _secondsLeft = 30 - (DateTime.now().second % 30);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft = 30 - (DateTime.now().second % 30);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordsAsync = ref.watch(passwordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS ACCESOS'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context).copyWith(bottom: 0),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: 'BUSCAR SERVICIO...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: passwordsAsync.when(
                data: (passwords) {
                  final filtered = passwords
                      .where((p) => p.serviceName.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('SIN ACCESOS GUARDADOS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isDesktop = ResponsiveUtils.isDesktop(context);
                      final bool isTablet = ResponsiveUtils.isTablet(context);
                      final padding = ResponsiveUtils.getResponsivePadding(context).copyWith(top: 0);

                      if (isDesktop || isTablet) {
                        return GridView.builder(
                          padding: padding,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 3 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => OtpCard(
                            password: filtered[index],
                            secondsLeft: _secondsLeft,
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: padding,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => OtpCard(
                          password: filtered[index],
                          secondsLeft: _secondsLeft,
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
                error: (e, s) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_password'),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OtpCard extends StatelessWidget {
  final Password password;
  final int secondsLeft;

  const OtpCard({super.key, required this.password, required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final code = OtpHelper.generateTOTP(password.secretKey);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        password.serviceName.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        password.accountEmail,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: secondsLeft / 30,
                        color: secondsLeft < 5 ? Colors.red : Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        strokeWidth: 2,
                      ),
                    ),
                    Text(
                      '$secondsLeft',
                      style: TextStyle(
                        color: secondsLeft < 5 ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CÓDIGO COPIADO')),
                    );
                  },
                  child: Text(
                    '${code.substring(0, 3)} ${code.substring(3)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                  onPressed: () {
                    // Delete logic
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
