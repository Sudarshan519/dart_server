import 'package:spa_server/spa_server.dart';
import 'package:path/path.dart' as p;

class StaticAssetsApi {
  final folderPath;
  StaticAssetsApi(this.folderPath);

  Router get router {
    final router = Router();
    router.get('/<file|.*>', (Request request) async {
      final assetPath =
          p.join(folderPath, request.requestedUri.path.substring(1));
      return await createFileHandler(assetPath)(request);
    });
    return router;
  }
}
