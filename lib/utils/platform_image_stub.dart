import 'package:flutter/widgets.dart';

Widget buildImageFromPath(String path) {
  return Image.network(path, fit: BoxFit.cover);
}
