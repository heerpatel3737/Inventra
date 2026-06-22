import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> saveAndOpenPdf(Uint8List bytes, String fileName) async {
  Directory? dir;
  if (Platform.isAndroid || Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory();
  } else {
    dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
