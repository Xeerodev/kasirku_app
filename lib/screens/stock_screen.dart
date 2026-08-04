import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Stok & Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context, provider),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.products.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final product = provider.products[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0D47A1),
              child: Text(
                product.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${product.category} • ${currencyFormatter.format(product.price)}\nStok: ${product.stock}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showProductDialog(
                    context,
                    provider,
                    productToEdit: product,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteProduct(product.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context, provider),
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showProductDialog(
    BuildContext context,
    PosProvider provider, {
    Product? productToEdit,
  }) {
    final nameController = TextEditingController(text: productToEdit?.name ?? '');
    final priceController =
        TextEditingController(text: productToEdit?.price.toInt().toString() ?? '');
    final stockController =
        TextEditingController(text: productToEdit?.stock.toString() ?? '');
    final descriptionController =
        TextEditingController(text: productToEdit?.description ?? '');

    String selectedCategory = productToEdit?.category ?? provider.existingCategories.first;
    bool isCustomCategory = !provider.existingCategories.contains(selectedCategory);
    final customCategoryController =
        TextEditingController(text: isCustomCategory ? selectedCategory : '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(productToEdit == null ? 'Tambah Produk Baru' : 'Edit Produk'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                    ),
                    const SizedBox(height: 12),

                    // Kategori Select / Manual Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kategori:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              isCustomCategory = !isCustomCategory;
                            });
                          },
                          child: Text(
                            isCustomCategory ? 'Pilih Daftar' : '+ Ketik Manual',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                    if (!isCustomCategory)
                      DropdownButton<String>(
                        isExpanded: true,
                        value: provider.existingCategories.contains(selectedCategory)
                            ? selectedCategory
                            : provider.existingCategories.first,
                        items: provider.existingCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedCategory = val;
                            });
                          }
                        },
                      )
                    else
                      TextField(
                        controller: customCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kategori Baru',
                          hintText: 'Tulis nama kategori...',
                        ),
                      ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rp)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Stok',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Produk',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final finalCategory = isCustomCategory
                        ? customCategoryController.text.trim()
                        : selectedCategory;

                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        stockController.text.isEmpty) {
                      return;
                    }

                    provider.saveProduct(Product(
                      id: productToEdit?.id ?? '',
                      name: nameController.text,
                      category: finalCategory.isEmpty ? 'Umum' : finalCategory,
                      price: double.tryParse(priceController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      description: descriptionController.text,
                      image: productToEdit?.image ?? '',
                    ));

                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
