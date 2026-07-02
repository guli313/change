import 'dart:io';

Future<String> saveXFileToAppDir(String path, String fileName) async {
  final savedFile = File(path);
  return savedFile.path;
}
