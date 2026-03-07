import 'package:http/http.dart';

/// A dummy client for development so mobile doesn't fail to load the proper client
class BrowserClient extends BaseClient {
  bool withCredentials = false;
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return StreamedResponse(Stream.empty(), 404);
  }
}
