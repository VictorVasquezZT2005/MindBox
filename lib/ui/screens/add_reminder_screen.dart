import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../data/models/reminder.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../theme/responsive_layout.dart';
import '../theme/responsive_utils.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();
  
  bool _isUrgent = false;
  bool _hasDate = false;
  bool _hasTime = false;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  String _selectedCategory = 'Inbox';
  final List<String> _categories = ['Inbox', 'Personal', 'Trabajo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVO RECORDATORIO'),
        centerTitle: ResponsiveUtils.isDesktop(context),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'TÍTULO'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'NOTAS RÁPIDAS'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL (HTTPS://...)'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                
                _buildSectionHeader('FECHA Y HORA'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _hasDate,
                              onChanged: (val) {
                                setState(() => _hasDate = val ?? false);
                                if (_hasDate) _selectDate(context);
                              },
                            ),
                            const Text('FECHA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_hasDate && _selectedDate != null)
                              TextButton(
                                onPressed: () => _selectDate(context),
                                child: Text(
                                  intl.DateFormat('dd/MM/yyyy').format(_selectedDate!), 
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _hasTime,
                              onChanged: (val) {
                                setState(() => _hasTime = val ?? false);
                                if (_hasTime) _selectTime(context);
                              },
                            ),
                            const Text('HORA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_hasTime && _selectedTime != null)
                              TextButton(
                                onPressed: () => _selectTime(context),
                                child: Text(
                                  _selectedTime!.format(context), 
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader('CATEGORIZACIÓN'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          onSelected: (selected) => setState(() => _selectedCategory = cat),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _isUrgent,
                      onChanged: (val) => setState(() => _isUrgent = val ?? false),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      'MARCAR COMO URGENTE', 
                      style: TextStyle(
                        color: _isUrgent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                        fontSize: 11, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _titleController.text.isEmpty ? null : _saveReminder,
                    child: const Text('GUARDAR RECORDATORIO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveReminder() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final reminder = Reminder(
        title: _titleController.text,
        notes: _notesController.text,
        url: _urlController.text,
        date: _hasDate && _selectedDate != null ? intl.DateFormat('dd/MM/yyyy').format(_selectedDate!) : '',
        time: _hasTime && _selectedTime != null ? _selectedTime!.format(context) : '',
        isUrgent: _isUrgent,
        listCategory: _selectedCategory,
      );
      
      await ref.read(firebaseServiceProvider).addReminder(user.uid, reminder);
      if (mounted) context.pop();
    }
  }
}
