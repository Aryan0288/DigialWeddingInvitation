import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

class ExportService {
  static Future<void> savePng(Uint8List bytes, String filename) async {
    final blob = html.Blob([bytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Cross-tab real-time update broadcaster using native BroadcastChannel
  static final _channel = html.BroadcastChannel('wedding_invitation_channel');

  static void broadcastUpdate(String invitationId) {
    try {
      _channel.postMessage(invitationId);
    } catch (_) {}
  }

  static Stream<String> listenForUpdates() {
    return _channel.onMessage.map((event) => event.data.toString());
  }

  static Future<String?> pickImage() async {
    final completer = Completer<String?>();
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          completer.complete(reader.result as String?);
        });
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}
