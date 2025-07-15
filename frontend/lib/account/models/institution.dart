/// The institution that accounts may be part of
class Institution {
  final String id;
  final String url;
  final String name;
  final bool hasError;

  Institution({required this.id, required this.url, required this.name, required this.hasError});

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      hasError: json['hasError'] as bool,
    );
  }

  /// Converts this object to JSON object
  dynamic toJson() {
    return {'name': name, 'url': url, 'hasError': hasError};
  }
}
