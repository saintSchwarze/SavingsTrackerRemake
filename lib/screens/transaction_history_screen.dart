import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../models/transaction.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;
          
          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(context, transaction);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    final isPositive = transaction.type == TransactionType.deposit;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.add_circle : Icons.remove_circle;
    final amountPrefix = isPositive ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        Provider.of<SavingsProvider>(context, listen: false)
            .deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(transaction.category),
          subtitle: Text(
            transaction.note ?? 'No note',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix₱${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(transaction.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 