import 'package:uuid/uuid.dart';

/// This class specifies the format of every REST request/response
class RestBody<PayloadType> {
  final PayloadType payload;
  final String requestId;
  final DateTime timestamp;
  RestBody(this.payload) : requestId = const Uuid().v4(), timestamp = DateTime.now();

  factory RestBody.fromJson(Map<String, dynamic> json, PayloadType Function(dynamic) fromJsonPayload) {
    return RestBody<PayloadType>._(
      payload: fromJsonPayload(json['payload']),
      requestId: json['requestId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  RestBody._({required this.payload, required this.requestId, required this.timestamp});
}

/// While very similar to a [RestBody], these add an additional "queue" so we can better identify where this data is going
class SSEBody<PayloadType> extends RestBody<PayloadType> {
  /// The queue of this SSE request so the frontend can direct it.
  final String queue;
  SSEBody(this.queue, PayloadType payload) : super(payload);

  factory SSEBody.fromJson(Map<String, dynamic> json) {
    return SSEBody<PayloadType>._(
      queue: json['queue'],
      payload: json['payload'],
      requestId: json['requestId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  SSEBody._({required this.queue, required PayloadType payload, required String requestId, required DateTime timestamp})
    : super._(payload: payload, requestId: requestId, timestamp: timestamp);
}
