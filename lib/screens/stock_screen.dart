import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final filteredProducts = provider.products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 3 : (width > 800 ? 2 : 1);

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      body: Column(
        children: [
          // Header Section (Matching React StockView)
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Stok',
                  style: TextStyle(
                    color: provider.isDarkMode ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const Text(
                  'Kelola ketersediaan produk dan harga barang',
                  style: TextStyle(color: Color(0xFF45464D), fontSize: 12),
                ),
                const SizedBox(height: 20),
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
                      hintText: 'Cari Produk...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF76777D)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _searchQuery = ''))
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List Area (Grid for desktop/tablet)
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState(provider)
                : width > 800
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildStockItem(filteredProducts[index], provider, currencyFormatter);
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildStockItem(filteredProducts[index], provider, currencyFormatter);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context, provider),
        backgroundColor: const Color(0xFF0D47A1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(PosProvider provider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2, size: 48, color: Color(0xFF2196F3)),
            const SizedBox(height: 12),
            const Text('Belum Ada Produk dalam Stok', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Klik tombol \'+\' di bawah untuk menambahkan produk baru.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(Product product, PosProvider provider, NumberFormat formatter) {
    final isOutOfStock = product.stock == 0;
    final isLowStock = product.stock > 0 && product.stock <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFFFDAD6)
              : isLowStock
                  ? const Color(0xFFFFEDD5)
                  : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.image.isNotEmpty
                  ? (product.image.startsWith('http')
                      ? Image.network(product.image, fit: BoxFit.cover, color: isOutOfStock ? Colors.grey : null, colorBlendMode: isOutOfStock ? BlendMode.saturation : null)
                      : Image.memory(base64Decode(product.image), fit: BoxFit.cover, color: isOutOfStock ? Colors.grey : null, colorBlendMode: isOutOfStock ? BlendMode.saturation : null))
                  : const Icon(Icons.inventory, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                if (isOutOfStock)
                  Row(children: [const Icon(Icons.block, size: 14, color: Color(0xFFBA1A1A)), const SizedBox(width: 4), const Text('Habis', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold, fontSize: 11))])
                else if (isLowStock)
                  Row(children: [const Icon(Icons.warning, size: 14, color: Color(0xFFEA580C)), const SizedBox(width: 4), Text('Sisa ${product.stock}', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 11))])
                else
                  Text('Stok: ${product.stock}', style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 11)),
                Text(formatter.format(product.price), style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.1))),
            child: Column(
              children: [
                IconButton(onPressed: () => _showProductDialog(context, provider, productToEdit: product), icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0D47A1)), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
                IconButton(onPressed: () => _showDeleteConfirm(context, product, provider), icon: const Icon(Icons.delete, size: 18, color: Color(0xFFBA1A1A)), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Product product, PosProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFFFFDAD6), shape: BoxShape.circle), child: const Icon(Icons.delete, color: Color(0xFFBA1A1A))),
            const SizedBox(height: 16),
            const Text('Hapus Produk?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Apakah Anda yakin ingin menghapus "${product.name}"?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Batal'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () {
                  provider.deleteProduct(product.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('Produk berhasil dihapus!'),
                        ],
                      ),
                      backgroundColor: const Color(0xFFBA1A1A),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height - 100,
                        left: 20,
                        right: 20,
                      ),
                    ),
                  );
                }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Hapus'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, PosProvider provider, {Product? productToEdit}) {
    final nameCtrl = TextEditingController(text: productToEdit?.name ?? '');
    final priceCtrl = TextEditingController(text: productToEdit?.price.toInt().toString() ?? '');
    final stockCtrl = TextEditingController(text: productToEdit?.stock.toString() ?? '');
    final descCtrl = TextEditingController(text: productToEdit?.description ?? '');
    String selectedCat = productToEdit?.category ?? 'Kopi';
    bool isCustom = !provider.existingCategories.contains(selectedCat);
    String imageBase64 = productToEdit?.image ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(productToEdit == null ? 'Tambah Produk Baru' : 'Edit Produk', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildLabel('Nama Produk'),
                  TextField(controller: nameCtrl, decoration: _inputDeco('cth. Latte Special')),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Kategori'),
                      TextButton(
                        onPressed: () => setDialogState(() => isCustom = !isCustom),
                        child: Text(isCustom ? 'Pilih dari Daftar' : '+ Ketik Manual', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (!isCustom)
                    DropdownButtonFormField<String>(
                      value: provider.existingCategories.contains(selectedCat) ? selectedCat : provider.existingCategories.first,
                      items: provider.existingCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setDialogState(() => selectedCat = val!),
                      decoration: _inputDeco(''),
                    )
                  else
                    TextField(
                      onChanged: (v) => selectedCat = v,
                      decoration: _inputDeco('Tulis nama kategori baru...'),
                    ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Harga (Rp)'), TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('25000'))])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Jumlah Stok'), TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('50'))])),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Gambar Produk'),
                  if (imageBase64.isNotEmpty)
                    Stack(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageBase64.startsWith('http')
                                ? Image.network(imageBase64, fit: BoxFit.cover)
                                : Image.memory(base64Decode(imageBase64), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => setDialogState(() => imageBase64 = ''),
                            child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
                          ),
                        ),
                        Positioned(
                          bottom: 8, right: 8,
                          child: ElevatedButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              // Optimized Image Picking for low storage usage
                              final photo = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 400,
                                maxHeight: 400,
                                imageQuality: 70,
                              );
                              if (photo != null) {
                                final bytes = await photo.readAsBytes();
                                setDialogState(() => imageBase64 = base64Encode(bytes));
                              }
                            },
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), minimumSize: Size.zero),
                            child: const Text('Ganti', style: TextStyle(fontSize: 10)),
                          ),
                        )
                      ],
                    )
                  else
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        // Optimized Image Picking
                        final photo = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 400,
                          maxHeight: 400,
                          imageQuality: 70,
                        );
                        if (photo != null) {
                          final bytes = await photo.readAsBytes();
                          setDialogState(() => imageBase64 = base64Encode(bytes));
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload, color: Color(0xFF0D47A1), size: 32),
                            const Text('Upload Gambar dari Galeri', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('JPG, PNG, WEBP (Auto-Compressed)', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  _buildLabel('Deskripsi Produk'),
                  TextField(controller: descCtrl, maxLines: 2, decoration: _inputDeco('Deskripsi singkat produk...')),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Batal'))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || stockCtrl.text.isEmpty) return;
                            provider.saveProduct(Product(
                              id: productToEdit?.id ?? '',
                              name: nameCtrl.text,
                              category: selectedCat,
                              price: double.tryParse(priceCtrl.text) ?? 0,
                              stock: int.tryParse(stockCtrl.text) ?? 0,
                              image: imageBase64,
                              description: descCtrl.text,
                            ));
                            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(productToEdit == null ? 'Produk berhasil ditambahkan!' : 'Perubahan produk berhasil disimpan!'),
                  ],
                ),
                backgroundColor: const Color(0xFF0D47A1),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 100,
                  left: 20,
                  right: 20,
                ),
                duration: const Duration(seconds: 2),
              ),
            );
                          },
                          child: const Text('Simpan Produk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1))),
    );
  }
}
