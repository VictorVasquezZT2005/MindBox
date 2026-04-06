import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/models/note.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';
import '../widgets/markdown_toolbar.dart';

class NewNoteScreen extends ConsumerStatefulWidget {
  const NewNoteScreen({super.key});

  @override
  ConsumerState<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends ConsumerState<NewNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'Personal';
  final List<String> _types = ['Personal', 'Trabajo', 'Idea', 'Urgente'];
  bool _isPreview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVA NOTA'),
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
              if (user != null) {
                final fullContent = _titleController.text.isNotEmpty 
                  ? '${_titleController.text}\n${_contentController.text}' 
                  : _contentController.text;
                
                final note = Note(
                  id: '', 
                  userId: user.uid,
                  content: fullContent,
                  type: _selectedType,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                );
                
                final noteId = await ref.read(firebaseServiceProvider).addNote(user.uid, note);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nota guardada')),
                  );
                  context.pushReplacement('/note_detail/$noteId');
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
                  children: _types.map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        onSelected: (selected) => setState(() => _selectedType = type),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
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
                    decoration: const InputDecoration(
                      hintText: 'TÍTULO',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
  }
}
