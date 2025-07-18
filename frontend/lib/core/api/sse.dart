import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprout/core/api/base.dart';

class SSEAPI extends BaseAPI {
  SSEAPI(super.client);

  /// Builds the SSE stream to the backend and returns it. You can then listen to the return of JSON on that stream.
  Stream<Map<String, dynamic>> buildSSE() async* {
    final url = Uri.parse('${client.apiUrl}/sse');
    final request = http.Request('GET', url);
    request.headers.addAll(await client.getSendHeaders());

    final response = await request.send();

    if (response.statusCode == 200) {
      try {
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (var line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              yield json.decode(data);
            }
          }
        }
      } catch (e) {
        throw Exception('SSE stream disconnected: $e');
      }
    } else {
      throw Exception('Failed to connect to SSE endpoint $url: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
