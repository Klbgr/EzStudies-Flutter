import 'package:encrypt/encrypt.dart';

String encrypt(String str, String keyStr) {
  Key key = Key.fromUtf8(keyStr);
  IV iv = IV.fromUtf8(keyStr.substring(0, 16));
  Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  Encrypted encrypted = encrypter.encrypt(str, iv: iv);
  return encrypted.base64;
}

String decrypt(String str, String keyStr) {
  Key key = Key.fromUtf8(keyStr);
  IV iv = IV.fromUtf8(keyStr.substring(0, 16));
  Encrypter encryptor = Encrypter(AES(key, mode: AESMode.cbc));
  String decrypted = encryptor.decrypt64(str, iv: iv);
  return decrypted;
}
