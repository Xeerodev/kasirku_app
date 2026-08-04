import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final filteredTransactions = provider.transactions.where((tx) {
      return tx.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.paymentMethod.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.status.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.history, color: Color(0xFF0D47A1)),
            SizedBox(width: 8),
            Text('Riwayat Transaksi', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar seluruh transaksi penjualan toko', style: TextStyle(fontSize: 12, color: Color(0xFF45464D))),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Cari no. faktur atau metode...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: filteredTransactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Belum ada riwayat transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredTransactions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final isRefunded = tx.status == 'Refund';

                          return ListTile(
                            onTap: () => _showTransactionDetail(context, tx, provider),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            title: Row(
                              children: [
                                Text(tx.invoiceNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0D47A1), decoration: isRefunded ? TextDecoration.lineThrough : null)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isRefunded ? Colors.red.shade50 : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(tx.status, style: TextStyle(color: isRefunded ? Colors.red : Colors.blue, fontWeight: FontWeight.bold, fontSize: 9)),
                                ),
                              ],
                            ),
                            subtitle: Text('${tx.timeString} • ${tx.items.length} item (${tx.paymentMethod})', style: const TextStyle(fontSize: 11)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyFormatter.format(tx.total), style: TextStyle(fontWeight: FontWeight.bold, color: isRefunded ? Colors.grey : Colors.black87)),
                                    const Text('Klik detail', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionModel tx, PosProvider provider) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detail Faktur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(tx.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)), Text(tx.status, style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold))]),
              const SizedBox(height: 4),
              Text('Kasir: ${tx.cashierName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Waktu: ${tx.timeString} | Pembayaran: ${tx.paymentMethod}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('Rincian Item:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tx.items.length,
                  itemBuilder: (context, i) {
                    final item = tx.items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.product.name}', style: const TextStyle(fontSize: 12)),
                          Text(currencyFormatter.format(item.subtotal), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 32, thickness: 1, color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(currencyFormatter.format(tx.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1))),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () {},
                      child: const Text('Cetak Struk', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  if (tx.status == 'Lunas') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        onPressed: () {
                          provider.toggleRefund(tx.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Refund', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
