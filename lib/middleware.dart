import 'package:file_picker/file_picker.dart';
import 'dart:io';

//return type   // name   // async
Future<String?> pickDir() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    throw Error();
  }
  return selectedDirectory;
}

Future<List> getDirs() async {
  try {
    var root = await FilePicker.platform.getDirectoryPath();
    if (root == null) {
      return [];
    }
    var list = [];
    List contents = Directory(root).listSync();
    for (var fileOrDir in contents) {
      if (fileOrDir is Directory) {
        list.add(fileOrDir);
      }
    }
    return list;
  } catch (err) {
    rethrow;
  }
}

Future<File> pickFile() async {
  try {
    var root = await FilePicker.platform.pickFiles();
    var firstFile = root!.files[0].path ?? '';
    return File(firstFile);
  } catch (err) {
    rethrow;
  }
}

Future<List> getFiles() async {
  try {
    var root = await FilePicker.platform.getDirectoryPath();
    var list = [];
    List contents = Directory(root!).listSync();
    for (var fileOrDir in contents) {
      if (fileOrDir is File) {
        list.add(fileOrDir);
      }
    }
    return list;
  } catch (err) {
    rethrow;
  }
}

Future<List<dynamic>> getFilesFromFolder(String root) async {
  try {
    var list = [];
    List<FileSystemEntity> contents = Directory(root).listSync();
    for (var fileOrDir in contents) {
      print(fileOrDir);
      if (fileOrDir is File) {
        list.add(fileOrDir);
      }
    }
    return list;
  } catch (err) {
    rethrow;
  }
}
