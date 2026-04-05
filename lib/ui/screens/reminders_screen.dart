import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/reminder.dart';
import '../../providers/data_providers.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Todas';

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RECORDATORIOS'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context).copyWith(bottom: 0),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: const InputDecoration(
                    hintText: 'BUSCAR RECORDATORIOS...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              remindersAsync.when(
                data: (reminders) {
                  final categories = ['Todas', ...reminders.map((r) => r.listCategory).toSet().toList()..sort()];
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsivePadding(context).left,
                    ),
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            selected: isSelected,
                            onSelected: (selected) => setState(() => _selectedCategory = category),
                            label: Text(category.toUpperCase(), style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                            )),
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
                child: remindersAsync.when(
                  data: (reminders) {
                    final filtered = reminders.where((r) {
                      final matchesSearch = r.title.toLowerCase().contains(_searchQuery.toLowerCase());
                      final matchesCategory = _selectedCategory == 'Todas' || r.listCategory == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('SIN RECORDATORIOS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      );
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
                              childAspectRatio: 3.5,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => ReminderCard(
                              reminder: filtered[index],
                              onDelete: () {
                                // Delete logic
                              },
                              onClick: () => context.push('/reminder_detail/${filtered[index].id}'),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          padding: padding,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => ReminderCard(
                            reminder: filtered[index],
                            onDelete: () {
                              // Delete logic
                            },
                            onClick: () => context.push('/reminder_detail/${filtered[index].id}'),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_reminder'),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  final VoidCallback onClick;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onDelete,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 2,
                height: 32,
                color: reminder.isUrgent ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (reminder.date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${reminder.date} • ${reminder.time}'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
