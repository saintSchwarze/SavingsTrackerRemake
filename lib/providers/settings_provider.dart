import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  Box<String>? _categoriesBox;
  Box<bool>? _settingsBox;
  
  bool _initialized = false;
  
  List<String> get categories => _categoriesBox?.values.toList() ?? [];
  bool get isDarkMode => _settingsBox?.get('isDarkMode', defaultValue: false) ?? false;
  bool get isInitialized => _initialized;

  SettingsProvider() {
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    _categoriesBox = await Hive.openBox<String>('categories');
    _settingsBox = await Hive.openBox<bool>('settings');
    
    // Add default categories if empty
    if (_categoriesBox!.isEmpty) {
      await addDefaultCategories();
    }
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> addDefaultCategories() async {
    final defaultCategories = [
      'General',
      'Salary',
      'Investment',
      'Bills',
      'Food',
      'Transportation',
      'Entertainment',
    ];

    for (final category in defaultCategories) {
      await _categoriesBox?.add(category);
    }
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    await _categoriesBox?.add(category);
    notifyListeners();
  }

  Future<void> deleteCategory(String category) async {
    final index = categories.indexOf(category);
    if (index != -1) {
      await _categoriesBox?.deleteAt(index);
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    final newValue = !isDarkMode;
    await _settingsBox?.put('isDarkMode', newValue);
    notifyListeners();
  }
} 