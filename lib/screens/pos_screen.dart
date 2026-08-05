import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import '../models/transaction.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Kopi',
    'Kue',
    'Merchandise',
    'Biji Kopi',
    'Minuman'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final filteredProducts = provider.products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Semua' || product.category == _selectedCategory;
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
            decoration: BoxDecoration(
              color: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
              border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.point_of_sale, color: Color(0xFF0D47A1), size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Kasir',
                          style: TextStyle(
                            color: provider.isDarkMode ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    if (provider.storeProfile.logoUrl.isNotEmpty)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.withOpacity(0.4)),
                          image: DecorationImage(image: NetworkImage(provider.storeProfile.logoUrl), fit: BoxFit.cover),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.blue.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.store, color: Color(0xFF0D47A1)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: provider.isDarkMode ? const Color(0xFF12253C) : const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: TextStyle(color: provider.isDarkMode ? Colors.grey : const Color(0xFF45464D), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF76777D)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Category Scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D47A1) : (provider.isDarkMode ? const Color(0xFF12253C) : const Color(0xFFEFF4FF)),
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected ? null : Border.all(color: Colors.black.withOpacity(0.1)),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : (provider.isDarkMode ? Colors.white70 : const Color(0xFF45464D)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product, provider, currencyFormatter);
                    },
                  ),
          ),
        ],
      ),

      // Floating Cart Bar
      floatingActionButton: provider.cart.isEmpty ? null : _buildFloatingCartBar(provider, currencyFormatter),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 8),
          const Text('Produk tidak ditemukan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text('Coba cari kata kunci lain.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, PosProvider provider, NumberFormat formatter) {
    final cartItem = provider.cart.firstWhere((item) => item.product.id == product.id, orElse: () => CartItem(product: product, quantity: 0));
    final qty = cartItem.quantity;
    final isOutOfStock = product.stock == 0;

    return Container(
      decoration: BoxDecoration(
        color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: product.image.isNotEmpty ? DecorationImage(image: NetworkImage(product.image), fit: BoxFit.cover) : null,
                  ),
                  child: product.image.isEmpty ? const Icon(Icons.local_cafe, size: 40, color: Colors.grey) : null,
                ),
                if (isOutOfStock)
                  Container(
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFBA1A1A), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Habis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info Area
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (!isOutOfStock)
                    Text('Stok: ${product.stock}', style: const TextStyle(color: Color(0xFF006C49), fontWeight: FontWeight.bold, fontSize: 10)),
                  const Spacer(),
                  Text(formatter.format(product.price), style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControlBtn(
                        icon: Icons.remove,
                        onTap: qty > 0 ? () => provider.removeFromCart(product) : null,
                        isActive: qty > 0,
                        isSecondary: true,
                      ),
                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      _buildControlBtn(
                        icon: Icons.add,
                        onTap: (!isOutOfStock && qty < product.stock) ? () => provider.addToCart(product) : null,
                        isActive: !isOutOfStock && qty < product.stock,
                        isSecondary: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, VoidCallback? onTap, required bool isActive, required bool isSecondary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? (isSecondary ? const Color(0xFF6CF8BB) : const Color(0xFF0D47A1)) : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: isActive ? (isSecondary ? const Color(0xFF00714D) : Colors.white) : Colors.grey),
      ),
    );
  }

  Widget _buildFloatingCartBar(PosProvider provider, NumberFormat formatter) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCartBottomSheet(context, provider),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
                      child: Text('${provider.cartTotalItems}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    const Text('Lihat Keranjang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    Text(formatter.format(provider.cartTotal), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context, PosProvider provider) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: provider.isDarkMode ? const Color(0xFF0B1C30) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Keranjang Belanja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () { provider.clearCart(); Navigator.pop(context); },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Kosongkan', style: TextStyle(color: Colors.red)),
                )
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: provider.cart.length,
                itemBuilder: (context, i) {
                  final item = provider.cart[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        image: item.product.image.isNotEmpty ? DecorationImage(image: NetworkImage(item.product.image), fit: BoxFit.cover) : null,
                      ),
                      child: item.product.image.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
                    ),
                    title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(formatter.format(item.product.price), style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildControlBtn(icon: Icons.remove, onTap: () => provider.removeFromCart(item.product), isActive: true, isSecondary: true),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        _buildControlBtn(icon: Icons.add, onTap: item.quantity < item.product.stock ? () => provider.addToCart(item.product) : null, isActive: item.quantity < item.product.stock, isSecondary: false),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            _buildPriceRow('Subtotal', formatter.format(provider.cartSubtotal)),
            _buildPriceRow('Pajak (0%)', formatter.format(0)),
            const SizedBox(height: 8),
            _buildPriceRow('Total Bayar', formatter.format(provider.cartTotal), isTotal: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                 Navigator.pop(context);
                 _showPaymentFlow(context, provider);
              },
              child: const Text('PROSES PEMBAYARAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xFF0D47A1) : null)),
      ],
    );
  }

  // Improved Payment Flow matching React's PaymentModal
  void _showPaymentFlow(BuildContext context, PosProvider provider) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    String paymentMethod = 'Tunai';
    double cashAmount = provider.cartTotal;
    final cashController = TextEditingController(text: cashAmount.toInt().toString());
    String? proofPhotoBase64;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          double change = (cashAmount - provider.cartTotal).clamp(0, double.infinity);
          final quickMoneyOptions = [
            provider.cartTotal,
            (provider.cartTotal / 10000).ceil() * 10000,
            (provider.cartTotal / 50000).ceil() * 50000,
            100000,
            200000,
            500000
          ].where((v) => v >= provider.cartTotal).toSet().toList().take(4).toList();

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 450),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Pilih metode pembayaran transaksi', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          // Total Bill Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3))),
                            child: Column(
                              children: [
                                const Text('Total Tagihan (Tanpa Pajak)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                                Text(currencyFormatter.format(provider.cartTotal), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Method Selection
                          const Align(alignment: Alignment.centerLeft, child: Text('Metode Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMethodBtn('Tunai', Icons.payments, paymentMethod, (val) => setDialogState(() => paymentMethod = val)),
                              const SizedBox(width: 8),
                              _buildMethodBtn('QRIS', Icons.qr_code_scanner, paymentMethod, (val) => setDialogState(() => paymentMethod = val)),
                              const SizedBox(width: 8),
                              _buildMethodBtn('Kartu', Icons.credit_card, paymentMethod, (val) => setDialogState(() => paymentMethod = val)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (paymentMethod == 'Tunai') ...[
                            TextField(
                              controller: cashController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Uang Diterima', prefixText: 'Rp ', border: OutlineInputBorder()),
                              onChanged: (v) => setDialogState(() => cashAmount = double.tryParse(v) ?? 0),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: quickMoneyOptions.map((opt) => ActionChip(
                                label: Text(currencyFormatter.format(opt), style: const TextStyle(fontSize: 10)),
                                onPressed: () {
                                  setDialogState(() {
                                    cashAmount = opt.toDouble();
                                    cashController.text = opt.toInt().toString();
                                  });
                                },
                              )).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Kembalian'),
                                Text(currencyFormatter.format(change), style: TextStyle(fontWeight: FontWeight.bold, color: cashAmount >= provider.cartTotal ? Colors.green : Colors.red)),
                              ],
                            ),
                          ],

                          if (paymentMethod == 'QRIS') ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Image.network('https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=KASIRKU-${provider.cartTotal}', height: 120),
                                  const SizedBox(height: 8),
                                  const Text('Scan QRIS Kasirku', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                                ],
                              ),
                            ),
                          ],

                          if (paymentMethod == 'Kartu') ...[
                             Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(color: const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(12)),
                               child: Column(
                                 children: [
                                   const Icon(Icons.photo_camera, size: 48, color: Color(0xFF0D47A1)),
                                   const SizedBox(height: 8),
                                   const Text('Foto HP Pelanggan / Bukti Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                   const Text('Cukup foto layar HP / struk EDC pelanggan untuk verifikasi kartu debit', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
                                   const SizedBox(height: 12),
                                   if (proofPhotoBase64 != null)
                                     Stack(
                                       children: [
                                         ClipRRect(
                                           borderRadius: BorderRadius.circular(8),
                                           child: Image.memory(base64Decode(proofPhotoBase64!), height: 120, width: double.infinity, fit: BoxFit.cover),
                                         ),
                                         Positioned(
                                           top: 4, right: 4,
                                           child: GestureDetector(
                                             onTap: () => setDialogState(() => proofPhotoBase64 = null),
                                             child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                                           ),
                                         )
                                       ],
                                     )
                                   else
                                     ElevatedButton.icon(
                                       onPressed: () async {
                                         final picker = ImagePicker();
                                         final photo = await picker.pickImage(source: ImageSource.camera);
                                         if (photo != null) {
                                           final bytes = await photo.readAsBytes();
                                           setDialogState(() => proofPhotoBase64 = base64Encode(bytes));
                                         }
                                       },
                                       icon: const Icon(Icons.add_a_photo, size: 16),
                                       label: const Text('Ambil / Unggah Foto HP', style: TextStyle(fontSize: 11)),
                                       style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0061A4), foregroundColor: Colors.white),
                                     ),
                                 ],
                               ),
                             )
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006C49),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (paymentMethod == 'Tunai' && cashAmount < provider.cartTotal) ? null : () {
                       final trx = provider.checkout(paymentAmount: cashAmount, paymentMethod: paymentMethod);
                       Navigator.pop(ctx);
                       if (trx != null) {
                         _showSuccessReceipt(context, trx, provider, cashAmount);
                       }
                    },
                    child: const Text('KONFIRMASI LUNAS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMethodBtn(String label, IconData icon, String active, Function(String) onSelect) {
    bool isSelected = label == active || (label == 'Kartu' && active == 'Kartu');
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
            border: Border.all(color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessReceipt(BuildContext context, TransactionModel trx, PosProvider provider, double paidAmount) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
              ),
              const SizedBox(height: 12),
              const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(trx.invoiceNumber, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Paper Receipt Simulation (Matching React layout)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Text(provider.storeProfile.name.toUpperCase(), style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                            Text(provider.storeProfile.address, style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54), textAlign: TextAlign.center),
                            Text('Telp: ${provider.storeProfile.phone}', style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('--------------------------------', style: TextStyle(letterSpacing: 2, color: Colors.black38)),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('No: ${trx.invoiceNumber}', style: GoogleFonts.sourceCodePro(fontSize: 10)),
                                  Text('Kasir: ${trx.cashierName}', style: GoogleFonts.sourceCodePro(fontSize: 10)),
                                  Text('Waktu: ${trx.timeString}', style: GoogleFonts.sourceCodePro(fontSize: 10)),
                                  Text('Metode: ${trx.paymentMethod}', style: GoogleFonts.sourceCodePro(fontSize: 10)),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('--------------------------------', style: TextStyle(letterSpacing: 2, color: Colors.black38)),
                            ),
                            ...trx.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('${item.quantity}x ${item.product.name}', style: GoogleFonts.sourceCodePro(fontSize: 10))),
                                  Text(currencyFormatter.format(item.subtotal), style: GoogleFonts.sourceCodePro(fontSize: 10)),
                                ],
                              ),
                            )),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('--------------------------------', style: TextStyle(letterSpacing: 2, color: Colors.black38)),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TOTAL', style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 12)), Text(currencyFormatter.format(trx.total), style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 12))]),
                            if (trx.paymentMethod == 'Tunai') ...[
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TUNAI', style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.black54)), Text(currencyFormatter.format(paidAmount), style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.black54))]),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('KEMBALI', style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.black54)), Text(currencyFormatter.format(trx.changeAmount), style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.black54))]),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('--------------------------------', style: TextStyle(letterSpacing: 2, color: Colors.black38)),
                            ),
                            Text(provider.footerMessage, style: GoogleFonts.sourceCodePro(fontSize: 9, color: Colors.black54), textAlign: TextAlign.center),
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
                    child: OutlinedButton.icon(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak struk...')));
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Cetak'),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(48)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(48)),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
