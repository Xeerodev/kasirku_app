import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/store_profile.dart';

class PosProvider with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Latte',
      category: 'Kopi',
      price: 45000,
      stock: 15,
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCD5wP3t-xFQxn5XoghNFgauxPU230h6J8bOnRmzYdAKM24saHAtAGNrrCc0E7w6Ximb9DZbx-GQrGDpRcxGYr7ayA7kJuLv3-47yIlRPFCgDf7BqIyUGqaFMERCvlI0W2GyZ3agi820v5oVazBc4_NUoQ5tVSAVkHWJC1wB2WC6tR33FvTbI2ARX8nSEkhwRwxN79kz5z170wuA2VnTS_ASgiYHBXf_UWbPQnCogaLyvT8EH3gQ3jt',
      description: 'Espresso creamy dengan susu segar berkualitas tinggi dan seni latte foam',
    ),
    Product(
      id: 'p2',
      name: 'Butter Croissant',
      category: 'Kue',
      price: 37500,
      stock: 8,
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0bvZcnjyjtHWAyCvb4Z0F_WLrDn5qp0DD-CJa4qY1h0Q0mGsnbnZtNHc5CYD3fsoP8xDbATpRupmhQ5K-j1auHAB9U-91lkczXRrGKuKwWtcDUBwtoR7pZeng_LTEXowm2_ehsRW2dOi6gUK4S3rfjzwkp_zI7cx9IdKeNr71XwKnQxjo45GQ1d7rq9zqCDzXVEFzP3COqyzGgPxsxn_RdR5lGJdyC2K0X9s_0msUPsCpbiT6-C2h',
      description: 'Roti croissant mentega Prancis renyah di luar, lembut berlapis di dalam',
    ),
    Product(
      id: 'p3',
      name: 'Iced Americano',
      category: 'Kopi',
      price: 35000,
      stock: 20,
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMuOWbl70BCHzw1FsgQQJoZ_U6XcE5bEwZ0WL6G1cmXWe3f_JV5GKHi6kuoFPVv3pFEmUMdxXg2TmXreAEY7-nEE0_8YtSSLGgq0sdDFHca2i-mMVJtyBvVxq-BH5LXCR-keAkPC9iZKRbYH77MZuOR5PHuNgEM3kXZoI4nH7PGhBQf4yAKEvs6lj50cMA-oI2yi9_70ralkKxQgm6l4n3dGknvSCxIAFmbc8DOdGJEG1LujIQwRPC',
      description: 'Double shot espresso dingin segar disajikan dengan es batu',
    ),
    Product(
      id: 'p4',
      name: 'Chocolate Chip Cookie',
      category: 'Kue',
      price: 25000,
      stock: 0,
      image: '',
      description: 'Kue kering cokelat lezat beraroma mentega',
    ),
    Product(
      id: 'p5',
      name: 'Campuran Espresso Artisan',
      category: 'Biji Kopi',
      price: 280000,
      stock: 45,
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBbr6zfbw-PQCu1WBIJFDrU0UNf-qWDHETwwl7IEDXt5scP_mGdtWzblQOLB4Xn57lTy5Daf2MrSiKWPXLpT_rtTsHdrVQgQNwj3pd4euQgqWBcespQVG_Bqf7HYEjpbxVeaO_6FtySpr7Lr2OFoZnzdSKRjDSAQ6K6NDjuh99xQxafNZi_zZn6cDB8CDGqcqXYO2mZFANl-iq4YPoLoGxn8vCSwl_PKAad5VlDbxcVF1IhX_7BWs9P',
      description: 'Biji kopi pilihan roasted segar dengan nota rasa cokelat dan kacang',
    ),
    Product(
      id: 'p6',
      name: 'Mug Keramik Pour-over',
      category: 'Merchandise',
      price: 180000,
      stock: 2,
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXa_18wnBm7xuaS1fS_jxljlcAODJG3JVz6kjiQskUKIY9p2hdLPQZ9jZYkFCUBpUklZUKtxMlP9PYPWm1NFKx488ohVh-uMbmOXqjA3GTHKC9N4RAolhBMzyGs4zT11liKF7xlu_AJcY--095s8lQZmsNO3HIwz0zNVYpo1Vv_bkmEM2zNyNV6qSnfs-4cgtTexlEHynZiAr6epyn3FbCWS05fqOK3MeLV8oSo6b76NY5Go7oyzzQ',
      description: 'Mug keramik buatan tangan estetis untuk penyeduhan manual',
    ),
  ];

  final List<CartItem> _cart = [];
  List<TransactionModel> _transactions = [];
  StoreProfile _storeProfile = StoreProfile(
    name: 'Toko Kopi Senja',
    address: 'Jl. Sudirman No. 123, Jakarta Selatan',
    phone: '0812-3456-7890',
    cashierName: 'Ahmad (Kasir 1)',
    logoUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHsGLOsUm9DlHUA9xeRpCapc2k1euPnzJcmzpRt_wjWQPVJ88L-F49scQ4D_RlATOmxa6YMFv0pCAsI4x-dd6QdWtAB905MfQ3qhy3SOvLTO3cs4m0qbR2VW1p_HjznuBoJlpBAzfz-sdyrHgJPXGqln6c8EYAzHv3zIYHz9ttb0WPoyhCysDwpOqTnI-xPbgNTL0sIJRDK-l4OsaXraEo8hWnDzmq1zLD29zlhgkabE8Nt99H39twcjRBwCh9wxz6tg',
    isConfigured: false,
  );
  bool _isDarkMode = false;
  bool _isLoggedIn = false;
  String _adminPassword = '123456';

  // Settings matching React
  String _activePrinter = 'Epson TM-T82X (USB)';
  bool _autoPrintReceipt = true;
  String _footerMessage = 'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli tidak dapat ditukar.';
  String _language = 'Indonesia';

  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<TransactionModel> get transactions => _transactions;
  StoreProfile get storeProfile => _storeProfile;
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  String get adminPassword => _adminPassword;

  String get activePrinter => _activePrinter;
  bool get autoPrintReceipt => _autoPrintReceipt;
  String get footerMessage => _footerMessage;
  String get language => _language;

  List<String> get existingCategories {
    final categories = _products.map((p) => p.category).toSet().toList();
    for (var defaultCat in ['Kopi', 'Kue', 'Merchandise', 'Biji Kopi', 'Teh', 'Minuman']) {
      if (!categories.contains(defaultCat)) {
        categories.add(defaultCat);
      }
    }
    return categories;
  }

  // Translation Map
  final Map<String, Map<String, String>> _translations = {
    'Indonesia': {
      'cashier': 'Kasir',
      'stock': 'Stok',
      'history': 'Riwayat',
      'reports': 'Laporan',
      'settings': 'Pengaturan',
      'search_product': 'Cari produk...',
      'empty_cart': 'Keranjang Kosong',
      'process_payment': 'PROSES PEMBAYARAN',
      'total_bill': 'Total Tagihan',
      'payment_method': 'Metode Pembayaran',
      'cash': 'Tunai',
      'card': 'Kartu',
      'change_password': 'Ubah Kata Sandi Kasir',
      'logout': 'Keluar dari Sesi',
      'language': 'Bahasa',
      'theme': 'Tema Gelap',
      'store_profile': 'Profil Toko & Kasir',
      'printer_receipt': 'Printer & Struk',
      'total_revenue': 'Total Omset',
      'total_transactions': 'Total Transaksi',
      'top_product': 'PRODUK TERLARIS',
      'recent_transactions': 'Transaksi Terakhir',
      'see_all': 'Lihat Semua',
      'out_of_stock': 'Habis',
      'low_stock': 'Sisa',
      'add_product': 'Tambah Produk Baru',
      'edit_product': 'Edit Produk',
      'save_product': 'Simpan Produk',
      'delete_product': 'Hapus Produk?',
      'confirm_delete': 'Apakah Anda yakin ingin menghapus',
      'product_name': 'Nama Produk',
      'category': 'Kategori',
      'price': 'Harga',
      'stock_amount': 'Jumlah Stok',
      'description': 'Deskripsi Produk',
      'upload_logo': 'Upload Logo Toko',
      'save_settings': 'Simpan Pengaturan',
      'receipt_footer': 'Pesan Footer Struk',
      'contact_dev': 'Hubungi Dev',
      'backup_data': 'Cadangkan Data JSON',
      'success_payment': 'Transaksi Berhasil!',
      'change': 'Kembalian',
      'done': 'Selesai',
      'print': 'Cetak',
      'cancel': 'Batal',
      'save': 'Simpan',
      'address': 'Alamat',
      'phone': 'Nomor Telepon',
      'cashier_name': 'Nama Kasir',
    },
    'English': {
      'cashier': 'POS',
      'stock': 'Inventory',
      'history': 'History',
      'reports': 'Analytics',
      'settings': 'Settings',
      'search_product': 'Search product...',
      'empty_cart': 'Cart is Empty',
      'process_payment': 'PROCESS PAYMENT',
      'total_bill': 'Total Bill',
      'payment_method': 'Payment Method',
      'cash': 'Cash',
      'card': 'Card',
      'change_password': 'Change Cashier Password',
      'logout': 'Logout Session',
      'language': 'Language',
      'theme': 'Dark Theme',
      'store_profile': 'Store Profile & Cashier',
      'printer_receipt': 'Printer & Receipt',
      'total_revenue': 'Total Revenue',
      'total_transactions': 'Total Transactions',
      'top_product': 'BEST SELLER',
      'recent_transactions': 'Recent Transactions',
      'see_all': 'See All',
      'out_of_stock': 'Out',
      'low_stock': 'Left',
      'add_product': 'Add New Product',
      'edit_product': 'Edit Product',
      'save_product': 'Save Product',
      'delete_product': 'Delete Product?',
      'confirm_delete': 'Are you sure you want to delete',
      'product_name': 'Product Name',
      'category': 'Category',
      'price': 'Price',
      'stock_amount': 'Stock Amount',
      'description': 'Product Description',
      'upload_logo': 'Upload Store Logo',
      'save_settings': 'Save Settings',
      'receipt_footer': 'Receipt Footer Message',
      'contact_dev': 'Contact Dev',
      'backup_data': 'Backup JSON Data',
      'success_payment': 'Transaction Success!',
      'change': 'Change',
      'done': 'Done',
      'print': 'Print',
      'cancel': 'Cancel',
      'save': 'Save',
      'address': 'Address',
      'phone': 'Phone Number',
      'cashier_name': 'Cashier Name',
    }
  };

  String tr(String key) {
    return _translations[_language]?[key] ?? key;
  }

  double get cartSubtotal =>
      _cart.fold(0, (sum, item) => sum + item.subtotal);

  double get cartTax => 0.0;

  double get cartTotal => cartSubtotal + cartTax;

  int get cartTotalItems =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  PosProvider() {
    _loadFromPrefs();
  }

  void login() {
    _isLoggedIn = true;
    _saveToPrefs();
    notifyListeners();
  }

  void updatePassword(String newPass) {
    _adminPassword = newPass;
    _saveToPrefs();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  void updatePrinterSettings({String? printer, bool? autoPrint, String? footer}) {
    if (printer != null) _activePrinter = printer;
    if (autoPrint != null) _autoPrintReceipt = autoPrint;
    if (footer != null) _footerMessage = footer;
    _saveToPrefs();
    notifyListeners();
  }

  void updateSystemSettings({String? lang, bool? dark}) {
    if (lang != null) _language = lang;
    if (dark != null) _isDarkMode = dark;
    _saveToPrefs();
    notifyListeners();
  }

  void addToCart(Product product) {
    if (product.stock <= 0) return;

    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity < product.stock) {
        _cart[index].quantity++;
      }
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, int delta) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final newQty = _cart[index].quantity + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else if (newQty <= _cart[index].product.stock) {
        _cart[index].quantity = newQty;
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  TransactionModel? checkout({
    required double paymentAmount,
    required String paymentMethod,
  }) {
    if (_cart.isEmpty || paymentAmount < cartTotal) return null;

    final total = cartTotal;
    final change = paymentAmount - total;

    // Reduce stock
    for (var item in _cart) {
      final pIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (pIndex >= 0) {
        final currentStock = _products[pIndex].stock;
        _products[pIndex] = _products[pIndex].copyWith(
          stock: (currentStock - item.quantity).clamp(0, 999999),
        );
      }
    }

    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final trxId = 'tx-${now.millisecondsSinceEpoch.toString().substring(10)}';

    final newTransaction = TransactionModel(
      id: trxId,
      invoiceNumber: 'INV-$dateStr-${now.millisecondsSinceEpoch.toString().substring(10)}',
      date: now,
      timeString: timeString,
      items: List.from(_cart),
      subtotal: cartSubtotal,
      tax: cartTax,
      discount: 0,
      total: total,
      paymentAmount: paymentAmount,
      changeAmount: change,
      paymentMethod: paymentMethod,
      cashierName: _storeProfile.cashierName,
      status: 'Lunas',
    );

    _transactions.insert(0, newTransaction);
    _cart.clear();
    _saveToPrefs();
    notifyListeners();
    return newTransaction;
  }

  void toggleRefund(String transactionId) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index >= 0) {
      final currentStatus = _transactions[index].status;
      _transactions[index] = _transactions[index].copyWith(
        status: currentStatus == 'Refund' ? 'Lunas' : 'Refund',
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void saveProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      final newProduct = product.copyWith(
        id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      );
      _products.add(newProduct);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _saveToPrefs();
    notifyListeners();
  }

  void updateStoreProfile(StoreProfile profile) {
    _storeProfile = profile;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setBool('isLoggedIn', _isLoggedIn);
    prefs.setString('storeProfile', jsonEncode(_storeProfile.toJson()));
    prefs.setString('products', jsonEncode(_products.map((p) => p.toJson()).toList()));
    prefs.setString('transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    prefs.setString('activePrinter', _activePrinter);
    prefs.setBool('autoPrintReceipt', _autoPrintReceipt);
    prefs.setString('footerMessage', _footerMessage);
    prefs.setString('language', _language);
    prefs.setString('adminPassword', _adminPassword);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _activePrinter = prefs.getString('activePrinter') ?? 'Epson TM-T82X (USB)';
    _autoPrintReceipt = prefs.getBool('autoPrintReceipt') ?? true;
    _footerMessage = prefs.getString('footerMessage') ?? 'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli tidak dapat ditukar.';
    _language = prefs.getString('language') ?? 'Indonesia';
    _adminPassword = prefs.getString('adminPassword') ?? '123456';

    final storeStr = prefs.getString('storeProfile');
    if (storeStr != null) {
      _storeProfile = StoreProfile.fromJson(jsonDecode(storeStr));
    }

    final prodStr = prefs.getString('products');
    if (prodStr != null) {
      final List list = jsonDecode(prodStr);
      _products = list.map((item) => Product.fromJson(item)).toList();
    }

    final trxStr = prefs.getString('transactions');
    if (trxStr != null) {
      final List list = jsonDecode(trxStr);
      _transactions = list.map((item) => TransactionModel.fromJson(item)).toList();
    } else {
      // Add initial transactions from React data
      _transactions = [
        TransactionModel(
          id: 'tx-142',
          invoiceNumber: 'INV-20231024-142',
          date: DateTime.now().subtract(const Duration(minutes: 5)),
          timeString: '14:32',
          items: [
            CartItem(product: _products[0], quantity: 1),
            CartItem(product: _products[2], quantity: 1),
          ],
          subtotal: 80000,
          tax: 0,
          discount: 0,
          total: 80000,
          paymentAmount: 100000,
          changeAmount: 20000,
          paymentMethod: 'QRIS',
          cashierName: 'Ahmad (Kasir 1)',
          status: 'Lunas',
        ),
      ];
    }
    notifyListeners();
  }
}
