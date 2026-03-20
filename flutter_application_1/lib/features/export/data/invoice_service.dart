import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/config/api.dart';
import '../../../services/secure_storage.dart';

class InvoiceService {
  final Dio _dio = Dio();

  Future<File> downloadInvoice(int exportId) async {
    final token = await SecureStorage.getToken();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/invoice-$exportId.pdf";

    await _dio.download(
      "${Api.baseUrl}/api/exports/invoice/$exportId",
      filePath,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        responseType: ResponseType.bytes,
      ),
    );

    return File(filePath);
  }

  Future<void> shareInvoice(int exportId) async {
    final file = await downloadInvoice(exportId);

    await Share.shareXFiles([XFile(file.path)], text: "Invoice #$exportId");
  }
}
