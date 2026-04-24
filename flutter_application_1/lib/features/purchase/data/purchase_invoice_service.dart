import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '/config/api.dart';
import '/services/secure_storage.dart';

class PurchaseInvoiceService {
  final Dio _dio = Dio();

  Future<File> downloadInvoice(int purchaseId) async {
    final token = await SecureStorage.getToken();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/purchase-$purchaseId.pdf";

    await _dio.download(
      "${Api.baseUrl}/api/purchases/invoice/$purchaseId",
      filePath,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        responseType: ResponseType.bytes,
      ),
    );

    return File(filePath);
  }

  Future<void> shareInvoice(int purchaseId) async {
    final file = await downloadInvoice(purchaseId);

    await Share.shareXFiles([XFile(file.path)],
        text: "Purchase Receipt #$purchaseId");
  }

  Future<void> shareViaWhatsApp(int purchaseId) async {
    final file = await downloadInvoice(purchaseId);

    final uri = Uri.parse(
        "whatsapp://send?text=Purchase Receipt PR-${purchaseId.toString().padLeft(6, '0')}");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Purchase Receipt PR-${purchaseId.toString().padLeft(6, '0')}",
    );
  }
}
