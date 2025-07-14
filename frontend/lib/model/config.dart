/// This class provides additional information to those who request but it is **not secured behind authentication requirements**
class UnsecureAppConfiguration {
  /// If this is the first time someone has connected to this interface
  final String firstTimeSetupPosition;

  /// Version of the backend
  final String version;

  UnsecureAppConfiguration({
    required this.firstTimeSetupPosition,
    required this.version,
  });

  factory UnsecureAppConfiguration.fromJson(Map<String, dynamic> json) {
    return UnsecureAppConfiguration(
      firstTimeSetupPosition: json['firstTimeSetupPosition'] as String,
      version: json['version'] as String,
    );
  }
}
