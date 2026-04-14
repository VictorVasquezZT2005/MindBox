import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/note.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';
  String _selectedType = 'Todas';

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS NOTAS'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context).copyWith(bottom: 0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'BUSCAR NOTAS...',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),
            
            notesAsync.when(
              data: (notes) {
                final types = ['Todas', ...notes.map((n) => n.type).toSet().toList()..sort()];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsivePadding(context).left,
                    vertical: 16,
                  ),
                  child: Row(
                    children: types.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(type.toUpperCase(), style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          )),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedType = type),
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
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  final filtered = notes.where((n) {
                    final matchesSearch = n.content.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesType = _selectedType == 'Todas' || n.type == _selectedType;
                    return matchesSearch && matchesType;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('SIN NOTAS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
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
                          itemBuilder: (context, index) => NoteCard(
                            note: filtered[index],
                            onDelete: () => _showDeleteDialog(context, filtered[index]),
                            onClick: () => context.push('/note_detail/${filtered[index].id}'),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: padding,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => NoteCard(
                          note: filtered[index],
                          onDelete: () => _showDeleteDialog(context, filtered[index]),
                          onClick: () => context.push('/note_detail/${filtered[index].id}'),
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
        onPressed: () => context.push('/new_note'),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('¿ELIMINAR NOTA?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text('ESTA NOTA SE ELIMINARÁ PERMANENTEMENTE.', style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                await ref.read(firebaseServiceProvider).deleteNote(user.uid, note.id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onClick;

  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onClick,
  });

  Color getCategoryColor(BuildContext context, String type) {
    switch (type) {
      case 'Trabajo': return Colors.blue;
      case 'Idea': return Colors.orange;
      case 'Urgente': return Colors.red;
      case 'Personal': return Colors.green;
      default: return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = getCategoryColor(context, note.type);
    
    // Clean markdown characters from title
    String rawTitle = note.content.split('\n').first;
    String title = rawTitle.replaceAll(RegExp(r'^[#*\-\s]+'), '').trim();

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                  border: Border.all(color: categoryColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(4),
                  color: categoryColor.withOpacity(0.05),
                ),
                child: Icon(Icons.description_outlined, size: 18, color: categoryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'SIN TÍTULO' : title.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note.type.toUpperCase(),
                      style: TextStyle(color: categoryColor.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
