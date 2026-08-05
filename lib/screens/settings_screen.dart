import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pos_provider.dart';
import '../models/store_profile.dart';
import '../services/printer_service.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _cashierController;
  late TextEditingController _footerController;
  final PrinterService _printerService = PrinterService();
  bool _isPrinterConnected = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PosProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.storeProfile.name);
    _addressController = TextEditingController(text: provider.storeProfile.address);
    _phoneController = TextEditingController(text: provider.storeProfile.phone);
    _cashierController = TextEditingController(text: provider.storeProfile.cashierName);
    _footerController = TextEditingController(text: provider.footerMessage);
    _checkPrinterStatus();
  }

  Future<void> _checkPrinterStatus() async {
    if (kIsWeb) return;
    bool connected = await _printerService.isConnected();
    if (mounted) setState(() => _isPrinterConnected = connected);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cashierController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _handleContactDev() async {
    final url = Uri.parse('https://wa.me/6283164004093?text=Halo%20Developer%20Kasirku');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
    }
  }

  Future<void> _handleLogoPick(BuildContext context, PosProvider provider) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, imageQuality: 70);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final base64 = base64Encode(bytes);
      provider.updateStoreProfile(provider.storeProfile.copyWith(logoUrl: base64));
      if (mounted) _showFloatingPopup(context, provider.language == 'Indonesia' ? 'Logo berhasil diperbarui' : 'Logo updated successfully', isError: false);
    }
  }

  void _showChangePasswordDialog(BuildContext context, PosProvider provider) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final isDark = provider.isDarkMode;
    final lang = provider.language;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF12253C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(provider.tr('change_password'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang == 'Indonesia' ? 'Konfirmasi kata sandi lama sebelum menggantinya.' : 'Confirm old password before changing.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: lang == 'Indonesia' ? 'Kata Sandi Saat Ini' : 'Current Password',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: lang == 'Indonesia' ? 'Kata Sandi Baru' : 'New Password',
                hintText: lang == 'Indonesia' ? 'Minimal 6 karakter' : 'Min 6 characters',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang == 'Indonesia' ? 'Batal' : 'Cancel')),
          ElevatedButton(
            onPressed: () {
              if (oldPassCtrl.text != provider.adminPassword) {
                _showFloatingPopup(context, lang == 'Indonesia' ? 'Kata sandi lama salah!' : 'Wrong current password!', isError: true);
                return;
              }
              if (newPassCtrl.text.length < 4) {
                _showFloatingPopup(context, lang == 'Indonesia' ? 'Password baru terlalu pendek!' : 'New password is too short!', isError: true);
                return;
              }
              provider.updatePassword(newPassCtrl.text);
              Navigator.pop(ctx);
              _showFloatingPopup(context, lang == 'Indonesia' ? 'Kata sandi berhasil diubah' : 'Password changed successfully', isError: false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
            child: Text(lang == 'Indonesia' ? 'Simpan' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackupJson(BuildContext context, PosProvider provider) async {
    final jsonStr = provider.getBackupJson();
    final path = await ExportService.saveBackupJson(jsonStr);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.backup, color: Color(0xFF0D47A1)),
              const SizedBox(width: 12),
              Text(provider.language == 'Indonesia' ? 'Cadangkan Data' : 'Data Backup', style: TextStyle(color: provider.isDarkMode ? Colors.white : Colors.black87)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path != null
                  ? (provider.language == 'Indonesia' ? 'Data berhasil dicadangkan ke file JSON.' : 'Data successfully backed up to JSON file.')
                  : (provider.language == 'Indonesia' ? 'Gagal mencadangkan data.' : 'Failed to backup data.'),
                style: TextStyle(color: provider.isDarkMode ? Colors.white70 : Colors.black87, fontSize: 13),
              ),
              if (path != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(path, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.blue)),
                ),
              ]
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  void _showFloatingPopup(BuildContext context, String message, {bool isError = false}) {
    final isDark = Provider.of<PosProvider>(context, listen: false).isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF006C49),
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final isDark = provider.isDarkMode;
    final lang = provider.language;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF12253C) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.settings, color: isDark ? Colors.lightBlueAccent : const Color(0xFF003178)),
            const SizedBox(width: 12),
            Text(provider.tr('settings'), style: TextStyle(color: isDark ? Colors.lightBlueAccent : const Color(0xFF003178), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: _handleContactDev,
              icon: const Icon(Icons.chat, size: 16, color: Colors.white),
              label: Text(lang == 'Indonesia' ? 'Hubungi Dev' : 'Contact Dev', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section 1: Profil Toko
            _buildSection(
              title: provider.tr('store_profile'),
              icon: Icons.store,
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE9F5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1)),
                              image: provider.storeProfile.logoUrl.isNotEmpty
                                ? (provider.storeProfile.logoUrl.startsWith('http')
                                    ? DecorationImage(image: NetworkImage(provider.storeProfile.logoUrl), fit: BoxFit.cover)
                                    : DecorationImage(image: MemoryImage(base64Decode(provider.storeProfile.logoUrl)), fit: BoxFit.cover))
                                : null,
                            ),
                            child: provider.storeProfile.logoUrl.isEmpty ? Icon(Icons.storefront, size: 40, color: isDark ? Colors.white24 : Colors.grey) : null,
                          ),
                          TextButton(
                            onPressed: () => _handleLogoPick(context, provider),
                            child: Text(lang == 'Indonesia' ? 'Ubah Logo' : 'Change Logo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1))),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextField(controller: _nameController, label: lang == 'Indonesia' ? 'Nama Toko' : 'Store Name', isDark: isDark),
                            const SizedBox(height: 12),
                            _buildTextField(controller: _cashierController, label: lang == 'Indonesia' ? 'Nama Kasir' : 'Cashier Name', isDark: isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _addressController, label: lang == 'Indonesia' ? 'Alamat' : 'Address', maxLines: 2, isDark: isDark),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _phoneController, label: lang == 'Indonesia' ? 'Nomor Telepon' : 'Phone Number', isDark: isDark),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      provider.updateStoreProfile(StoreProfile(
                        name: _nameController.text,
                        address: _addressController.text,
                        phone: _phoneController.text,
                        cashierName: _cashierController.text,
                        logoUrl: provider.storeProfile.logoUrl,
                        isConfigured: true,
                      ));
                      _showFloatingPopup(context, lang == 'Indonesia' ? 'Profil berhasil disimpan' : 'Profile saved successfully', isError: false);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0061A4), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(lang == 'Indonesia' ? 'Simpan Profil & Kasir' : 'Save Profile & Cashier', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 2: Printer
            _buildSection(
              title: provider.tr('printer_receipt'),
              icon: Icons.print,
              isDark: isDark,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5FAFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isPrinterConnected ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang == 'Indonesia' ? 'Status Printer' : 'Printer Status', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            Row(
                              children: [
                                Icon(Icons.circle, size: 8, color: _isPrinterConnected ? Colors.green : Colors.red),
                                const SizedBox(width: 6),
                                Text(
                                  _isPrinterConnected
                                    ? (lang == 'Indonesia' ? 'Terhubung' : 'Connected')
                                    : (lang == 'Indonesia' ? 'Tidak Ada Printer Terhubung' : 'No Printer Connected'),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _checkPrinterStatus,
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: lang == 'Indonesia' ? 'Cek Koneksi' : 'Check Status',
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: isDark ? const Color(0xFF12253C) : Colors.white,
                    value: provider.activePrinter,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: lang == 'Indonesia' ? 'Printer Aktif' : 'Active Printer',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                    ),
                    items: ['Epson TM-T82X (USB)', 'Bluetooth Printer 58mm', 'Tidak ada printer'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: TextStyle(color: isDark ? Colors.white : Colors.black87)))).toList(),
                    onChanged: (val) => provider.updatePrinterSettings(printer: val),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchRow(
                    label: lang == 'Indonesia' ? 'Cetak struk otomatis' : 'Auto print receipt',
                    value: provider.autoPrintReceipt,
                    onChanged: (val) => provider.updatePrinterSettings(autoPrint: val),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _footerController, label: lang == 'Indonesia' ? 'Pesan Footer Struk' : 'Receipt Footer Message', maxLines: 3, isDark: isDark),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Sistem
            _buildSection(
              title: lang == 'Indonesia' ? 'Sistem & Masukan' : 'System & Feedback',
              icon: Icons.settings_system_daydream,
              isDark: isDark,
              child: Column(
                children: [
                  _buildDropdownRow(
                    label: provider.tr('language'),
                    icon: Icons.language,
                    value: provider.language,
                    items: ['Indonesia', 'English'],
                    onChanged: (val) => provider.updateSystemSettings(lang: val),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchRow(
                    label: provider.tr('theme'),
                    icon: Icons.dark_mode,
                    value: provider.isDarkMode,
                    onChanged: (val) => provider.updateSystemSettings(dark: val),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showChangePasswordDialog(context, provider),
                    icon: const Icon(Icons.lock_reset),
                    label: Text(provider.tr('change_password')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleContactDev,
                    icon: const Icon(Icons.chat),
                    label: Text(lang == 'Indonesia' ? 'Hubungi Developer (WhatsApp)' : 'Contact Developer (WhatsApp)'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _handleBackupJson(context, provider),
                    icon: const Icon(Icons.backup),
                    label: Text(lang == 'Indonesia' ? 'Cadangkan Data JSON' : 'Backup JSON Data'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.grey),
                      foregroundColor: isDark ? Colors.white70 : Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 4: Logout
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF12253C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  Container(width: 56, height: 56, decoration: const BoxDecoration(color: Color(0xFFFFDAD6), shape: BoxShape.circle), child: const Icon(Icons.logout, color: Color(0xFF93000A), size: 30)),
                  const SizedBox(height: 12),
                  Text(provider.tr('logout'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(
                    lang == 'Indonesia'
                      ? 'Pastikan semua transaksi telah selesai sebelum keluar dari aplikasi.'
                      : 'Ensure all transactions are completed before logging out.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey)
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.logout(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(lang == 'Indonesia' ? 'Keluar' : 'Logout', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12253C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: isDark ? Colors.lightBlueAccent : const Color(0xFF003178)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.lightBlueAccent : const Color(0xFF003178))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, int maxLines = 1, bool isDark = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey),
        border: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: isDark ? Colors.lightBlueAccent : const Color(0xFF0D47A1))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSwitchRow({required String label, required bool value, required ValueChanged<bool> onChanged, IconData? icon, bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.grey), const SizedBox(width: 10)],
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
          Switch(value: value, onChanged: onChanged, activeColor: isDark ? Colors.lightBlueAccent : const Color(0xFF0061A4)),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged, required IconData icon}) {
    final isDark = Provider.of<PosProvider>(context, listen: false).isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.grey),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87)),
            ],
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF12253C) : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
