import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/service_providers.dart';
import '../../providers/gemini_provider.dart';

class MarkdownToolbar extends ConsumerWidget {
  final TextEditingController controller;

  const MarkdownToolbar({super.key, required this.controller});

  void _insertMarkdown(String prefix, {String suffix = ''}) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.baseOffset == -1) {
      controller.text = '$text$prefix$suffix';
      controller.selection = TextSelection.collapsed(offset: controller.text.length - suffix.length);
    } else {
      final start = selection.start;
      final end = selection.end;
      final selectedText = text.substring(start, end);
      final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: start + prefix.length + selectedText.length);
    }
  }

  Future<void> _handleAIAction(BuildContext context, WidgetRef ref, String action) async {
    final apiKey = ref.read(geminiKeyProvider);
    if (apiKey.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configura tu Gemini API Key en el Perfil.')),
      );
      return;
    }

    final text = controller.text;
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe algo primero.')),
      );
      return;
    }

    // Indicador sutil de que la IA está trabajando
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text('IA TRABAJANDO... ESPERA UN MOMENTO'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    String result = '';
    try {
      final aiService = ref.read(aiServiceProvider);
      print('DEBUG UI: Iniciando acción IA: $action (Sin bloqueo de pantalla)');
      
      if (action == 'summarize') {
        result = await aiService.summarize(text);
      } else if (action == 'grammar') {
        result = await aiService.fixGrammar(text);
      } else if (action == 'continue') {
        result = await aiService.continueWriting(text);
      } else if (action.startsWith('custom:')) {
        final prompt = action.replaceFirst('custom:', '');
        result = await aiService.customPrompt(text, prompt);
      }
      
      if (result.isNotEmpty) {
        if (action == 'grammar') {
          controller.text = result;
          controller.selection = TextSelection.collapsed(offset: controller.text.length);
        } else if (action == 'summarize') {
          _insertMarkdown('\n\n### Resumen IA\n', suffix: result);
        } else if (action == 'continue') {
          _insertMarkdown('\n\n', suffix: result);
        } else if (action.startsWith('custom:')) {
          _insertMarkdown('\n\n---\n', suffix: result);
        }
        print('DEBUG UI: Texto insertado con éxito');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('IA: PROCESO COMPLETADO'), duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      print('DEBUG UI ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de IA: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAIOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('ASISTENTE IA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.purple),
                  title: const Text('Instrucción personalizada'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCustomPromptDialog(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.short_text),
                  title: const Text('Resumir nota'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleAIAction(context, ref, 'summarize');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.spellcheck),
                  title: const Text('Corregir ortografía'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleAIAction(context, ref, 'grammar');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('Continuar escribiendo'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleAIAction(context, ref, 'continue');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomPromptDialog(BuildContext context, WidgetRef ref) {
    final promptController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿QUÉ QUIERES QUE HAGA?'),
        content: TextField(
          controller: promptController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ej: Traduce al inglés...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              final prompt = promptController.text.trim();
              if (prompt.isNotEmpty) {
                Navigator.pop(context);
                _handleAIAction(context, ref, 'custom:$prompt');
              }
            },
            child: const Text('EJECUTAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.purple),
            onPressed: () => _showAIOptions(context, ref),
          ),
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
          _ToolbarButton(icon: Icons.format_bold, tooltip: 'Negrita', onPressed: () => _insertMarkdown('**', suffix: '**')),
          _ToolbarButton(icon: Icons.format_italic, tooltip: 'Cursiva', onPressed: () => _insertMarkdown('_', suffix: '_')),
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
          _ToolbarButton(icon: Icons.title, tooltip: 'Título 1', onPressed: () => _insertMarkdown('\n# ')),
          _ToolbarButton(icon: Icons.format_size, tooltip: 'Título 2', onPressed: () => _insertMarkdown('\n## ')),
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
          _ToolbarButton(icon: Icons.format_list_bulleted, tooltip: 'Lista', onPressed: () => _insertMarkdown('\n- ')),
          _ToolbarButton(icon: Icons.format_list_numbered, tooltip: 'Lista Numerada', onPressed: () => _insertMarkdown('\n1. ')),
          const VerticalDivider(width: 16, indent: 8, endIndent: 8),
          _ToolbarButton(icon: Icons.code, tooltip: 'Código', onPressed: () => _insertMarkdown('\n```\n', suffix: '\n```\n')),
          _ToolbarButton(icon: Icons.format_quote, tooltip: 'Cita', onPressed: () => _insertMarkdown('\n> ')),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  const _ToolbarButton({required this.icon, required this.onPressed, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }
}
