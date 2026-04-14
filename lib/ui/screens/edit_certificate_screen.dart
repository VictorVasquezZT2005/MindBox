import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' as intl;
import '../../data/models/certificate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/data_providers.dart';

class EditCertificateScreen extends ConsumerStatefulWidget {
  final String certificateId;
  const EditCertificateScreen({super.key, required this.certificateId});

  @override
  ConsumerState<EditCertificateScreen> createState() => _EditCertificateScreenState();
}

class _EditCertificateScreenState extends ConsumerState<EditCertificateScreen> {
  final _titleController = TextEditingController();
  final _idController = TextEditingController();
  final _notesController = TextEditingController();
  final _scoreController = TextEditingController();
  final _credlyIdController = TextEditingController();
  final _credlyIssuerController = TextEditingController();
  
  String _platformType = 'Carlos Slim';
  DateTime? _selectedDate;
  File? _selectedPdf;
  Uint8List? _webPdfBytes;
  bool _isSaving = false;
  bool _initialized = false;
  String? _currentPdfUrl;

  final List<String> _platforms = ['Carlos Slim', 'Credly', 'Otro'];

  @override
  void dispose() {
    _titleController.dispose();
    _idController.dispose();
    _notesController.dispose();
    _scoreController.dispose();
    _credlyIdController.dispose();
    _credlyIssuerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(certificatesProvider);

    return certificatesAsync.when(
      data: (certs) {
        final cert = certs.firstWhere((c) => c.id == widget.certificateId, orElse: () => throw 'Not found');
        
        if (!_initialized) {
          _titleController.text = cert.title;
          _idController.text = cert.folio ?? '';
          _notesController.text = cert.notes ?? '';
          _scoreController.text = cert.score ?? '';
          _credlyIdController.text = cert.credlyId ?? '';
          _credlyIssuerController.text = cert.credlyIssuer ?? '';
          
          if (cert.platform.startsWith('Credly /')) {
            _platformType = 'Credly';
          } else {
            _platformType = cert.platform;
          }
          
          _currentPdfUrl = cert.pdfUrl;
          
          if (cert.issueDate.isNotEmpty) {
            try {
              _selectedDate = intl.DateFormat('dd/MM/yyyy').parse(cert.issueDate);
            } catch (_) {}
          }
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('EDITAR LOGRO'),
            actions: [
              if (!_isSaving)
                TextButton(
                  onPressed: _titleController.text.isEmpty ? null : _saveCertificate,
                  child: Text('ACTUALIZAR', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSaving) ...[
                  LinearProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                ],
                _buildSectionHeader('PLATAFORMA / EMISOR'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _platforms.map((p) {
                      final isSelected = _platformType == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(p.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          onSelected: null, // Disable changing platform in edit mode
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'TÍTULO DEL CURSO'),
                ),
                if (_platformType == 'Credly') ...[
                  const SizedBox(height: 24),
                  TextField(
                    controller: _credlyIssuerController,
                    decoration: const InputDecoration(labelText: 'EMISOR (EJ. CISCO)'),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _credlyIdController,
                    decoration: const InputDecoration(labelText: 'CREDLY ID'),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionHeader('FECHA DE EMISIÓN'),
                _buildSelectorTile(
                  icon: Icons.calendar_today_outlined,
                  text: _selectedDate == null ? 'SELECCIONAR FECHA' : intl.DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _idController,
                        decoration: const InputDecoration(labelText: 'FOLIO / ID'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _scoreController,
                        decoration: const InputDecoration(labelText: 'CALIF.'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('ARCHIVO DE RESPALDO'),
                _buildSelectorTile(
                  icon: Icons.picture_as_pdf_outlined,
                  text: (_selectedPdf == null && _webPdfBytes == null) 
                    ? (_currentPdfUrl != null ? 'CAMBIAR PDF' : 'SELECCIONAR PDF')
                    : 'PDF SELECCIONADO',
                  onTap: _pickPdf,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'NOTAS ADICIONALES'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
      ),
    );
  }

  Widget _buildSelectorTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text, 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    
    if (result != null) {
      if (kIsWeb) {
        setState(() => _webPdfBytes = result.files.single.bytes);
      } else if (result.files.single.path != null) {
        setState(() => _selectedPdf = File(result.files.single.path!));
      }
    }
  }

  Future<void> _saveCertificate() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      String? pdfUrl = _currentPdfUrl;
      if (_selectedPdf != null) {
        pdfUrl = await ref.read(appwriteServiceProvider).uploadFile(
          _selectedPdf!.path,
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
      }

      final cert = Certificate(
        id: widget.certificateId,
        title: _titleController.text,
        platform: _platformType == 'Credly' ? 'Credly / ${_credlyIssuerController.text}' : _platformType,
        issueDate: _selectedDate != null ? intl.DateFormat('dd/MM/yyyy').format(_selectedDate!) : '',
        folio: _idController.text,
        notes: _notesController.text,
        score: _scoreController.text,
        credlyId: _platformType == 'Credly' ? _credlyIdController.text : null,
        credlyIssuer: _platformType == 'Credly' ? _credlyIssuerController.text : null,
        pdfUrl: pdfUrl,
      );

      await ref.read(firebaseServiceProvider).addCertificate(user.uid, cert);
      if (mounted) context.pop();
    }
    setState(() => _isSaving = false);
  }
}
