import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import '../theme/colors.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final certs = ref.watch(certificatesProvider);
    final passwords = ref.watch(passwordsProvider);
    final reminders = ref.watch(remindersProvider);

    final noteCount = notes.value?.length ?? 0;
    final certCount = certs.value?.length ?? 0;
    final passCount = passwords.value?.length ?? 0;
    final reminderCount = reminders.value?.length ?? 0;
    final totalItems = noteCount + certCount + passCount + reminderCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MI RED'),
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
                _buildHubIcon(context),
                const SizedBox(height: 32),
                Text(
                  'MI RED DIGITAL',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, 
                    fontSize: 24, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TU ACTIVIDAD Y CONEXIONES DIGITALES',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = ResponsiveUtils.isDesktop(context);
                    final bool isTablet = ResponsiveUtils.isTablet(context);
                    
                    if (isDesktop || isTablet) {
                      return GridView.count(
                        crossAxisCount: isDesktop ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
                        children: [
                          _buildStatsCard(context, 'NOTAS', noteCount.toString(), Icons.description_outlined, BrandOrange),
                          _buildStatsCard(context, 'LOGROS', certCount.toString(), Icons.school_outlined, BrandGreen),
                          _buildStatsCard(context, 'LLAVES', passCount.toString(), Icons.vpn_key_outlined, NetworkBlue),
                          _buildStatsCard(context, 'ALERTAS', reminderCount.toString(), Icons.notifications_active_outlined, BrandRust),
                        ],
                      );
                    }
                    
                    return Column(
                      children: [
                        _buildStatsCard(context, 'NOTAS GUARDADAS', noteCount.toString(), Icons.description_outlined, BrandOrange),
                        const SizedBox(height: 12),
                        _buildStatsCard(context, 'CURSOS Y LOGROS', certCount.toString(), Icons.school_outlined, BrandGreen),
                        const SizedBox(height: 12),
                        _buildStatsCard(context, 'LLAVES DE ACCESO', passCount.toString(), Icons.vpn_key_outlined, NetworkBlue),
                        const SizedBox(height: 12),
                        _buildStatsCard(context, 'RECORDATORIOS', reminderCount.toString(), Icons.notifications_active_outlined, BrandRust),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                _buildSummaryCard(context, totalItems),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHubIcon(BuildContext context) {
    final color = NetworkBlue;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Icon(Icons.hub_outlined, color: color, size: 40),
    );
  }

  Widget _buildStatsCard(BuildContext context, String label, String value, IconData icon, Color color) {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(), 
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
                      fontSize: 20, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
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

  Widget _buildSummaryCard(BuildContext context, int total) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, color: color, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'TIENES $total ELEMENTOS SINCRONIZADOS. TU MINDBOX ESTÁ CRECIENDO.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), 
                fontSize: 11, 
                height: 1.5, 
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
