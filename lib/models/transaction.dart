import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  deposit,
  @HiveField(1)
  expense
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final String? goalId;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
    this.goalId,
  });
} 