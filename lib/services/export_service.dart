import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<String?> exportToPdf(List<TransactionModel> transactions, String storeName, String lang) async {
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      final pdf = pw.Document();
      final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text(lang == 'Indonesia' ? "Laporan Penjualan $storeName" : "$storeName Sales Report")),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: lang == 'Indonesia'
                ? ['No. Faktur', 'Waktu', 'Metode', 'Total', 'Status']
                : ['Invoice No.', 'Time', 'Method', 'Total', 'Status'],
              data: transactions.map((t) => [
                t.invoiceNumber,
                t.timeString,
                t.paymentMethod,
                currencyFormatter.format(t.total),
                t.status,
              ]).toList(),
            ),
          ],
        ),
      );

      final output = await _getAppFolder();
      final file = File("${output.path}/Laporan_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> exportToExcel(List<TransactionModel> transactions, String storeName, String lang) async {
    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
      }

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      sheetObject.appendRow(lang == 'Indonesia'
        ? ['No. Faktur', 'Waktu', 'Metode', 'Total', 'Status']
        : ['Invoice No.', 'Time', 'Method', 'Total', 'Status']);

      for (var t in transactions) {
        sheetObject.appendRow([t.invoiceNumber, t.timeString, t.paymentMethod, t.total, t.status]);
      }

      final output = await _getAppFolder();
      final filePath = "${output.path}/Laporan_${DateTime.now().millisecondsSinceEpoch}.xlsx";

      var fileBytes = excel.save();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Directory> _getAppFolder() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final path = Directory("${directory.path}/Kasirku");
    if (!await path.exists()) {
      await path.create(recursive: true);
    }
    return path;
  }
}
