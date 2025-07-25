import 'package:flutter/material.dart';

/// This class represents a time frame of net worth change.
class NetWorthFrameData {
  final double? percentChange;
  final double valueChange;

  const NetWorthFrameData({required this.valueChange, this.percentChange});

  factory NetWorthFrameData.fromJson(Map<String, dynamic> json) {
    return NetWorthFrameData(
      valueChange: json['valueChange']?.toDouble(),
      percentChange: json['percentChange']?.toDouble(),
    );
  }
}

/// Provides information for how net worth has progressed over time
class HistoricalNetWorth {
  NetWorthFrameData last1Day;
  NetWorthFrameData last7Days;
  NetWorthFrameData last30Days;
  NetWorthFrameData lastYear;
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
      last1Day: NetWorthFrameData.fromJson(json['last1Day']),
      last7Days: NetWorthFrameData.fromJson(json['last7Days']),
      last30Days: NetWorthFrameData.fromJson(json['last30Days']),
      lastYear: NetWorthFrameData.fromJson(json['lastYear']),
      historicalData: parsedHistoricalData,
      accountId: json['accountId'],
    );
  }

  /// Returns the value by the given time frame as supported in the above properties
  NetWorthFrameData getValueByFrame(String frame) {
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
    throw Exception("Couldn't find matching net worth time frame");
  }
}
