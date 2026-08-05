import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final isDark = provider.isDarkMode;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final activeTransactions = provider.transactions.where((t) => t.status == 'Lunas').toList();

    final totalRevenue = activeTransactions.fold(
      0.0,
      (sum, trx) => sum + trx.total,
    );

    final recentTransactions = provider.transactions.take(5).toList();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            if (provider.storeProfile.logoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: provider.storeProfile.logoUrl.startsWith('http')
                      ? DecorationImage(image: NetworkImage(provider.storeProfile.logoUrl), fit: BoxFit.cover)
                      : DecorationImage(image: MemoryImage(base64Decode(provider.storeProfile.logoUrl)), fit: BoxFit.cover)
                  ),
                ),
              ),
            Expanded(
              child: Text(
                provider.storeProfile.name,
                style: TextStyle(color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.tr('reports'),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1)),
                    ),
                    Text(
                      provider.tr('summary_today'),
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : const Color(0xFF45464D)),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(Icons.picture_as_pdf, 'PDF', () => _simulateExport(context, 'PDF', provider), isDark),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.table_chart, 'Excel', () => _simulateExport(context, 'Excel', provider), isDark),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bento Grid - More Responsive
            LayoutBuilder(builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: width > 900 ? 3 : (width > 600 ? 2 : 1),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: width > 600 ? 1.8 : 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildBentoCard(
                    title: provider.tr('total_revenue'),
                    value: currencyFormatter.format(totalRevenue),
                    subtitle: provider.language == 'Indonesia' ? '+14.2% dari kemarin' : '+14.2% from yesterday',
                    icon: Icons.payments,
                    color: isDark ? const Color(0xFF0D47A1).withOpacity(0.1) : const Color(0xFFE3F2FD),
                    textColor: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                    isDark: isDark,
                  ),
                  _buildBentoCard(
                    title: provider.tr('total_transactions'),
                    value: '${activeTransactions.length} ${provider.language == 'Indonesia' ? 'Transaksi' : 'Transactions'}',
                    subtitle: '${provider.language == 'Indonesia' ? 'Rata-rata' : 'Average'} ${currencyFormatter.format(activeTransactions.isEmpty ? 0 : totalRevenue / activeTransactions.length)} / trx',
                    icon: Icons.receipt_long,
                    color: isDark ? const Color(0xFF0D47A1).withOpacity(0.1) : const Color(0xFFE3F2FD),
                    textColor: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                    isDark: isDark,
                  ),
                  _buildTopProductCard(provider, currencyFormatter),
                ],
              );
            }),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1)),
                    const SizedBox(width: 8),
                    Text(provider.tr('recent_transactions'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(provider.tr('see_all'), style: TextStyle(color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1), fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Recent Transactions Table Style
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              child: recentTransactions.isEmpty
                  ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(provider.language == 'Indonesia' ? 'Belum ada transaksi' : 'No transactions yet', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey))))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentTransactions.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final tx = recentTransactions[index];
                        final isRefunded = tx.status == 'Refund';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: isRefunded ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                            child: Icon(isRefunded ? Icons.undo : Icons.check_circle, color: isRefunded ? Colors.red : Colors.blue, size: 20),
                          ),
                          title: Text(tx.invoiceNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, decoration: isRefunded ? TextDecoration.lineThrough : null, color: isDark ? Colors.white : Colors.black87)),
                          subtitle: Text('${tx.timeString} • ${tx.paymentMethod}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
                          trailing: Text(currencyFormatter.format(tx.total), style: TextStyle(fontWeight: FontWeight.bold, color: isRefunded ? (isDark ? Colors.white10 : Colors.grey) : (isDark ? Colors.white : const Color(0xFF0D47A1)))),
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

  void _simulateExport(BuildContext context, String type, PosProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(type == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart, color: const Color(0xFF0D47A1)),
            const SizedBox(width: 12),
            Text('Export $type', style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87)),
          ],
        ),
        content: Text(
          provider.language == 'Indonesia'
            ? 'Laporan berhasil diekspor ke format $type. File tersimpan di folder Unduhan.'
            : 'Report successfully exported to $type format. File saved in Downloads folder.',
          style: TextStyle(color: provider.isDarkMode ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1))),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard({required String title, required String value, required String subtitle, required IconData icon, required Color color, required Color textColor, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.7)), overflow: TextOverflow.ellipsis)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: textColor, size: 20)),
            ],
          ),
          const Spacer(),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor))),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: isDark ? Colors.greenAccent : Colors.teal.shade700),
              const SizedBox(width: 4),
              Flexible(child: Text(subtitle, style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey.shade700, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductCard(PosProvider provider, NumberFormat currencyFormatter) {
    final isDark = provider.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12253C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(provider.tr('top_product'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.grey), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.star, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text('Latte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.image, color: isDark ? Colors.white24 : Colors.grey, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.language == 'Indonesia' ? 'Total Terjual' : 'Total Sold', style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey), overflow: TextOverflow.ellipsis),
                    Text('48 ${provider.language == 'Indonesia' ? 'porsi' : 'servings'}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700), overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
