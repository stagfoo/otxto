import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// Asks the user to pick a folder, returns null if they cancel.
Future<String?> pickDir() {
  return FilePicker.platform.getDirectoryPath();
}

List<File> getFilesFromFolder(String root) {
  return Directory(root).listSync().whereType<File>().toList();
}
