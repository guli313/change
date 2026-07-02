import 'dart:io';
import 'package:flutter/widgets.dart';

Widget buildImageFromPath(String path) {
  return Image.file(File(path), fit: BoxFit.cover);
}
