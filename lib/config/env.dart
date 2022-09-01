import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify(name: 'Secret')
abstract class Secret {
  static const server_url = _Secret.server_url;
  static const cipher_key = _Secret.cipher_key;
}
