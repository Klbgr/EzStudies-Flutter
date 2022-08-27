import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class Secret {
  static late String serverUrl;
  static late String cipherKey;

  static Future<void> load() async {
    await rootBundle.loadStructuredData<void>("secrets.json", (value) async {
      var data = json.decode(value);
      serverUrl = data["server_url"];
      cipherKey = data["cipher_key"];
    });
  }
}
