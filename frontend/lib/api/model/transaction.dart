//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Transaction {
  /// Returns a new [Transaction] instance.
  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.pending,
    this.category,
    required this.posted,
    required this.account,
    this.extra,
    this.manuallyEdited = false,
  });

  String id;

  /// In the currency of the account
  num amount;

  String description;

  bool pending;

  /// The category this transaction belongs to. A null category signifies an unknown category.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Category? category;

  /// The date this transaction posted
  DateTime posted;

  /// The account this transaction belongs to
  Account account;

  /// Any extra data that we want to store as JSON
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Object? extra;

  /// Tracks if this transaction was manually edited by the user. Used to prevent automation from overwriting it for transactional rules. This will be rest if automation does update it.
  bool manuallyEdited;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Transaction &&
    other.id == id &&
    other.amount == amount &&
    other.description == description &&
    other.pending == pending &&
    other.category == category &&
    other.posted == posted &&
    other.account == account &&
    other.extra == extra &&
    other.manuallyEdited == manuallyEdited;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (amount.hashCode) +
    (description.hashCode) +
    (pending.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (posted.hashCode) +
    (account.hashCode) +
    (extra == null ? 0 : extra!.hashCode) +
    (manuallyEdited.hashCode);

  @override
  String toString() => 'Transaction[id=$id, amount=$amount, description=$description, pending=$pending, category=$category, posted=$posted, account=$account, extra=$extra, manuallyEdited=$manuallyEdited]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'amount'] = this.amount;
      json[r'description'] = this.description;
      json[r'pending'] = this.pending;
    if (this.category != null) {
      json[r'category'] = this.category;
    } else {
      json[r'category'] = null;
    }
      json[r'posted'] = this.posted.toUtc().toIso8601String();
      json[r'account'] = this.account;
    if (this.extra != null) {
      json[r'extra'] = this.extra;
    } else {
      json[r'extra'] = null;
    }
      json[r'manuallyEdited'] = this.manuallyEdited;
    return json;
  }

  /// Returns a new [Transaction] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Transaction? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Transaction[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Transaction[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Transaction(
        id: mapValueOfType<String>(json, r'id')!,
        amount: num.parse('${json[r'amount']}'),
        description: mapValueOfType<String>(json, r'description')!,
        pending: mapValueOfType<bool>(json, r'pending')!,
        category: Category.fromJson(json[r'category']),
        posted: mapDateTime(json, r'posted', r'')!,
        account: Account.fromJson(json[r'account'])!,
        extra: mapValueOfType<Object>(json, r'extra'),
        manuallyEdited: mapValueOfType<bool>(json, r'manuallyEdited') ?? false,
      );
    }
    return null;
  }

  static List<Transaction> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Transaction>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Transaction.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Transaction> mapFromJson(dynamic json) {
    final map = <String, Transaction>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Transaction.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Transaction-objects as value to a dart map
  static Map<String, List<Transaction>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Transaction>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Transaction.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'amount',
    'description',
    'pending',
    'posted',
    'account',
  };
}

