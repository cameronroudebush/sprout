/// This class represents a finance provider and some metadata on their connection
class FinanceProviderConfig {
  /// The name of this provider
  final String name;

  /// An endpoint of where to get this logo
  final String logoUrl;

  /// The URL to be able to fix accounts
  final String? accountFixUrl;

  FinanceProviderConfig({required this.name, required this.logoUrl, this.accountFixUrl});

  factory FinanceProviderConfig.fromJson(Map<String, dynamic> json) {
    return FinanceProviderConfig(name: json['name'], logoUrl: json['logoUrl'], accountFixUrl: json['accountFixUrl']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'logoUrl': logoUrl, 'accountFixUrl': accountFixUrl};
  }
}
