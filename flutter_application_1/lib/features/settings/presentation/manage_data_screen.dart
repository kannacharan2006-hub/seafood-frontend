import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api.dart';

class ManageDataScreen extends StatefulWidget {
  const ManageDataScreen({super.key});

  @override
  State<ManageDataScreen> createState() => _ManageDataScreenState();
}

class _ManageDataScreenState extends State<ManageDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List _categories = [];
  List _items = [];
  List _variants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categoriesData = await Api.get('/api/categories');
      try {
        final itemsData = await Api.get('/api/items');
        _items = List.from(itemsData['data'] ?? []);
      } catch (e) {
        _items = [];
      }
      try {
        final variantsData = await Api.get('/api/variants');
        _variants = List.from(variantsData['data'] ?? []);
      } catch (e) {
        _variants = [];
      }
      setState(() {
        _categories = List.from(categoriesData['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text('Manage Data',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Items'),
            Tab(text: 'Variants'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(),
                _buildItemsList(),
                _buildVariantsList(),
              ],
            ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () => _showAddDialog('category'),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          );
        }
        final category = _categories[index - 1];
        return Card(
          child: ListTile(
            title: Text(category['name'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog('category', category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem('category', category['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () => _showAddDialog('item'),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          );
        }
        final item = _items[index - 1];
        return Card(
          child: ListTile(
            title: Text(item['name'] ?? ''),
            subtitle: Text('Category ID: ${item['category_id'] ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog('item', item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem('item', item['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVariantsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _variants.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () => _showAddDialog('variant'),
              icon: const Icon(Icons.add),
              label: const Text('Add Variant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          );
        }
        final variant = _variants[index - 1];
        return Card(
          child: ListTile(
            title: Text(variant['grade'] ?? variant['variant_name'] ?? ''),
            subtitle: Text(
                '${variant['item_name'] ?? ''} - ${variant['category'] ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog('variant', variant),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem('variant', variant['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(String type) {
    final nameController = TextEditingController();
    String? selectedCategoryId;
    String? selectedItemId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${type[0].toUpperCase()}${type.substring(1)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: type == 'variant' ? 'Variant Name' : 'Name',
                border: const OutlineInputBorder(),
              ),
            ),
            if (type == 'item') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map<DropdownMenuItem<String>>((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text(c['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) => selectedCategoryId = value,
              ),
            ],
            if (type == 'variant') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Item',
                  border: OutlineInputBorder(),
                ),
                items: _items.map<DropdownMenuItem<String>>((i) {
                  return DropdownMenuItem<String>(
                    value: i['id'].toString(),
                    child: Text(i['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) => selectedItemId = value,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              try {
                if (type == 'category') {
                  await Api.post(
                      '/api/categories', {'name': nameController.text});
                } else if (type == 'item') {
                  await Api.post('/api/items', {
                    'name': nameController.text,
                    'category_id': selectedCategoryId
                  });
                } else if (type == 'variant') {
                  await Api.post('/api/variants', {
                    'variant_name': nameController.text,
                    'item_id': selectedItemId
                  });
                }
                _loadData();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String type, Map item) {
    final nameController = TextEditingController(
        text: item['name'] ?? item['variant_name'] ?? item['grade'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${type[0].toUpperCase()}${type.substring(1)}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              try {
                await Api.put('/api/${type}s/${item['id']}',
                    {'name': nameController.text});
                _loadData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String type, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Api.delete('/api/${type}s/$id');
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
