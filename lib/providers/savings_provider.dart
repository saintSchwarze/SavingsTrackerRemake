import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';

class SavingsProvider extends ChangeNotifier {
  late Box<Transaction> _transactionsBox;
  late Box<SavingsGoal> _goalsBox;

  List<Transaction> get transactions => _transactionsBox.values.toList();
  List<SavingsGoal> get goals => _goalsBox.values.toList();

  SavingsProvider() {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    _transactionsBox = Hive.box<Transaction>('transactions');
    _goalsBox = Hive.box<SavingsGoal>('savings_goals');
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
    if (transaction.goalId != null) {
      updateGoalProgress(transaction.goalId!, transaction);
    }
    notifyListeners();
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await _goalsBox.put(goal.id, goal);
    notifyListeners();
  }

  Future<void> updateGoalProgress(String goalId, Transaction transaction) async {
    final goal = _goalsBox.get(goalId);
    if (goal != null) {
      if (transaction.type == TransactionType.deposit) {
        goal.currentAmount += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        goal.currentAmount -= transaction.amount;
      }
      await goal.save();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
    notifyListeners();
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _goalsBox.delete(id);
    notifyListeners();
  }
} 