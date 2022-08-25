import 'package:encrypt/encrypt.dart';

String encrypt(String str, String keyStr) {
  final key = Key.fromUtf8(keyStr);
  final iv = IV.fromUtf8(keyStr.substring(0, 16));
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(str, iv: iv);
  return encrypted.base64;
}
