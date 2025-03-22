import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 2)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final DateTime targetDate;

  @HiveField(4)
  double currentAmount;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    this.currentAmount = 0,
  });
} 