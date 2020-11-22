import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    print(directory.path);
    return directory.path;
  }

  Future<File> _localFile(String name) async {
    final path = await _localPath;
    return File('$path/$name');
  }

  Future<File> writeContent(double d) async {
    final file = await _localFile('max');
    // Write the file
    if (d == null) return file;
    return file.writeAsString(d.toStringAsFixed(1));
  }

  Future<double> readcontent() async {
    try {
      final file = await _localFile('max');
      // Read the file
      String contents = await file.readAsString();
      return double.parse(contents);
    } catch (e) {
      // If there is an error reading, return a default String
      print(e);
      return -1;
    }
  }
}
