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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: provider.language == 'Indonesia' ? 'id_ID' : 'en_US',
      symbol: provider.language == 'Indonesia' ? 'Rp ' : r'$',
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
                  provider.tr('stock'),
                  style: TextStyle(
                    color: provider.isDarkMode ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  provider.language == 'Indonesia' ? 'Kelola ketersediaan produk dan harga barang' : 'Manage product availability and item prices',
                  style: TextStyle(color: provider.isDarkMode ? Colors.white54 : const Color(0xFF45464D), fontSize: 12),
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: provider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: provider.tr('search_product'),
                      hintStyle: TextStyle(color: provider.isDarkMode ? Colors.white38 : Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: provider.isDarkMode ? Colors.white38 : const Color(0xFF76777D)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: Icon(Icons.close, size: 18, color: provider.isDarkMode ? Colors.white38 : Colors.grey), onPressed: () => setState(() => _searchQuery = ''))
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
            Text(provider.language == 'Indonesia' ? 'Belum Ada Produk dalam Stok' : 'No Products in Stock Yet', style: TextStyle(fontWeight: FontWeight.bold, color: provider.isDarkMode ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(provider.language == 'Indonesia' ? 'Klik tombol \'+\' di bawah untuk menambahkan produk baru.' : 'Click the \'+\' button below to add a new product.', textAlign: TextAlign.center, style: TextStyle(color: provider.isDarkMode ? Colors.white54 : Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(Product product, PosProvider provider, NumberFormat formatter) {
    final isOutOfStock = product.stock == 0;
    final isLowStock = product.stock > 0 && product.stock <= 3;
    final isDark = provider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12253C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFBA1A1A).withOpacity(0.5)
              : isLowStock
                  ? const Color(0xFFEA580C).withOpacity(0.5)
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
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
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5FAFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.image.isNotEmpty
                  ? (product.image.startsWith('http')
                      ? Image.network(product.image, fit: BoxFit.cover, color: isOutOfStock ? Colors.grey : null, colorBlendMode: isOutOfStock ? BlendMode.saturation : null)
                      : Image.memory(base64Decode(product.image), fit: BoxFit.cover, color: isOutOfStock ? Colors.grey : null, colorBlendMode: isOutOfStock ? BlendMode.saturation : null))
                  : Icon(Icons.inventory, color: isDark ? Colors.white24 : Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.category, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey)),
                const SizedBox(height: 12),
                if (isOutOfStock)
                  Row(children: [const Icon(Icons.block, size: 14, color: Color(0xFFBA1A1A)), const SizedBox(width: 4), Text(provider.tr('out_of_stock'), style: const TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold, fontSize: 11))])
                else if (isLowStock)
                  Row(children: [const Icon(Icons.warning, size: 14, color: Color(0xFFEA580C)), const SizedBox(width: 4), Text('${provider.tr('low_stock')} ${product.stock}', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold, fontSize: 11))])
                else
                  Text('${provider.language == 'Indonesia' ? 'Stok' : 'Stock'}: ${product.stock}', style: TextStyle(color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1), fontSize: 11)),
                Text(formatter.format(product.price), style: TextStyle(color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.1))),
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
    final lang = provider.language;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFFFFDAD6), shape: BoxShape.circle), child: const Icon(Icons.delete, color: Color(0xFFBA1A1A))),
            const SizedBox(height: 16),
            Text(provider.tr('delete_product'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: provider.isDarkMode ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text('${provider.tr('confirm_delete')} "${product.name}"?', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: provider.isDarkMode ? Colors.white54 : Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(provider.tr('cancel')))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () {
                  provider.deleteProduct(product.id);
                  Navigator.pop(ctx);
                  _showFloatingPopup(context, lang == 'Indonesia' ? 'Produk berhasil dihapus!' : 'Product deleted successfully!', isError: true);
                }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(lang == 'Indonesia' ? 'Hapus' : 'Delete'))),
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
    final lang = provider.language;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(productToEdit == null ? provider.tr('add_product') : provider.tr('edit_product'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: provider.isDarkMode ? Colors.lightBlueAccent : const Color(0xFF0D47A1))),
                        IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: provider.isDarkMode ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildLabel(provider.tr('product_name'), provider.isDarkMode),
                    TextFormField(
                      controller: nameCtrl,
                      style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87),
                      decoration: _inputDeco(lang == 'Indonesia' ? 'cth. Latte Special' : 'e.g. Special Latte'),
                      validator: (v) => v!.isEmpty ? (lang == 'Indonesia' ? 'Nama produk wajib diisi' : 'Product name is required') : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(provider.tr('category'), provider.isDarkMode),
                        TextButton(
                          onPressed: () => setDialogState(() => isCustom = !isCustom),
                          child: Text(isCustom ? (lang == 'Indonesia' ? 'Pilih dari Daftar' : 'Choose from List') : (lang == 'Indonesia' ? '+ Ketik Manual' : '+ Type Manual'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (!isCustom)
                      DropdownButtonFormField<String>(
                        dropdownColor: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
                        value: provider.existingCategories.contains(selectedCat) ? selectedCat : provider.existingCategories.first,
                        style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87),
                        items: provider.existingCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setDialogState(() => selectedCat = val!),
                        decoration: _inputDeco(''),
                      )
                    else
                      TextFormField(
                        onChanged: (v) => selectedCat = v,
                        style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87),
                        decoration: _inputDeco(lang == 'Indonesia' ? 'Tulis nama kategori baru...' : 'Type new category name...'),
                        validator: (v) => v!.isEmpty ? (lang == 'Indonesia' ? 'Kategori wajib diisi' : 'Category is required') : null,
                      ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(provider.tr('price'), provider.isDarkMode),
                              TextFormField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87),
                                decoration: _inputDeco('25000'),
                                validator: (v) => v!.isEmpty ? (lang == 'Indonesia' ? 'Harga wajib diisi' : 'Price is required') : null,
                              )
                            ]
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(provider.tr('stock_amount'), provider.isDarkMode),
                              TextFormField(
                                controller: stockCtrl,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87),
                                decoration: _inputDeco('50'),
                                validator: (v) => v!.isEmpty ? (lang == 'Indonesia' ? 'Stok wajib diisi' : 'Stock is required') : null,
                              )
                            ]
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel(provider.language == 'Indonesia' ? 'Gambar Produk' : 'Product Image', provider.isDarkMode),
                    if (imageBase64.isNotEmpty)
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: provider.isDarkMode ? Colors.white10 : Colors.grey.shade300),
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
                              child: Text(lang == 'Indonesia' ? 'Ganti' : 'Change', style: const TextStyle(fontSize: 10)),
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
                            color: provider.isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: provider.isDarkMode ? Colors.white10 : Colors.grey.shade300, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload, color: Color(0xFF0D47A1), size: 32),
                              Text(lang == 'Indonesia' ? 'Upload Gambar dari Galeri' : 'Upload Image from Gallery', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: provider.isDarkMode ? Colors.white70 : Colors.black87)),
                              Text('JPG, PNG, WEBP (Auto-Compressed)', style: TextStyle(fontSize: 9, color: provider.isDarkMode ? Colors.white38 : Colors.grey.shade400)),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    _buildLabel(provider.tr('description'), provider.isDarkMode),
                    TextFormField(controller: descCtrl, maxLines: 2, style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87), decoration: _inputDeco(lang == 'Indonesia' ? 'Deskripsi singkat produk...' : 'Short product description...')),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(provider.tr('cancel')))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
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
                                _showFloatingPopup(context, productToEdit == null ? (lang == 'Indonesia' ? 'Produk berhasil ditambahkan!' : 'Product added successfully!') : (lang == 'Indonesia' ? 'Perubahan produk berhasil disimpan!' : 'Product changes saved successfully!'), isError: false);
                              }
                            },
                            child: Text(provider.tr('save')),
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
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)));
  }

  InputDecoration _inputDeco(String hint) {
    final isDark = Provider.of<PosProvider>(context, listen: false).isDarkMode;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1))),
    );
  }

  void _showFloatingPopup(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF0D47A1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
      ),
    );
  }
}
