import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../providers/data_providers.dart';
import '../../providers/service_providers.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/note.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';
import '../widgets/markdown_toolbar.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final String noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedType = 'Personal';
  bool _initialized = false;
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return notesAsync.when(
      data: (notes) {
        final note = notes.firstWhere(
          (n) => n.id == widget.noteId, 
          orElse: () => Note(id: '', content: '', type: 'Personal', userId: '', timestamp: 0),
        );
        
        if (!_initialized && note.id.isNotEmpty) {
          final lines = note.content.split('\n');
          _titleController.text = lines.first;
          _contentController.text = lines.length > 1 ? lines.sublist(1).join('\n') : '';
          _selectedType = note.type;
          _initialized = true;
          _isPreview = true; // Empieza en modo lectura (preview)
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('EDITAR NOTA'),
            centerTitle: ResponsiveUtils.isDesktop(context),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(_isPreview ? Icons.edit_note : Icons.preview),
                tooltip: _isPreview ? 'Editar' : 'Vista previa',
                onPressed: () => setState(() => _isPreview = !_isPreview),
              ),
              IconButton(
                icon: const Icon(Icons.done),
                onPressed: () async {
                  final user = ref.read(currentUserProvider);
                  if (user != null && note.id.isNotEmpty) {
                    final fullContent = _titleController.text.isNotEmpty 
                      ? '${_titleController.text}\n${_contentController.text}' 
                      : _contentController.text;
                    
                    final updatedNote = note.copyWith(
                      content: fullContent,
                      type: _selectedType,
                    );
                    
                    await ref.read(firebaseServiceProvider).updateNote(user.uid, note.id, updatedNote);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nota actualizada')),
                      );
                      setState(() => _isPreview = true);
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: ResponsiveContainer(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: ['Personal', 'Trabajo', 'Idea', 'Urgente'].map((t) {
                        final isSelected = _selectedType == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedType = t),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            selectedColor: Theme.of(context).colorScheme.primary,
                            labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (!_isPreview)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'TÍTULO',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  if (!_isPreview) const Divider(height: 1),
                  Expanded(
                    child: _isPreview
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_titleController.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      _titleController.text,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                MarkdownBody(
                                  data: _contentController.text.isEmpty ? '*Sin contenido*' : _contentController.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(fontSize: 16, height: 1.5),
                                    h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    listBullet: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _contentController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'ESCRIBE ALGO... (SOPORTA MARKDOWN)',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                  ),
                  if (!_isPreview) MarkdownToolbar(controller: _contentController),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }
}
