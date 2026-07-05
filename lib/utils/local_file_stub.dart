import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> savePickedImageLocally(XFile file) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('profile_avatar_path', file.path);
  return file.path;
}
