import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

Future<String> savePickedImageLocally(XFile file) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = Uri.file(file.path).pathSegments.last;
  final savedFile = File('${appDir.path}/$fileName');
  await File(file.path).copy(savedFile.path);
  return savedFile.path;
}
