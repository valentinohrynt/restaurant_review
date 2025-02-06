import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<File?> getImage(String imageUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = imageUrl.split('/').last;
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        return file;
      }

      final response = await Dio().download(imageUrl, filePath);

      if (response.statusCode == 200) {
        return file;
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
    return null;
  }
}
