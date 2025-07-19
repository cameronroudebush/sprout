/// Defines a sync schedule job. Used purely for visibility on how the jobs are doing
class Sync {
  final DateTime? time;
  final String status;
  final String? failureReason;

  Sync({required this.time, required this.status, this.failureReason});

  factory Sync.fromJson(Map<String, dynamic> json) {
    return Sync(
      time: DateTime.parse(json['time']),
      status: json['status'] as String,
      failureReason: json['failureReason'] as String?,
    );
  }
}
