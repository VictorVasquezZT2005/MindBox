import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';
import 'notes_screen.dart';
import 'reminders_screen.dart';
import 'passwords_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const NotesScreen(),
    const RemindersScreen(),
    const PasswordsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtils.isMobile(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final now = DateTime.now();
        if (_lastPressedAt == null || 
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PRESIONA DE NUEVO PARA SALIR', 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        
        // If we reach here, it's the second press within 2 seconds
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
              unselectedIconTheme: const IconThemeData(color: Colors.grey),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('INICIO')),
                NavigationRailDestination(icon: Icon(Icons.description), label: Text('NOTAS')),
                NavigationRailDestination(icon: Icon(Icons.notifications), label: Text('ALERTAS')),
                NavigationRailDestination(icon: Icon(Icons.vpn_key), label: Text('LLAVES')),
                NavigationRailDestination(icon: Icon(Icons.account_circle), label: Text('PERFIL')),
              ],
            ),
          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'INICIO'),
                BottomNavigationBarItem(icon: Icon(Icons.description), label: 'NOTAS'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'ALERTAS'),
                BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'LLAVES'),
                BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'PERFIL'),
              ],
              selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            )
          : null,
      ),
    );
  }
}

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'USUARIO';

    return Scaffold(
      appBar: AppBar(
        title: const Text('MINDBOX'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOLA, ${userName.toUpperCase()}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.isMobile(context) ? 24 : 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¿QUÉ QUIERES HACER HOY?',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.isMobile(context) ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'ACCESOS DIRECTOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Shortcut Grid/List
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
                        childAspectRatio: 2.5,
                        children: [
                          _buildShortcutItem(
                            context, 
                            title: 'MIS LOGROS', 
                            subtitle: 'CERTIFICADOS', 
                            icon: Icons.school_outlined, 
                            color: BrandOrange,
                            route: '/certificates'
                          ),
                          _buildShortcutItem(
                            context, 
                            title: 'MI RED', 
                            subtitle: 'ESTADÍSTICAS', 
                            icon: Icons.hub_outlined, 
                            color: NetworkBlue,
                            route: '/stats'
                          ),
                          _buildShortcutItem(
                            context, 
                            title: 'ESCÁNER ID', 
                            subtitle: 'DOCUMENTOS', 
                            icon: Icons.document_scanner_outlined, 
                            color: BrandPurple,
                            route: '/document_scanner'
                          ),
                          _buildShortcutItem(
                            context, 
                            title: 'MI CV', 
                            subtitle: 'CURRÍCULUM', 
                            icon: Icons.contact_page_outlined, 
                            color: BrandGreen,
                            route: '/resume'
                          ),
                        ],
                      );
                    }
                    
                    return Column(
                      children: [
                        _buildShortcutItem(
                          context, 
                          title: 'MIS LOGROS', 
                          subtitle: 'CERTIFICADOS Y DIPLOMAS', 
                          icon: Icons.school_outlined, 
                          color: BrandOrange,
                          route: '/certificates'
                        ),
                        const SizedBox(height: 8),
                        _buildShortcutItem(
                          context, 
                          title: 'MI RED', 
                          subtitle: 'ESTADÍSTICAS Y CONTACTOS', 
                          icon: Icons.hub_outlined, 
                          color: NetworkBlue,
                          route: '/stats'
                        ),
                        const SizedBox(height: 8),
                        _buildShortcutItem(
                          context, 
                          title: 'ESCÁNER ID', 
                          subtitle: 'DIGITALIZA DOCUMENTOS', 
                          icon: Icons.document_scanner_outlined, 
                          color: BrandPurple,
                          route: '/document_scanner'
                        ),
                        const SizedBox(height: 8),
                        _buildShortcutItem(
                          context, 
                          title: 'MI CV', 
                          subtitle: 'CURRÍCULUM VITAE DINÁMICO', 
                          icon: Icons.contact_page_outlined, 
                          color: BrandGreen,
                          route: '/resume'
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0), // Grid manages spacing
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(4),
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
                    border: Border.all(color: color.withOpacity(0.2)),
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
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
