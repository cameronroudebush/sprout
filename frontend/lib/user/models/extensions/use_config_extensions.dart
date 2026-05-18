import 'package:sprout/api/api.dart';

/// Helper functions for user config
extension UserConfigExtensions on UserConfig {
  /// Clones the current configuration
  UserConfig copyWith(
      {String? id,
      ChartRangeEnum? netWorthRange,
      ThemeStyleEnum? themeStyle,
      bool? privateMode,
      bool? secureMode,
      bool? allowWidgets,
      CurrencyOptionsEnum? currency,
      EmailUpdateFrequencyEnum? emailUpdateFrequency,
      String? simpleFinToken,
      String? geminiKey}) {
    return UserConfig(
        id: id ?? this.id,
        netWorthRange: netWorthRange ?? this.netWorthRange,
        themeStyle: themeStyle ?? this.themeStyle,
        privateMode: privateMode ?? this.privateMode,
        secureMode: secureMode ?? this.secureMode,
        allowWidgets: allowWidgets ?? this.allowWidgets,
        currency: currency ?? this.currency,
        emailUpdateFrequency: emailUpdateFrequency ?? this.emailUpdateFrequency,
        simpleFinToken: simpleFinToken ?? this.simpleFinToken,
        geminiKey: geminiKey ?? this.geminiKey);
  }
}
