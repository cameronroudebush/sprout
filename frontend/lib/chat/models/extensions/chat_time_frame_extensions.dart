import 'package:sprout/api/api.dart';

/// Extension to add UI properties directly to the generated OpenAPI enum
extension ChatTimeframeUI on ChatRequestDTOTimeframeEnum {
  String get label {
    switch (this) {
      case ChatRequestDTOTimeframeEnum.sixMonths:
        return '6M';
      case ChatRequestDTOTimeframeEnum.oneYear:
        return '1Y';
      case ChatRequestDTOTimeframeEnum.threeMonths:
      default:
        return '3M';
    }
  }

  String get longLabel {
    switch (this) {
      case ChatRequestDTOTimeframeEnum.sixMonths:
        return '6 Months';
      case ChatRequestDTOTimeframeEnum.oneYear:
        return '1 Year';
      case ChatRequestDTOTimeframeEnum.threeMonths:
      default:
        return '3 Months';
    }
  }

  String get description {
    switch (this) {
      case ChatRequestDTOTimeframeEnum.sixMonths:
        return 'Past 6 months of financial history';
      case ChatRequestDTOTimeframeEnum.oneYear:
        return 'Past year of financial history';
      case ChatRequestDTOTimeframeEnum.threeMonths:
      default:
        return 'Past 3 months (Default balance window)';
    }
  }
}
