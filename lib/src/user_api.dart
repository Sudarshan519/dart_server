import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../spa_server.dart';

class UserApi {
  final DbCollection store;
  UserApi(
    this.store,
  );

  Handler get router {
    final router = Router();
    router.get('/', (Request req) async {
      final authDetails = req.context['authDetails'] as JWT;
      final user =
          await store.findOne(where.eq("_id", (authDetails.subject ?? "")));
      return Response.ok('{"user":"${user!['email']}"}',
          headers: {HttpHeaders.contentTypeHeader: ContentType.json});
    });
    final handler =
        Pipeline().addMiddleware(checkAuthorization()).addHandler(router);
    return handler;
  }
}
