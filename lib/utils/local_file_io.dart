import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> savePickedImageLocally(XFile file) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = file.name.isNotEmpty
      ? file.name
      : Uri.file(file.path).pathSegments.last;
  final savedFile = File('${appDir.path}/$fileName');
  await File(file.path).copy(savedFile.path);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('profile_avatar_path', savedFile.path);

  return savedFile.path;
}
