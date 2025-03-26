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
            _CategoryPieChart(),
            _buildMonthlyBarChart(),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatefulWidget {
  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  bool showSavings = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        final categoryData = showSavings
            ? _calculateSavingsByCategory(transactions)
            : _calculateCategoryData(transactions);

        if (transactions.isEmpty) {
          return const Center(child: Text('No transaction data available'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Show Savings'),
                  Switch(
                    value: showSavings,
                    onChanged: (value) {
                      setState(() {
                        showSavings = value;
                      });
                    },
                  ),
                ],
              ),
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

  Map<String, double> _calculateSavingsByCategory(List<Transaction> transactions) {
    final categoryData = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.deposit) {
        categoryData[transaction.category] =
            (categoryData[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return categoryData;
  }
}

Widget _buildMonthlyBarChart() {
  return Consumer<SavingsProvider>(
    builder: (context, provider, child) {
      final transactions = provider.transactions;
      final monthlySavings = _calculateMonthlyData(transactions);
      final monthlyExpenses = _calculateMonthlyExpenses(transactions);

      if (transactions.isEmpty) {
        return const Center(child: Text('No transaction data available'));
      }

      // Find the maximum value between savings and expenses
      final maxSavings = _findMaxAmount(monthlySavings);
      final maxExpenses = _findMaxAmount(monthlyExpenses);
      final maxY = ((maxSavings > maxExpenses ? maxSavings : maxExpenses) * 1.2)
          .clamp(0, double.infinity);

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: SizedBox(
            width: 1000, // Adjust width to fit all months
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble(),
                barGroups: _createBarGroups(monthlySavings, monthlyExpenses),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Use the _getMonthName method to map numeric values to month names
                        final monthName = _getMonthName(value.toInt());
                        return Text(
                          monthName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 28, // Space for the month names
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // Hide numbers on the left
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // Hide numbers on the left
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // Hide numbers on the left
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: false, // Hide grid lines for a cleaner look
                ),
                borderData: FlBorderData(
                  show: false, // Hide borders for a minimalistic design
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.7),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(2),
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
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

Map<int, double> _calculateMonthlyExpenses(List<Transaction> transactions) {
  final monthlyExpenses = <int, double>{};

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.expense) {
      final month = transaction.date.month;
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + transaction.amount;
    }
  }

  return monthlyExpenses;
}

List<BarChartGroupData> _createBarGroups(Map<int, double> monthlyData, Map<int, double> monthlyExpenses) {
  const darkGreen = Color.fromARGB(255, 13, 99, 10); // Lighter shade of green
  const darkRed = Color.fromARGB(255, 134, 23, 13); // Lighter shade of red

  return List.generate(12, (index) {
    final month = index + 1; // Months are 1-based
    final savings = monthlyData[month] ?? 0; // Default to 0 if no data
    final expenses = monthlyExpenses[month] ?? 0; // Default to 0 if no data

    return BarChartGroupData(
      x: month,
      barRods: [
        BarChartRodData(
          toY: savings,
          color: darkGreen,
          width: 20, // Increased bar width for thicker bars
          borderRadius: BorderRadius.circular(4), // Rounded corners
        ),
        BarChartRodData(
          toY: expenses,
          color: darkRed,
          width: 20, // Increased bar width for thicker bars
          borderRadius: BorderRadius.circular(4), // Rounded corners
        ),
      ],
      barsSpace: 4, // Reduced space between bars for compression
    );
  });
}

double _findMaxAmount(Map<int, double> data) {
  if (data.isEmpty) return 0;
  return data.values.map((amount) => amount.abs()).reduce((a, b) => a > b ? a : b);
}

String _getMonthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}