import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/certificate.dart';
import '../../providers/data_providers.dart';

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen> {
  String _searchQuery = '';
  String _selectedPlatform = 'Todas';

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(certificatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS LOGROS'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'BUSCAR CERTIFICADOS...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          certificatesAsync.when(
            data: (certificates) {
              final platforms = ['Todas', ...certificates.map((c) {
                if (c.platform.startsWith('Credly /')) {
                  return c.platform.replaceFirst('Credly / ', '');
                }
                return c.platform;
              }).toSet().toList()..sort()];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: platforms.map((platform) {
                    final isSelected = _selectedPlatform == platform;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(platform.toUpperCase(), style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                        )),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedPlatform = platform),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: certificatesAsync.when(
              data: (certificates) {
                final filtered = certificates.where((c) {
                  final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase());
                  
                  String displayPlatform = c.platform;
                  if (c.platform.startsWith('Credly /')) {
                    displayPlatform = c.platform.replaceFirst('Credly / ', '');
                  }
                  
                  final matchesPlatform = _selectedPlatform == 'Todas' || displayPlatform == _selectedPlatform;
                  return matchesSearch && matchesPlatform;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('SIN CERTIFICADOS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => CertificateCard(
                    certificate: filtered[index],
                    onClick: () => context.push('/certificate_detail/${filtered[index].id}'),
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
              error: (e, s) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_certificate'),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onClick;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    String displayPlatform = certificate.platform;
    if (certificate.platform.startsWith('Credly /')) {
      displayPlatform = certificate.platform.replaceFirst('Credly / ', '');
    }

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.verified_outlined, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayPlatform.toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
