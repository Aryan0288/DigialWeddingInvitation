import 'dart:typed_data';
import 'dart:async';

class ExportService {
  static Future<void> savePng(Uint8List bytes, String filename) async {
    // Native mobile fallback (saving to gallery is supported in production,
    // here we provide a safe compilation fallback).
    print("Mobile Png export: $filename - bytes length: ${bytes.length}");
  }

  static void broadcastUpdate(String invitationId) {}
  static Stream<String> listenForUpdates() => const Stream.empty();
}
