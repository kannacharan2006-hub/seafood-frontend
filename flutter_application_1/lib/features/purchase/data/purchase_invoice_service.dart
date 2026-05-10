import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/config/api.dart';
import '/services/secure_storage.dart';

class PurchaseInvoiceService {
  Future<File> downloadInvoice(int purchaseId) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse("${Api.baseUrl}/api/purchases/invoice/$purchaseId");
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/purchase-$purchaseId.pdf";

    final response = await http.get(uri, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode != 200) {
      final msg = response.body.isNotEmpty && !response.body.startsWith('<!')
          ? response.body
          : 'Server returned ${response.statusCode}';
      throw Exception(msg);
    }

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> shareInvoice(int purchaseId) async {
    final file = await downloadInvoice(purchaseId);
    await Share.shareXFiles([XFile(file.path)],
        text: "Purchase Receipt #$purchaseId");
  }

  Future<void> shareViaWhatsApp(int purchaseId) async {
    final file = await downloadInvoice(purchaseId);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Purchase Receipt PR-${purchaseId.toString().padLeft(6, '0')}",
    );
  }
}
