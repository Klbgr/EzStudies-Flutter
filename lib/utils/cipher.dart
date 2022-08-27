import 'package:encrypt/encrypt.dart';

String encrypt(String str, String keyStr) {
  final key = Key.fromUtf8(keyStr);
  final iv = IV.fromUtf8(keyStr.substring(0, 16));
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(str, iv: iv);
  return encrypted.base64;
}

String decrypt(String str, String keyStr) {
  final key = Key.fromUtf8(keyStr);
  final iv = IV.fromUtf8(keyStr.substring(0, 16));
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt64(str, iv: iv);
  return decrypted;
}
