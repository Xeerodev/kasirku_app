import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/transaction.dart';
import '../models/store_profile.dart';

class PrinterService {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<bool> isConnected() async {
    return await bluetooth.isConnected ?? false;
  }

  Future<List<BluetoothDevice>> getDevices() async {
    return await bluetooth.getBondedDevices();
  }

  Future<String> printReceipt(TransactionModel trx, StoreProfile store) async {
    bool? connected = await bluetooth.isConnected;
    if (connected == null || !connected) {
      return "Printer belum terhubung via Bluetooth.";
    }

    try {
      // Receipt Printing Logic
      bluetooth.printCustom(store.name.toUpperCase(), 3, 1);
      bluetooth.printCustom(store.address, 1, 1);
      bluetooth.printCustom(store.phone, 1, 1);
      bluetooth.printNewLine();
      bluetooth.printLeftRight("No: ", trx.invoiceNumber, 1);
      bluetooth.printLeftRight("Kasir: ", trx.cashierName, 1);
      bluetooth.printNewLine();

      for (var item in trx.items) {
        bluetooth.printCustom(item.product.name, 1, 0);
        bluetooth.printLeftRight("${item.quantity} x ${item.product.price}", item.subtotal.toString(), 1);
      }

      bluetooth.printNewLine();
      bluetooth.printLeftRight("TOTAL", trx.total.toString(), 2);
      bluetooth.printCustom("Terima Kasih", 1, 1);
      bluetooth.paperCut();

      return "Berhasil mencetak struk.";
    } catch (e) {
      return "Gagal mencetak: $e";
    }
  }
}
