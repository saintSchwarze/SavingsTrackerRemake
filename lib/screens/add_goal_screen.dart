import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SavingsProvider>(context, listen: false);
      
      final goal = SavingsGoal(
        id: const Uuid().v4(),
        name: _nameController.text,
        targetAmount: double.parse(_amountController.text),
        targetDate: _targetDate,
      );

      provider.addSavingsGoal(goal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Savings Goal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₱',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Target Date'),
              subtitle: Text(_formatDate(_targetDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() {
                    _targetDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 