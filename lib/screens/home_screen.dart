import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'charts_screen.dart';
import 'add_goal_screen.dart';
import 'manage_categories_screen.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return IconButton(
                icon: Icon(
                  settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => settings.toggleDarkMode(),
              );
            },
          ),
        ],
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          final goals = provider.goals;
          final transactions = provider.transactions;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Savings',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱${_calculateTotalSavings(transactions)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 16),
              _buildSavingsGoalsList(goals),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
            heroTag: 'addTransaction',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddGoalScreen()),
            ),
            heroTag: 'addGoal',
            child: const Icon(Icons.flag),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          'History',
          Icons.history,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
          ),
        ),
        _buildActionButton(
          context,
          'Charts',
          Icons.pie_chart,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChartsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildSavingsGoalsList(List<SavingsGoal> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Goals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final progress = goal.currentAmount / goal.targetAmount;
            
            return Card(
              child: ListTile(
                title: Text(goal.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₱${goal.currentAmount} / ₱${goal.targetAmount}'),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  double _calculateTotalSavings(List<Transaction> transactions) {
    return transactions.fold(0.0, (total, transaction) {
      if (transaction.type == TransactionType.deposit) {
        return total + transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        return total - transaction.amount;
      }
      return total;
    });
  }
} 