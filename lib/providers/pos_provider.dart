import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/store_profile.dart';

class PosProvider with ChangeNotifier {
  List<Product> _products = [];

  final List<CartItem> _cart = [];
  List<TransactionModel> _transactions = [];
  StoreProfile _storeProfile = StoreProfile(
    name: '',
    address: '',
    phone: '',
    cashierName: '',
    logoUrl: 'assets/images/logo.png',
    isConfigured: false,
  );
  bool _isDarkMode = false;
  bool _isLoggedIn = false;
  String _adminPassword = '123456';
  List<Map<String, dynamic>> _backups = [];

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

  Map<String, dynamic>? get topProduct {
    if (_transactions.isEmpty) return null;
    
    final Map<String, int> productSales = {};
    for (var trx in _transactions.where((t) => t.status == 'Lunas')) {
      for (var item in trx.items) {
        productSales[item.product.name] = (productSales[item.product.name] ?? 0) + item.quantity;
      }
    }
    
    if (productSales.isEmpty) return null;
    
    var sortedEntries = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topEntry = sortedEntries.first;
    final productIndex = _products.indexWhere((p) => p.name == topEntry.key);
    
    return {
      'name': topEntry.key,
      'sold': topEntry.value,
      'image': productIndex >= 0 ? _products[productIndex].image : 'assets/images/logo.png',
    };
  }

  List<String> get existingCategories {
    return _products.map((p) => p.category).toSet().toList();
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
      'summary_today': 'Ringkasan Penjualan Hari Ini',
      'invoice_detail': 'Detail Faktur',
      'refund': 'Refund',
      'paid': 'Lunas',
    },
    'English': {
      'cashier': 'POS',
      'stock': 'Inventory',
      'history': 'History',
      'reports': 'Reports',
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
      'summary_today': 'Today\'s Sales Summary',
      'invoice_detail': 'Invoice Detail',
      'refund': 'Refund',
      'paid': 'Paid',
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

  bool loginWithCredentials(String cashierName, String password) {
    // 1. Check current active profile
    if (_storeProfile.cashierName.toLowerCase() == cashierName.toLowerCase() && 
        _adminPassword == password) {
      _isLoggedIn = true;
      _saveToPrefs();
      notifyListeners();
      return true;
    }

    // 2. Check backups
    final backup = findBackup(cashierName, password);
    if (backup != null) {
      restoreBackup(backup);
      return true;
    }

    return false;
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

  void updateStoreProfile(StoreProfile profile, {String? password}) {
    // If we are starting fresh from setup (not restoring), we don't clear here 
    // because resetAllData/prepareForNewSetup already did it if necessary.
    _storeProfile = profile;
    if (password != null) _adminPassword = password;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> prepareForNewSetup() async {
    // Save current active data to backups before clearing
    if (_storeProfile.isConfigured) {
      final currentData = {
        'storeProfile': _storeProfile.toJson(),
        'products': _products.map((p) => p.toJson()).toList(),
        'transactions': _transactions.map((t) => t.toJson()).toList(),
        'password': _adminPassword,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Remove old backup for same cashier if exists to update it
      _backups.removeWhere((b) => 
        b['storeProfile']['cashierName'].toString().toLowerCase() == 
        _storeProfile.cashierName.toLowerCase()
      );
      
      _backups.add(currentData);
    }

    // Clear active state
    _products = [];
    _transactions = [];
    _cart.clear();
    _storeProfile = StoreProfile(
      name: '',
      address: '',
      phone: '',
      cashierName: '',
      logoUrl: 'assets/images/logo.png',
      isConfigured: false,
    );
    _adminPassword = '123456';
    _isLoggedIn = false;
    
    await _saveToPrefs();
    notifyListeners();
  }

  Map<String, dynamic>? findBackup(String cashierName, String password) {
    try {
      return _backups.firstWhere(
        (b) => 
          b['storeProfile']['cashierName'].toString().toLowerCase() == cashierName.toLowerCase() &&
          b['password'] == password,
      );
    } catch (_) {
      return null;
    }
  }

  void restoreBackup(Map<String, dynamic> backup) {
    _storeProfile = StoreProfile.fromJson(backup['storeProfile']);
    _adminPassword = backup['password'];
    
    final List prodList = backup['products'];
    _products = prodList.map((item) => Product.fromJson(item)).toList();
    
    final List trxList = backup['transactions'];
    _transactions = trxList.map((item) => TransactionModel.fromJson(item)).toList();
    
    _isLoggedIn = true; // Auto login on restore
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> resetAllData() async {
    _products = [];
    _transactions = [];
    _cart.clear();
    _backups = [];
    _storeProfile = StoreProfile(
      name: '',
      address: '',
      phone: '',
      cashierName: '',
      logoUrl: 'assets/images/logo.png',
      isConfigured: false,
    );
    _adminPassword = '123456';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wipe everything
    
    notifyListeners();
  }

  String getBackupJson() {
    return jsonEncode({
      'storeProfile': _storeProfile.toJson(),
      'products': _products.map((p) => p.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'settings': {
        'printer': _activePrinter,
        'autoPrint': _autoPrintReceipt,
        'footer': _footerMessage,
        'language': _language,
        'darkMode': _isDarkMode,
      }
    });
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
    prefs.setString('backups', jsonEncode(_backups));
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

    final backupsStr = prefs.getString('backups');
    if (backupsStr != null) {
      final List list = jsonDecode(backupsStr);
      _backups = list.cast<Map<String, dynamic>>();
    }

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
      _transactions = [];
    }
    notifyListeners();
  }
}
