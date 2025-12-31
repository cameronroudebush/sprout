import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// An icon display for transaction categories
class CategoryIcon extends StatelessWidget {
  final Category? category;
  final double avatarSize;
  const CategoryIcon(this.category, {super.key, this.avatarSize = 20});

  /// Icons that we support for our category display
  static const Map<String, IconData> iconLibrary = {
    'food_drink': Icons.fastfood,
    'groceries': Icons.local_grocery_store,
    'restaurants': Icons.restaurant,
    'shopping': Icons.shopping_bag,
    'online_shopping': Icons.web,
    'utilities': Icons.lightbulb,
    'housing': Icons.home,
    'transportation': Icons.directions_car,
    'healthcare': Icons.local_hospital,
    'entertainment': Icons.movie,
    'pets': Icons.pets,
    'travel': Icons.flight,
    'service': Icons.room_service,
    'recreation': Icons.sports_baseball,
    'warning': Icons.warning,
    'loan': Icons.money,
    'interest': Icons.money_off,
    'payment': Icons.payment,
    'income': Icons.attach_money,
    'holiday': Icons.celebration,
    'savings': Icons.savings,
    'investments': Icons.trending_up,
    'bank': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'cash': Icons.payments,
    'tax': Icons.description,
    'insurance': Icons.shield,
    'subscription': Icons.subscriptions,
    'gift': Icons.redeem,
    'education': Icons.school,
    'fitness': Icons.fitness_center,
    'personal_care': Icons.content_cut,
    'laundry': Icons.local_laundry_service,
    'coffee': Icons.coffee,
    'gas': Icons.local_gas_station,
    'maintenance': Icons.build,
    'child_care': Icons.child_care,
    'charity': Icons.volunteer_activism,
    'phone': Icons.smartphone,
    'internet': Icons.router,
    'work': Icons.work,
    'hobby': Icons.palette,
    'print': Icons.print,
    'help': Icons.help_outline,
    'unknown': Icons.question_mark_rounded,
  };

  /// Attempts to load the icon from the library, else defaults to the category icon
  IconData _getIconForCategory(Category? category) {
    return iconLibrary[category?.icon] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: avatarSize,
      child: Icon(_getIconForCategory(category), size: avatarSize),
    );
  }
}
