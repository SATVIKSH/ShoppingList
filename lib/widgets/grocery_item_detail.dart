import 'package:flutter/material.dart';
import 'package:shoppinglist/models/grocery_item.dart';

class GroceryItemDetail extends StatelessWidget {
  const GroceryItemDetail({super.key, required this.item});
  final GroceryItem item;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: item.category.color),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.name,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              )
            ],
          ),
        ),
        Text(
          item.quantity.toString(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        )
      ]),
    );
  }
}
