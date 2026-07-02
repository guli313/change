import 'package:image_picker/image_picker.dart';

Future<String> savePickedImageLocally(XFile file) async {
  return file.path;
}
