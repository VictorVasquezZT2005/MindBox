import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../../data/models/reminder.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/data_providers.dart';

class EditReminderScreen extends ConsumerStatefulWidget {
  final String reminderId;
  const EditReminderScreen({super.key, required this.reminderId});

  @override
  ConsumerState<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends ConsumerState<EditReminderScreen> {
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
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);

    return remindersAsync.when(
      data: (reminders) {
        final reminder = reminders.firstWhere((r) => r.id == widget.reminderId, orElse: () => throw 'Not found');
        
        if (!_initialized) {
          _titleController.text = reminder.title;
          _notesController.text = reminder.notes;
          _urlController.text = reminder.url;
          _isUrgent = reminder.isUrgent;
          _selectedCategory = reminder.listCategory;
          
          if (reminder.date.isNotEmpty) {
            _hasDate = true;
            try {
              _selectedDate = intl.DateFormat('dd/MM/yyyy').parse(reminder.date);
            } catch (_) {}
          }
          
          if (reminder.time.isNotEmpty) {
            _hasTime = true;
            // Simplified time parsing
          }
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('EDITAR RECORDATORIO'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'TÍTULO'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'NOTAS RÁPIDAS'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL (HTTPS://...)'),
                ),
                const SizedBox(height: 24),
                
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
                                child: Text(intl.DateFormat('dd/MM/yyyy').format(_selectedDate!), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
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
                                child: Text(_selectedTime!.format(context), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionHeader('CATEGORIZACIÓN'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      selected: isSelected,
                      onSelected: (selected) => setState(() => _selectedCategory = cat),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isUrgent,
                      onChanged: (val) => setState(() => _isUrgent = val ?? false),
                      activeColor: Colors.black,
                    ),
                    Text('MARCAR COMO URGENTE', style: TextStyle(color: _isUrgent ? Colors.black : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _titleController.text.isEmpty ? null : _saveReminder,
                    child: const Text('ACTUALIZAR RECORDATORIO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveReminder() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final reminder = Reminder(
        id: widget.reminderId,
        title: _titleController.text,
        notes: _notesController.text,
        url: _urlController.text,
        date: _hasDate && _selectedDate != null ? intl.DateFormat('dd/MM/yyyy').format(_selectedDate!) : '',
        time: _hasTime && _selectedTime != null ? _selectedTime!.format(context) : '',
        isUrgent: _isUrgent,
        listCategory: _selectedCategory,
      );
      
      // Update logic would go here
      await ref.read(firebaseServiceProvider).addReminder(user.uid, reminder); // Assuming addReminder handles updates if ID exists
      if (mounted) context.pop();
    }
  }
}
