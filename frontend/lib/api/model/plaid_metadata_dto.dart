//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlaidMetadataDTO {
  /// Returns a new [PlaidMetadataDTO] instance.
  PlaidMetadataDTO({
    required this.institution,
    this.accounts = const [],
    required this.linkSessionId,
  });

  PlaidInstitutionDTO institution;

  List<PlaidAccountDTO> accounts;

  String linkSessionId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlaidMetadataDTO &&
    other.institution == institution &&
    _deepEquality.equals(other.accounts, accounts) &&
    other.linkSessionId == linkSessionId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (institution.hashCode) +
    (accounts.hashCode) +
    (linkSessionId.hashCode);

  @override
  String toString() => 'PlaidMetadataDTO[institution=$institution, accounts=$accounts, linkSessionId=$linkSessionId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'institution'] = this.institution;
      json[r'accounts'] = this.accounts;
      json[r'link_session_id'] = this.linkSessionId;
    return json;
  }

  /// Returns a new [PlaidMetadataDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlaidMetadataDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'institution'), 'Required key "PlaidMetadataDTO[institution]" is missing from JSON.');
        assert(json[r'institution'] != null, 'Required key "PlaidMetadataDTO[institution]" has a null value in JSON.');
        assert(json.containsKey(r'accounts'), 'Required key "PlaidMetadataDTO[accounts]" is missing from JSON.');
        assert(json[r'accounts'] != null, 'Required key "PlaidMetadataDTO[accounts]" has a null value in JSON.');
        assert(json.containsKey(r'link_session_id'), 'Required key "PlaidMetadataDTO[link_session_id]" is missing from JSON.');
        assert(json[r'link_session_id'] != null, 'Required key "PlaidMetadataDTO[link_session_id]" has a null value in JSON.');
        return true;
      }());

      return PlaidMetadataDTO(
        institution: PlaidInstitutionDTO.fromJson(json[r'institution'])!,
        accounts: PlaidAccountDTO.listFromJson(json[r'accounts']),
        linkSessionId: mapValueOfType<String>(json, r'link_session_id')!,
      );
    }
    return null;
  }

  static List<PlaidMetadataDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlaidMetadataDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlaidMetadataDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlaidMetadataDTO> mapFromJson(dynamic json) {
    final map = <String, PlaidMetadataDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlaidMetadataDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlaidMetadataDTO-objects as value to a dart map
  static Map<String, List<PlaidMetadataDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlaidMetadataDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlaidMetadataDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'institution',
    'accounts',
    'link_session_id',
  };
}

