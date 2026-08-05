import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pos_provider.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final isDark = provider.isDarkMode;
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
      backgroundColor: isDark ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.history, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.tr('history'),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1)),
                      ),
                      Text(
                        provider.language == 'Indonesia' ? 'Daftar seluruh transaksi penjualan toko' : 'List of all store sales transactions',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF45464D))
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: provider.language == 'Indonesia' ? 'Cari no. faktur atau metode...' : 'Search invoice no. or method...',
                  hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white38 : Colors.grey), onPressed: () => setState(() => _searchQuery = '')) : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: filteredTransactions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: isDark ? Colors.white10 : Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              provider.language == 'Indonesia' ? 'Belum ada riwayat transaksi' : 'No transaction history yet',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
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
                                          Flexible(
                                            child: Text(
                                              tx.invoiceNumber,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1), decoration: isRefunded ? TextDecoration.lineThrough : null),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isRefunded ? const Color(0xFFBA1A1A).withOpacity(0.1) : const Color(0xFFE3F2FD),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              isRefunded ? provider.tr('refund') : provider.tr('paid'),
                                              style: TextStyle(color: isRefunded ? (isDark ? Colors.redAccent : const Color(0xFF93000A)) : const Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 9)
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${tx.timeString} • ${tx.items.length} item (${tx.paymentMethod}) • ${provider.language == 'Indonesia' ? 'Kasir' : 'Cashier'}: ${tx.cashierName}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currencyFormatter.format(tx.total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isRefunded ? (isDark ? Colors.white10 : Colors.grey) : (isDark ? Colors.white : Colors.black87))),
                                    Row(
                                      children: [
                                        Text(provider.language == 'Indonesia' ? 'Klik detail' : 'See detail', style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey)),
                                        Icon(Icons.chevron_right, size: 14, color: isDark ? Colors.white38 : Colors.grey),
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isDark = provider.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF12253C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 450),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      provider.tr('invoice_detail'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Paper Receipt Simulation
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Text(provider.storeProfile.name.toUpperCase(), style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                            Text(provider.storeProfile.address, style: GoogleFonts.sourceCodePro(fontSize: 8, color: Colors.grey), textAlign: TextAlign.center),
                            const Divider(height: 24, thickness: 1, color: Colors.black12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: Text('No: ${tx.invoiceNumber}', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black))),
                                      Text(tx.status, style: GoogleFonts.sourceCodePro(fontSize: 9, fontWeight: FontWeight.bold, color: tx.status == 'Refund' ? Colors.red : Colors.green))
                                    ]
                                  ),
                                  Text('${provider.language == 'Indonesia' ? 'Kasir' : 'Cashier'}: ${tx.cashierName}', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black)),
                                  Text('${provider.language == 'Indonesia' ? 'Waktu' : 'Time'}: ${tx.timeString}', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black)),
                                  Text('${provider.language == 'Indonesia' ? 'Metode' : 'Method'}: ${tx.paymentMethod}', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black)),
                                ],
                              ),
                            ),
                            const Divider(height: 24, thickness: 1, color: Colors.black12),
                            ...tx.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(item.product.name, style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                                      Text(currencyFormatter.format(item.subtotal), style: GoogleFonts.sourceCodePro(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                    ],
                                  ),
                                  Text('   ${item.quantity} x ${currencyFormatter.format(item.product.price).replaceAll('Rp ', '')}', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54)),
                                ],
                              ),
                            )),
                            const Divider(height: 24, thickness: 1, color: Colors.black12),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TOTAL', style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)), Text(currencyFormatter.format(tx.total), style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black))]),
                            if (tx.paymentMethod == 'Tunai' || tx.paymentMethod == 'Cash') ...[
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(provider.language == 'Indonesia' ? 'TUNAI' : 'CASH', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54)), Text(currencyFormatter.format(tx.paymentAmount), style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54))]),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(provider.language == 'Indonesia' ? 'KEMBALI' : 'CHANGE', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54)), Text(currencyFormatter.format(tx.changeAmount), style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54))]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.language == 'Indonesia' ? 'Mencetak struk...' : 'Printing receipt...'), behavior: SnackBarBehavior.floating));
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: Text(provider.tr('print'), style: const TextStyle(fontSize: 12)),
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
                        label: Text(provider.tr('refund'), style: const TextStyle(fontSize: 12)),
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
    );
  }
}
