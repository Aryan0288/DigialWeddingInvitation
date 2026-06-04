import 'dart:typed_data';
import 'dart:async';

abstract class ExportService {
  static Future<void> savePng(Uint8List bytes, String filename) {
    throw UnimplementedError('Platform not supported');
  }

  static void broadcastUpdate(String invitationId) {}
  static Stream<String> listenForUpdates() => const Stream.empty();
  
  static Future<String?> pickImage() async {
    throw UnimplementedError('Platform not supported');
  }
}
