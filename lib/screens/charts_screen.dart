import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/savings_provider.dart';
import '../models/transaction.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Spending by Category'),
              Tab(text: 'Monthly Overview'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryPieChart(),
            _buildMonthlyBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        final categoryData = _calculateCategoryData(transactions);

        if (transactions.isEmpty) {
          return const Center(child: Text('No transaction data available'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: _createPieSections(categoryData),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(categoryData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyBarChart() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        final monthlyData = _calculateMonthlyData(transactions);

        if (transactions.isEmpty) {
          return const Center(child: Text('No transaction data available'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _findMaxAmount(monthlyData) * 1.2,
              barGroups: _createBarGroups(monthlyData),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _getMonthName(value.toInt()),
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, double> _calculateCategoryData(List<Transaction> transactions) {
    final categoryData = <String, double>{};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryData[transaction.category] =
            (categoryData[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    return categoryData;
  }

  List<PieChartSectionData> _createPieSections(Map<String, double> categoryData) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> categoryData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryData.entries.map((entry) {
        return Chip(
          label: Text(
            '${entry.key}: ₱${entry.value.toStringAsFixed(0)}',
          ),
        );
      }).toList(),
    );
  }

  Map<int, double> _calculateMonthlyData(List<Transaction> transactions) {
    final monthlyData = <int, double>{};
    
    for (final transaction in transactions) {
      final month = transaction.date.month;
      if (transaction.type == TransactionType.deposit) {
        monthlyData[month] = (monthlyData[month] ?? 0) + transaction.amount;
      } else {
        monthlyData[month] = (monthlyData[month] ?? 0) - transaction.amount;
      }
    }
    
    return monthlyData;
  }

  List<BarChartGroupData> _createBarGroups(Map<int, double> monthlyData) {
    return monthlyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: entry.value >= 0 ? Colors.green : Colors.red,
          ),
        ],
      );
    }).toList();
  }

  double _findMaxAmount(Map<int, double> monthlyData) {
    return monthlyData.values
        .map((amount) => amount.abs())
        .fold(0, (max, amount) => amount > max ? amount : max);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
} 