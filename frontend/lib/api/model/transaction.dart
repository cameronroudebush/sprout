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
    this.categoryId,
    required this.accountId,
    required this.amount,
    required this.description,
    required this.pending,
    required this.posted,
    this.extra,
    this.manuallyEdited = false,
  });

  String id;

  /// The Id of the category related to this transaction, if set.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? categoryId;

  /// The Id of the account related to this transaction.
  String accountId;

  /// The numeric value converted to the user's preferred currency format. This overrides the original amount property.
  num amount;

  String description;

  bool pending;

  /// The date this transaction posted
  DateTime posted;

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
    other.categoryId == categoryId &&
    other.accountId == accountId &&
    other.amount == amount &&
    other.description == description &&
    other.pending == pending &&
    other.posted == posted &&
    other.extra == extra &&
    other.manuallyEdited == manuallyEdited;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (categoryId == null ? 0 : categoryId!.hashCode) +
    (accountId.hashCode) +
    (amount.hashCode) +
    (description.hashCode) +
    (pending.hashCode) +
    (posted.hashCode) +
    (extra == null ? 0 : extra!.hashCode) +
    (manuallyEdited.hashCode);

  @override
  String toString() => 'Transaction[id=$id, categoryId=$categoryId, accountId=$accountId, amount=$amount, description=$description, pending=$pending, posted=$posted, extra=$extra, manuallyEdited=$manuallyEdited]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.categoryId != null) {
      json[r'categoryId'] = this.categoryId;
    } else {
      json[r'categoryId'] = null;
    }
      json[r'accountId'] = this.accountId;
      json[r'amount'] = this.amount;
      json[r'description'] = this.description;
      json[r'pending'] = this.pending;
      json[r'posted'] = this.posted.toUtc().toIso8601String();
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
        assert(json.containsKey(r'id'), 'Required key "Transaction[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Transaction[id]" has a null value in JSON.');
        assert(json.containsKey(r'accountId'), 'Required key "Transaction[accountId]" is missing from JSON.');
        assert(json[r'accountId'] != null, 'Required key "Transaction[accountId]" has a null value in JSON.');
        assert(json.containsKey(r'amount'), 'Required key "Transaction[amount]" is missing from JSON.');
        assert(json[r'amount'] != null, 'Required key "Transaction[amount]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "Transaction[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "Transaction[description]" has a null value in JSON.');
        assert(json.containsKey(r'pending'), 'Required key "Transaction[pending]" is missing from JSON.');
        assert(json[r'pending'] != null, 'Required key "Transaction[pending]" has a null value in JSON.');
        assert(json.containsKey(r'posted'), 'Required key "Transaction[posted]" is missing from JSON.');
        assert(json[r'posted'] != null, 'Required key "Transaction[posted]" has a null value in JSON.');
        return true;
      }());

      return Transaction(
        id: mapValueOfType<String>(json, r'id')!,
        categoryId: mapValueOfType<String>(json, r'categoryId'),
        accountId: mapValueOfType<String>(json, r'accountId')!,
        amount: num.parse('${json[r'amount']}'),
        description: mapValueOfType<String>(json, r'description')!,
        pending: mapValueOfType<bool>(json, r'pending')!,
        posted: mapDateTime(json, r'posted', r'')!,
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
    'accountId',
    'amount',
    'description',
    'pending',
    'posted',
  };
}

