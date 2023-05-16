import 'package:spa_server/spa_server.dart';

void main(List<String> arguments) async {
  final db = Db(Env.mongoUrl);
  await db.open();
  print('connected to database');
  final store = db.collection('users');
  final app = Router();
  app.mount('/assets', StaticAssetsApi('public').router);
  app.mount('/auth/', AuthApi(store, Env.secretKey).router);
  app.mount('/users/', UserApi(store).router);
  app.get('/assets/<file|.*>', createStaticHandler('public'));
  app.get('/<name|.*>', (Request request, String name) {
    final indexFile = File('public/index.html').readAsStringSync();
    return Response.ok(indexFile, headers: {'content-type': 'text/html'});
    // return Response.ok('My Single Page App');
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addMiddleware(handleAuth(Env.secretKey))
      .addHandler(app);
  await serve(handler, 'localhost', 8080);
  // print('Hello world: ${spa_server.calculate()}!');
}
