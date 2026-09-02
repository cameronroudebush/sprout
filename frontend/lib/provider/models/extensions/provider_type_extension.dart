import 'package:sprout/api/api.dart';

extension ProviderTypeExtension on ProviderTypeEnum {
  /// Whether this provider links directly immediately upon selection without requiring account selection UI.
  bool get isDirectLinking {
    switch (this) {
      case ProviderTypeEnum.coinbase:
        return true;
      default:
        return false;
    }
  }
}
