/// Defines a sync schedule job. Used purely for visibility on how the jobs are doing
class Schedule {
  final DateTime? time;
  final String status;
  final String? failureReason;

  Schedule({required this.time, required this.status, this.failureReason});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      time: DateTime.parse(json['time']),
      status: json['status'] as String,
      failureReason: json['failureReason'] as String?,
    );
  }
}
