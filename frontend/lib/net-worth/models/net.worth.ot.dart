import 'package:flutter/material.dart';

/// Provides information for how net worth has progressed over time
class HistoricalNetWorth {
  double? last1Day;
  double? last7Days;
  double? last30Days;
  double? lastYear;
  Map<DateTime, double> historicalData;
  String? accountId;

  HistoricalNetWorth({
    required this.last1Day,
    required this.last7Days,
    required this.last30Days,
    required this.lastYear,
    required this.historicalData,
    this.accountId,
  });

  factory HistoricalNetWorth.fromJson(Map<String, dynamic> json) {
    Map<DateTime, double> parsedHistoricalData = {};
    if (json.containsKey('historicalData') && json['historicalData'] is Map) {
      (json['historicalData'] as Map).forEach((key, value) {
        try {
          parsedHistoricalData[DateTime.parse(key)] = value.toDouble();
        } catch (e) {
          debugPrint('Error parsing historical date $key: $e');
        }
      });
    }

    return HistoricalNetWorth(
      last1Day: json['last1Day']?.toDouble(),
      last7Days: json['last7Days']?.toDouble(),
      last30Days: json['last30Days']?.toDouble(),
      lastYear: json['lastYear']?.toDouble(),
      historicalData: parsedHistoricalData,
      accountId: json['accountId'],
    );
  }

  /// Returns the value by the given time frame as supported in the above properties
  double? getValueByFrame(String frame) {
    switch (frame) {
      case "last1Day":
        return last1Day;
      case "last7Days":
        return last7Days;
      case "last30Days":
        return last30Days;
      case "lastYear":
        return lastYear;
    }
    return null;
  }
}
