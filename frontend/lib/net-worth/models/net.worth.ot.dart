import 'package:flutter/material.dart';

/// Provides information for how net worth has progressed over time
class HistoricalNetWorth {
  double last7Days;
  double last30Days;
  double lastYear;
  Map<DateTime, double> historicalData;

  HistoricalNetWorth({
    required this.last7Days,
    required this.last30Days,
    required this.lastYear,
    required this.historicalData,
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
      last7Days: json['last7Days'].toDouble(),
      last30Days: json['last30Days'].toDouble(),
      lastYear: json['lastYear'].toDouble(),
      historicalData: parsedHistoricalData,
    );
  }
}
