import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/transaction.dart';
import 'models/savings_goal.dart';
import 'providers/savings_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  
  // Open Hive boxes
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<SavingsGoal>('savings_goals');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.isInitialized) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Savings Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
