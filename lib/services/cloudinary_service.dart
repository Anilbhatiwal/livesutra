import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "mxbtvwdp";
  static const String uploadPreset = "livesutra_upload";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      var request = http.MultipartRequest(
        "POST",
        uri,
      );

      request.fields["upload_preset"] = uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData =
            await response.stream.bytesToString();

        final jsonData = json.decode(responseData);

        return jsonData["secure_url"];
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}