
import 'dart:typed_data';

class UploadableFile {
  final String fileName;
  final Uint8List bytes;
  // Opcional: El tipo MIME o extensión
  final String? extension; 

  UploadableFile({required this.fileName, required this.bytes, this.extension});
}