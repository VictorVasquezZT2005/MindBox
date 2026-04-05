import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/data_providers.dart';

class CertificateDetailScreen extends ConsumerWidget {
  final String certificateId;
  const CertificateDetailScreen({super.key, required this.certificateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(certificatesProvider);

    return certificatesAsync.when(
      data: (certs) {
        final cert = certs.firstWhere((c) => c.id == certificateId, orElse: () => throw 'Not found');

        return Scaffold(
          appBar: AppBar(
            title: const Text('DETALLE LOGRO'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/edit_certificate/$certificateId'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cert.platform.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cert.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      cert.issueDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                if (cert.folio != null && cert.folio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'FOLIO: ${cert.folio}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'NOTAS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      (cert.notes == null || cert.notes!.isEmpty) ? 'Sin notas adicionales' : cert.notes!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ),
                if (cert.pdfUrl != null && cert.pdfUrl!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(cert.pdfUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('VER CERTIFICADO (PDF)'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }
}
