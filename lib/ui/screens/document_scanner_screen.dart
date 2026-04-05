import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  File? _frontImage;
  File? _backImage;
  bool _isGenerating = false;
  final _picker = ImagePicker();

  Future<void> _captureImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_frontImage == null || _backImage == null) return;

    setState(() => _isGenerating = true);
    try {
      final pdf = pw.Document();
      final frontImg = pw.MemoryImage(_frontImage!.readAsBytesSync());
      final backImg = pw.MemoryImage(_backImage!.readAsBytesSync());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(frontImg, width: 365, height: 230),
                  pw.SizedBox(height: 50),
                  pw.Image(backImg, width: 365, height: 230),
                ],
              ),
            );
          },
        ),
      );

      final output = await getExternalStorageDirectory();
      final file = File("${output?.path}/Copia_ID_150_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF GUARDADO EN: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: $e')),
        );
      }
    }
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESCÁNER ID'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBox(BrandPurple),
                const SizedBox(height: 32),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = ResponsiveUtils.isDesktop(context);
                    final bool isTablet = ResponsiveUtils.isTablet(context);
                    
                    if (isDesktop || isTablet) {
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.8,
                        children: [
                          _buildDocumentCard("PARTE FRONTAL", _frontImage, Icons.badge_outlined, BrandPurple, () => _captureImage(true)),
                          _buildDocumentCard("PARTE TRASERA", _backImage, Icons.credit_card_outlined, BrandPurple, () => _captureImage(false)),
                        ],
                      );
                    }
                    
                    return Column(
                      children: [
                        _buildDocumentCard("PARTE FRONTAL", _frontImage, Icons.badge_outlined, BrandPurple, () => _captureImage(true)),
                        const SizedBox(height: 16),
                        _buildDocumentCard("PARTE TRASERA", _backImage, Icons.credit_card_outlined, BrandPurple, () => _captureImage(false)),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                _buildGenerateButton(BrandPurple),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "CAPTURA LA FOTO PARA GENERAR TU COPIA 150%.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), 
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String label, File? image, IconData icon, Color color, VoidCallback onTap) {
    final captured = image != null;
    final cardColor = captured ? BrandGreen : color;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(captured ? Icons.check_circle_outline : icon, color: cardColor, size: 40),
              const SizedBox(height: 16),
              Text(
                label, 
                style: const TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 14,
                  letterSpacing: 0.5,
                )
              ),
              const SizedBox(height: 4),
              Text(
                captured ? "TOCA PARA CAMBIAR" : "TOCA PARA CAPTURAR", 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), 
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(Color color) {
    final canGenerate = _frontImage != null && _backImage != null && !_isGenerating;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generatePdf : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        icon: _isGenerating 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.picture_as_pdf_outlined, size: 20),
        label: const Text(
          "GENERAR PDF",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
