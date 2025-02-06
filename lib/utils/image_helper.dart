import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static final _dio = Dio();
  static const _maxCacheAge = Duration(days: 30); 

  static Future<File?> getImage(String imageUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _generateFileName(imageUrl);
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      final metadata = File('${filePath}_metadata');

      if (await file.exists()) {
        if (await _isCacheValid(metadata)) {
          return file;
        } else {
          await file.delete();
          await metadata.delete();
        }
      }

      final response = await _dio.download(imageUrl, filePath);

      if (response.statusCode == 200) {

        await metadata.writeAsString(DateTime.now().toIso8601String());
        return file;
      }
    } catch (e) {
      print("Error handling image: $e");
    }
    return null;
  }

  static String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<bool> _isCacheValid(File metadata) async {
    try {
      if (await metadata.exists()) {
        final savedDate = DateTime.parse(await metadata.readAsString());
        final age = DateTime.now().difference(savedDate);
        return age < _maxCacheAge;
      }
    } catch (e) {
      print("Error checking cache validity: $e");
    }
    return false;
  }

  static Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      for (var file in files) {
        if (file is File && !file.path.endsWith('_metadata')) {
          await file.delete();
          final metadata = File('${file.path}_metadata');
          if (await metadata.exists()) {
            await metadata.delete();
          }
        }
      }
    } catch (e) {
      print("Error clearing cache: $e");
    }
  }
}