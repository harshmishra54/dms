import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class TokenDecryptor {
  static String decrypt(String encryptedBase64, {String password = "46@XT@PJ"}) {
    final encryptedBytes = base64.decode(encryptedBase64);

    // Check OpenSSL prefix
    final prefix = utf8.decode(encryptedBytes.sublist(0, 8));
    if (prefix != "Salted__") {
      throw Exception("Invalid OpenSSL encrypted format");
    }

    // Extract salt and ciphertext
    final salt = encryptedBytes.sublist(8, 16);
    final ciphertext = encryptedBytes.sublist(16);

    // Derive key and IV
    final keyIv = _evpBytesToKey(Utf8Encoder().convert(password), salt, 32, 16);
    final key = keyIv.sublist(0, 32);
    final iv = keyIv.sublist(32, 48);

    // Decrypt
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key(Uint8List.fromList(key)),
        mode: encrypt.AESMode.cbc,
        padding: 'PKCS7',
      ),
    );

    final decrypted = encrypter.decrypt(
      encrypt.Encrypted(Uint8List.fromList(ciphertext)),
      iv: encrypt.IV(Uint8List.fromList(iv)),
    );

    return decrypted;
  }

  /// Implements OpenSSL EVP_BytesToKey with MD5
  static List<int> _evpBytesToKey(
      List<int> password, List<int> salt, int keyLen, int ivLen) {
    final totalLen = keyLen + ivLen;
    List<int> derived = [];
    List<int> block = [];

    while (derived.length < totalLen) {
      var md5Input = <int>[];
      md5Input.addAll(block);
      md5Input.addAll(password);
      md5Input.addAll(salt);
      block = md5.convert(md5Input).bytes;
      derived.addAll(block);
    }

    return derived.sublist(0, totalLen);
  }
}
