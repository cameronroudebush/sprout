import 'package:flutter/material.dart';
import 'package:sprout/transaction/models/category.dart';

/// An icon display for transaction categories
class CategoryIcon extends StatelessWidget {
  final Category? category;
  final double avatarSize;
  const CategoryIcon(this.category, {super.key, this.avatarSize = 20});

  IconData _getIconForCategory(Category? category) {
    if (category == null) {
      return Icons.category;
    }

    final categoryName = category.name.toLowerCase();

    switch (categoryName) {
      case 'food & drink':
        return Icons.fastfood;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'restaurants':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'online shopping':
        return Icons.web;
      case 'utilities':
        return Icons.lightbulb;
      case 'housing':
        return Icons.home;
      case 'transportation':
        return Icons.directions_car;
      case 'healthcare':
        return Icons.local_hospital;
      case 'entertainment':
        return Icons.movie;
      case 'pets':
        return Icons.pets;
      case 'travel':
        return Icons.flight;
      case 'service':
        return Icons.room_service;
      case 'recreation':
        return Icons.sports_baseball;
      case 'shops':
        return Icons.shopping_bag;
      case 'unauthorized':
        return Icons.warning;
      case 'loan':
        return Icons.money;
      case 'interest':
        return Icons.money_off;
      case 'payment':
        return Icons.payment;
      case 'income':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: avatarSize, child: Icon(_getIconForCategory(category)));
  }
}
