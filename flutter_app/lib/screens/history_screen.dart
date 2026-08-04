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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF0D47A1), size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: provider.isDarkMode ? Colors.skyAccent : const Color(0xFF0D47A1)),
                    ),
                    const Text('Daftar seluruh transaksi penjualan toko', style: TextStyle(fontSize: 12, color: Color(0xFF45464D))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari no. faktur atau metode...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _searchQuery = '')) : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List
            Container(
              decoration: BoxDecoration(
                color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: filteredTransactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Belum ada riwayat transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        final isRefunded = tx.status == 'Refund';

                        return InkWell(
                          onTap: () => _showTransactionDetail(context, tx, provider),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(tx.invoiceNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0D47A1), decoration: isRefunded ? TextDecoration.lineThrough : null)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isRefunded ? const Color(0xFFFFDAD6) : const Color(0xFFE3F2FD),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(tx.status, style: TextStyle(color: isRefunded ? const Color(0xFF93000A) : const Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 9)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${tx.timeString} • ${tx.items.length} item (${tx.paymentMethod}) • Kasir: ${tx.cashierName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyFormatter.format(tx.total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isRefunded ? Colors.grey : Colors.black87)),
                                    const Row(
                                      children: [
                                        Text('Klik detail', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                        Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 40),
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
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),

                // Paper Receipt Simulation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
                  child: Column(
                    children: [
                      Text(provider.storeProfile.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                      Text(provider.storeProfile.address, style: const TextStyle(fontSize: 8, color: Colors.grey), textAlign: TextAlign.center),
                      const Divider(height: 24, thickness: 1, color: Colors.black12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('No: ${tx.invoiceNumber}', style: const TextStyle(fontSize: 9, color: Colors.black87)), Text(tx.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tx.status == 'Refund' ? Colors.red : Colors.green))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Kasir: ${tx.cashierName}', style: const TextStyle(fontSize: 9, color: Colors.black87)), Text(tx.timeString, style: const TextStyle(fontSize: 9, color: Colors.black87))]),
                      const Divider(height: 24, thickness: 1, color: Colors.black12),
                      ...tx.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.quantity}x ${item.product.name}', style: const TextStyle(fontSize: 9, color: Colors.black87))),
                            Text(currencyFormatter.format(item.subtotal), style: const TextStyle(fontSize: 9, color: Colors.black87)),
                          ],
                        ),
                      )),
                      const Divider(height: 24, thickness: 1, color: Colors.black12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black87)), Text(currencyFormatter.format(tx.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black87))]),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak struk...')));
                        },
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Cetak Struk', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(44)),
                      ),
                    ),
                    if (tx.status == 'Lunas') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.toggleRefund(tx.id);
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.assignment_return, size: 16),
                          label: const Text('Refund', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(44)),
                        ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
