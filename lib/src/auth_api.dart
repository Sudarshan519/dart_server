import 'dart:convert';

import '../spa_server.dart';

class AuthApi {
  DbCollection store;
  String secret;
  AuthApi(this.store, this.secret);
  Router get router {
    final router = Router();
    router.post('/register/', (Request req) async {
      final payload = await req.readAsString();
      final userInfo = jsonDecode(payload);
      print(userInfo['email']);
      final email = userInfo['email'];
      final password = userInfo['password'];
      if (email == null ||
          password == null ||
          password.isEmpty ||
          email.isEmpty) {
        return Response.badRequest(
            body: 'Please provide your email and password');
      }
      final user = await store.findOne(where.eq('email', email));
      if (user != null) {
        return Response.badRequest(body: 'User already exists.');
      }
      final salt = generateSalt();
      final hashedPassword = hashPassword(password, salt);
      await store.insertOne(
          {'email': email, 'password': hashedPassword, 'salt': salt});
      return Response.ok('User registered');
    });
    router.post('/login/', (Request req) async {
      final payload = await req.readAsString();
      final userInfo = jsonDecode(payload);
      print(userInfo['email']);
      final email = userInfo['email'];
      final password = userInfo['password'];
      if (email == null ||
          password == null ||
          password.isEmpty ||
          email.isEmpty) {
        return Response.badRequest(
            body: 'Please provide your email and password');
      }
      final user = await store.findOne(where.eq('email', email));
      if (user == null) {
        return Response.badRequest(body: 'Incorrect Username or password.');
      }
      final userId = (user['_id'] as ObjectId).toString();
      final token = generateJwt(userId, 'http://localhost', secret);

      return Response.ok(jsonEncode({"token": token}),
          headers: {HttpHeaders.contentTypeHeader: ContentType.json.mimeType});
    });
    router.post('/logout/', (Request request) async {
      if (request.context['authDetails'] == null) {
        return Response.forbidden('Not authorized to perform this action.');
      }
      return Response.ok('Successfully logged out');
    });
    return router;
  }
}
