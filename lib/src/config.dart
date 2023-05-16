import 'package:envied/envied.dart';
part 'config.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'SECRET_KEY')
  static const secretKey = _Env.secretKey;
  @EnviedField(varName: 'MONGO_URL')
  static const mongoUrl = _Env.mongoUrl;
}
