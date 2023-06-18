import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglist/data/categories.dart';
import 'package:shoppinglist/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var itemName = '';
  var itemQuantity = 1;
  var itemCategory = categories[Categories.carbs];
  void saveState() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    final url = Uri.https('shopping-list-2b551-default-rtdb.firebaseio.com',
        'shopping-list.json');
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'name': itemName,
          'quantity': itemQuantity,
          'category': itemCategory!.name
        },
      ),
    );
    final response = await http.get(url);
    Map<String, dynamic> responseItem = jsonDecode(response.body);

    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(GroceryItem(
        id: responseItem.entries.toList()[0].key,
        category: itemCategory!,
        name: itemName,
        quantity: itemQuantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.length > 50) {
                    return 'Name should have 1-50 characters!';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  itemName = newValue!;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Enter a valid non-negative number!';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        itemQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: itemCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(category.value.name),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            itemCategory = value;
                          });
                        }),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset')),
                  const SizedBox(
                    width: 12,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        saveState();
                      },
                      child: const Text('Add Item')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
