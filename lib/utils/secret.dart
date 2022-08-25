import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class Secret {
  final String serverUrl;
  final String cipherKey;

  Secret({this.serverUrl = "", this.cipherKey = ""});

  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(
        serverUrl: jsonMap["server_url"], cipherKey: jsonMap["cipher_key"]);
  }
}

class SecretLoader {
  SecretLoader();

  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>("secrets.json", (value) async {
      final secret = Secret.fromJson(json.decode(value));
      return secret;
    });
  }
}
