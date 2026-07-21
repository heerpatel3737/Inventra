import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveAndOpenPdf(Uint8List bytes, String fileName) async {
  if (Platform.isAndroid) {
    const channel = MethodChannel('com.example.inventra/pdf_saver');
    try {
      final String? path = await channel.invokeMethod<String>('savePdf', {
        'bytes': bytes,
        'fileName': fileName,
      });
      if (path != null) {
        return path;
      } else {
        throw Exception('Failed to save PDF on Android');
      }
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  } else {
    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
