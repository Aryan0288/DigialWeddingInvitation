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
}
