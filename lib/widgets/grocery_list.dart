import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/models/grocery_item.dart';
import 'package:shoppinglist/widgets/grocery_item_detail.dart';
import 'package:shoppinglist/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var isLoading = false;
  List<GroceryItem> groceryItems = [];
  Widget? content = const Center(
    child: CircularProgressIndicator(),
  );
  void removeItem(int index) async {
    final item = groceryItems[index];
    final url = Uri.https('shopping-list-2b551-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    setState(() {
      groceryItems.removeAt(index);
    });
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        setState(() {
          groceryItems.insert(index, item);
        });
      }
    } catch (e) {
      setState(() {
        groceryItems.insert(index, item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    isLoading = true;
    final url = Uri.https('shopping-list-2b551-default-rtdb.firebaseio.com',
        'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = jsonDecode(response.body);
      if (response.statusCode >= 400) {
        setState(() {
          content = const Center(
            child: Text('List could not be loaded.'),
          );
        });
        return;
      }
      List<GroceryItem> itemData = [];
      for (final item in listData.entries) {
        final category = categories.entries.firstWhere(
            (element) => element.value.name == item.value['category']);
        itemData.add(
          GroceryItem(
              id: item.key,
              category: category.value,
              name: item.value['name'],
              quantity: item.value['quantity']),
        );
      }
      setState(() {
        isLoading = false;
        groceryItems = itemData;
      });
    } catch (exception) {
      setState(() {
        content = const Center(child: Text('Some error occured.'));
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && groceryItems.isEmpty) {
      content = const Center(child: Text('No items added yet.'));
    }
    if (groceryItems.isNotEmpty && !isLoading) {
      content = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(groceryItems[index]),
            background: Container(
              color: const Color.fromARGB(255, 193, 82, 74),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onDismissed: (direction) {
              removeItem(index);
            },
            child: GroceryItemDetail(
              item: groceryItems[index],
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              addItem();
            },
            icon: const Icon(Icons.add),
          ),
        ],
        title: const Text('Your Groceries'),
      ),
      body: content,
    );
  }
}
