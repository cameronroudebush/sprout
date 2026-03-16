//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserConfig {
  /// Returns a new [UserConfig] instance.
  UserConfig({
    required this.id,
    required this.netWorthRange,
    required this.themeStyle,
    required this.privateMode,
    this.simpleFinToken,
    this.geminiKey,
    required this.secureMode,
    required this.allowWidgets,
  });

  String id;

  /// The net worth range to display by default
  ChartRangeEnum netWorthRange;

  /// The visual theme style selected by the user
  ThemeStyleEnum themeStyle;

  /// If we should hide balances on the users display
  bool privateMode;

  /// This property defines the SimpleFIN URL for obtaining data from the necessary endpoint. This will be encrypted in the database.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? simpleFinToken;

  /// This property defines the Gemini API token for LLM use.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? geminiKey;

  /// If we should require biometrics to view the app and if we should hide the app in the background
  bool secureMode;

  /// If we should allow widgets to be rendered with real data from Sprout. You will have to open the app at least once.
  bool allowWidgets;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserConfig &&
    other.id == id &&
    other.netWorthRange == netWorthRange &&
    other.themeStyle == themeStyle &&
    other.privateMode == privateMode &&
    other.simpleFinToken == simpleFinToken &&
    other.geminiKey == geminiKey &&
    other.secureMode == secureMode &&
    other.allowWidgets == allowWidgets;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (netWorthRange.hashCode) +
    (themeStyle.hashCode) +
    (privateMode.hashCode) +
    (simpleFinToken == null ? 0 : simpleFinToken!.hashCode) +
    (geminiKey == null ? 0 : geminiKey!.hashCode) +
    (secureMode.hashCode) +
    (allowWidgets.hashCode);

  @override
  String toString() => 'UserConfig[id=$id, netWorthRange=$netWorthRange, themeStyle=$themeStyle, privateMode=$privateMode, simpleFinToken=$simpleFinToken, geminiKey=$geminiKey, secureMode=$secureMode, allowWidgets=$allowWidgets]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'netWorthRange'] = this.netWorthRange;
      json[r'themeStyle'] = this.themeStyle;
      json[r'privateMode'] = this.privateMode;
    if (this.simpleFinToken != null) {
      json[r'simpleFinToken'] = this.simpleFinToken;
    } else {
      json[r'simpleFinToken'] = null;
    }
    if (this.geminiKey != null) {
      json[r'geminiKey'] = this.geminiKey;
    } else {
      json[r'geminiKey'] = null;
    }
      json[r'secureMode'] = this.secureMode;
      json[r'allowWidgets'] = this.allowWidgets;
    return json;
  }

  /// Returns a new [UserConfig] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserConfig? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UserConfig[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UserConfig[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UserConfig(
        id: mapValueOfType<String>(json, r'id')!,
        netWorthRange: ChartRangeEnum.fromJson(json[r'netWorthRange'])!,
        themeStyle: ThemeStyleEnum.fromJson(json[r'themeStyle'])!,
        privateMode: mapValueOfType<bool>(json, r'privateMode')!,
        simpleFinToken: mapValueOfType<String>(json, r'simpleFinToken'),
        geminiKey: mapValueOfType<String>(json, r'geminiKey'),
        secureMode: mapValueOfType<bool>(json, r'secureMode')!,
        allowWidgets: mapValueOfType<bool>(json, r'allowWidgets')!,
      );
    }
    return null;
  }

  static List<UserConfig> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserConfig>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserConfig.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserConfig> mapFromJson(dynamic json) {
    final map = <String, UserConfig>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserConfig.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserConfig-objects as value to a dart map
  static Map<String, List<UserConfig>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserConfig>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserConfig.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'netWorthRange',
    'themeStyle',
    'privateMode',
    'secureMode',
    'allowWidgets',
  };
}

