import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_categoryController.text.isNotEmpty) {
      Provider.of<SettingsProvider>(context, listen: false)
          .addCategory(_categoryController.text);
      _categoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'New Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return ListView.builder(
                  itemCount: settings.categories.length,
                  itemBuilder: (context, index) {
                    final category = settings.categories[index];
                    return ListTile(
                      title: Text(category),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          settings.deleteCategory(category);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 