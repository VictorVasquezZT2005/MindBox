import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/resume.dart';
import '../../data/models/certificate.dart';
import '../../providers/data_providers.dart';

class ResumeScreen extends ConsumerStatefulWidget {
  const ResumeScreen({super.key});

  @override
  ConsumerState<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends ConsumerState<ResumeScreen> {
  ResumeData _resumeData = ResumeData();

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(certificatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MI CURRICULUM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              // PDF generation logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generando PDF...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('DATOS PERSONALES', Icons.person),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Nombre completo',
                      initialValue: _resumeData.personalInfo.name,
                      onChanged: (val) => setState(() => _resumeData = _resumeData.copyWith(
                        personalInfo: _resumeData.personalInfo.copyWith(name: val),
                      )),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Correo electrónico',
                      initialValue: _resumeData.personalInfo.email,
                      onChanged: (val) => setState(() => _resumeData = _resumeData.copyWith(
                        personalInfo: _resumeData.personalInfo.copyWith(email: val),
                      )),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Teléfono',
                      initialValue: _resumeData.personalInfo.phone,
                      onChanged: (val) => setState(() => _resumeData = _resumeData.copyWith(
                        personalInfo: _resumeData.personalInfo.copyWith(phone: val),
                      )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('FORMACIÓN ACADÉMICA', Icons.school),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Universidad',
                      initialValue: _resumeData.education.university,
                      onChanged: (val) => setState(() => _resumeData = _resumeData.copyWith(
                        education: _resumeData.education.copyWith(university: val),
                      )),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Secundaria',
                      initialValue: _resumeData.education.secondary,
                      onChanged: (val) => setState(() => _resumeData = _resumeData.copyWith(
                        education: _resumeData.education.copyWith(secondary: val),
                      )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('CURSOS Y CERTIFICACIONES', Icons.verified),
            certificatesAsync.when(
              data: (certs) => Column(
                children: certs.map((cert) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(cert.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('${cert.platform} • ${cert.issueDate}', style: const TextStyle(fontSize: 12)),
                    leading: const Icon(Icons.check_circle, size: 20),
                  ),
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('EXPERIENCIA LABORAL', Icons.work),
            ..._resumeData.experiences.asMap().entries.map((entry) {
              int idx = entry.key;
              Experience exp = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Empresa',
                        initialValue: exp.company,
                        onChanged: (val) {
                          var list = List<Experience>.from(_resumeData.experiences);
                          list[idx] = exp.copyWith(company: val);
                          setState(() => _resumeData = _resumeData.copyWith(experiences: list));
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: 'Cargo',
                        initialValue: exp.position,
                        onChanged: (val) {
                          var list = List<Experience>.from(_resumeData.experiences);
                          list[idx] = exp.copyWith(position: val);
                          setState(() => _resumeData = _resumeData.copyWith(experiences: list));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            TextButton.icon(
              onPressed: () {
                setState(() => _resumeData = _resumeData.copyWith(
                  experiences: [..._resumeData.experiences, Experience()],
                ));
              },
              icon: const Icon(Icons.add),
              label: const Text('AÑADIR EXPERIENCIA'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, required Function(String) onChanged}) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
