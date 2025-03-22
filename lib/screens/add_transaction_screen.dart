import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../providers/settings_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionType _type = TransactionType.deposit;
  String _category = 'General';
  String? _selectedGoalId;
  
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SavingsProvider>(context, listen: false);
      
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
        type: _type,
        category: _category,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        goalId: _selectedGoalId,
      );

      provider.addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTransactionTypeSelector(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildGoalSelector(),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.deposit,
          label: Text('Deposit'),
          icon: Icon(Icons.add),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Expense'),
          icon: Icon(Icons.shopping_cart),
        ),
      ],
      selected: {_type},
      onSelectionChanged: (Set<TransactionType> newSelection) {
        setState(() {
          _type = newSelection.first;
        });
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Amount',
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
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: settings.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _category = value!;
            });
          },
        );
      },
    );
  }

  Widget _buildGoalSelector() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final goals = provider.goals;
        
        if (goals.isEmpty) {
          return const SizedBox.shrink();
        }

        return DropdownButtonFormField<String>(
          value: _selectedGoalId,
          decoration: const InputDecoration(
            labelText: 'Savings Goal (Optional)',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('None'),
            ),
            ...goals.map((goal) {
              return DropdownMenuItem(
                value: goal.id,
                child: Text(goal.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGoalId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'Note (Optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }
} 