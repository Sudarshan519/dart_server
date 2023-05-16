import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

Middleware handleCors() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE',
    'Access-Control-Allow-Headers': 'Origin,Content-Type'
  };
  return createMiddleware(requestHandler: (Request request) {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: corsHeaders);
    }
    return null;
  }, responseHandler: (Response response) {
    return response.change(headers: corsHeaders);
  });
}

String generateSalt([int length = 32]) {
  final rand = Random.secure();
  final saltBytes = List<int>.generate(length, (index) => rand.nextInt(256));
  return base64Encode(saltBytes);
}

String hashPassword(String password, String salt) {
  final codec = Utf8Codec();
  final key = codec.encode(password);
  final saltBytes = codec.encode(salt);
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(saltBytes);
  return digest.toString();
}

String generateJwt(String subject, String isuser, String secret) {
  final jwt = JWT({
    'int': DateTime.now().millisecondsSinceEpoch,
  }, subject: subject, issuer: isuser);
  return jwt.sign(SecretKey(secret));
}

dynamic verifyJwt(String token, String secret) {
  try {
    final jwt = JWT.verify(token, SecretKey(secret));
    return jwt;
  } on JWTExpiredError catch (e) {
    print(e);
  } on JWTError catch (error) {
    print(error);
  } catch (e) {
    print(e);
  }
}

Middleware handleAuth(String secret) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      var token, jwt;
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7);
        jwt = verifyJwt(token, secret);
      }
      final updateRequest = request.change(context: {'authDetails': jwt});
      return await innerHandler(updateRequest);
    };
  };
}

Middleware checkAuthorization() {
  return createMiddleware(requestHandler: (Request request) {
    if (request.context['authDetails'] == null) {
      return Response.forbidden('Not authorized to perform action');
    }
    return null;
  });
}
