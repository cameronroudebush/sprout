import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// An icon display for transaction categories
class CategoryIcon extends StatelessWidget {
  final Category? category;
  final double avatarSize;
  const CategoryIcon(this.category, {super.key, this.avatarSize = 20});

  /// Icons that we support for our category display
  static const Map<String, IconData> iconLibrary = {
    // Food & Drink
    'food_drink': Icons.fastfood,
    'groceries': Icons.local_grocery_store,
    'restaurants': Icons.restaurant,
    'coffee': Icons.coffee,
    'alcohol': Icons.local_bar,
    'bakery': Icons.bakery_dining,

    // Shopping & Personal
    'shopping': Icons.shopping_bag,
    'online_shopping': Icons.web,
    'clothing': Icons.checkroom,
    'jewelry': Icons.diamond,
    'electronics': Icons.devices,
    'personal_care': Icons.content_cut,
    'hair': Icons.face_retouching_natural,
    'cosmetics': Icons.brush,

    // Housing & Utilities
    'housing': Icons.home,
    'mortgage': Icons.domain,
    'rent': Icons.house,
    'home_improvement': Icons.construction,
    'utilities': Icons.lightbulb,
    'internet': Icons.router,
    'phone': Icons.smartphone,
    'water': Icons.water_drop,
    'maintenance': Icons.build,
    'furniture': Icons.chair,
    'laundry': Icons.local_laundry_service,

    // Transportation
    'transportation': Icons.directions_car,
    'gas': Icons.local_gas_station,
    'parking': Icons.local_parking,
    'auto_loan': Icons.car_rental,
    'auto_repair': Icons.car_repair,
    'taxi': Icons.local_taxi,
    'public_transit': Icons.directions_bus,
    'charging': Icons.ev_station,
    'bridge_toll': Icons.toll,
    'bicycle': Icons.pedal_bike,

    // Travel
    'travel': Icons.flight,
    'airfare': Icons.airplane_ticket,
    'hotel': Icons.hotel,
    'vacation': Icons.beach_access,
    'luggage': Icons.luggage,

    // Entertainment & Hobbies
    'entertainment': Icons.movie,
    'video_games': Icons.videogame_asset,
    'hobby': Icons.palette,
    '3d_printing': Icons.layers,
    'music': Icons.music_note,
    'recreation': Icons.sports_baseball,
    'fitness': Icons.fitness_center,
    'events': Icons.confirmation_number,
    'computer': Icons.computer,
    'photography': Icons.camera_alt,
    'sports': Icons.sports_soccer,
    'books': Icons.menu_book,
    'news': Icons.newspaper,
    'gaming': Icons.sports_esports,

    // Financial & Income
    'income': Icons.attach_money,
    'paycheck': Icons.work_history,
    'bonus': Icons.star,
    'savings': Icons.savings,
    'investments': Icons.trending_up,
    'stocks': Icons.show_chart,
    'buy': Icons.shopping_cart,
    'sale': Icons.sell,
    'dividend': Icons.currency_exchange,
    'crypto': Icons.currency_bitcoin,
    'bank': Icons.account_balance,
    'transfer': Icons.swap_horiz,
    'withdrawal': Icons.money_off,
    'fee': Icons.price_change,
    'tax': Icons.description,
    'loan': Icons.money,
    'refund': Icons.settings_backup_restore,
    'interest': Icons.percent,
    'reimbursement': Icons.assignment_return,
    'atm': Icons.atm,
    'pension': Icons.account_balance_wallet,

    // Credit & Payments
    'payment': Icons.payment,
    'credit_card': Icons.credit_card,
    'cc_payment': Icons.credit_score,
    'debt': Icons.money_off_csred,
    'cash': Icons.payments,

    // Health & Life
    'healthcare': Icons.local_hospital,
    'pharmacy': Icons.medication,
    'insurance': Icons.shield,
    'pets': Icons.pets,
    'vet': Icons.healing,
    'child_care': Icons.child_care,
    'education': Icons.school,

    // Occasions & Gifts
    'gift': Icons.redeem,
    'christmas': Icons.ac_unit,
    'holiday': Icons.celebration,
    'charity': Icons.volunteer_activism,
    'subscription': Icons.subscriptions,

    // Professional Services
    'legal': Icons.gavel,
    'accounting': Icons.calculate,
    'consulting': Icons.handshake,
    'shipping': Icons.local_shipping,
    'software': Icons.code,

    // Specific Bills & Subscriptions
    'streaming': Icons.play_circle_fill,
    'security': Icons.security,
    'storage': Icons.inventory_2,

    // Family & Household
    'tuition': Icons.history_edu,
    'baby_supplies': Icons.child_friendly,
    'toys': Icons.toys,
    'garden': Icons.yard,
    'home_insurance': Icons.home_repair_service,

    // Social & Occasions
    'party': Icons.party_mode,
    'flowers': Icons.local_florist,
    'donations': Icons.favorite,

    // Misc
    'service': Icons.room_service,
    'work': Icons.work,
    'print': Icons.print,
    'warning': Icons.warning,
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
