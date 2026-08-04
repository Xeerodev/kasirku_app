import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/pos_provider.dart';
import '../models/store_profile.dart';

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

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PosProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.storeProfile.name);
    _addressController = TextEditingController(text: provider.storeProfile.address);
    _phoneController = TextEditingController(text: provider.storeProfile.phone);
    _cashierController = TextEditingController(text: provider.storeProfile.cashierName);
    _footerController = TextEditingController(text: provider.footerMessage);
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
    final url = Uri.parse('https://wa.me/6283164004093?text=mau%20kasih%20masukan');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.settings, color: provider.isDarkMode ? Colors.skyAccent : const Color(0xFF003178)),
            const SizedBox(width: 12),
            Text('Pengaturan', style: TextStyle(color: provider.isDarkMode ? Colors.skyAccent : const Color(0xFF003178), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: _handleContactDev,
              icon: const Icon(Icons.chat, size: 16, color: Colors.white),
              label: const Text('Hubungi Dev', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
              title: 'Profil Toko & Kasir',
              icon: Icons.store,
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
                              color: const Color(0xFFE9F5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.1)),
                              image: provider.storeProfile.logoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(provider.storeProfile.logoUrl), fit: BoxFit.cover) : null,
                            ),
                            child: provider.storeProfile.logoUrl.isEmpty ? const Icon(Icons.storefront, size: 40, color: Colors.grey) : null,
                          ),
                          TextButton(
                            onPressed: () {
                              _showLogoUrlPrompt(context, provider);
                            },
                            child: const Text('Ubah Logo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextField(controller: _nameController, label: 'Nama Toko'),
                            const SizedBox(height: 12),
                            _buildTextField(controller: _cashierController, label: 'Nama Kasir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _addressController, label: 'Alamat', maxLines: 2),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _phoneController, label: 'Nomor Telepon'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      provider.updateStoreProfile(StoreProfile(
                        name: _nameController.text,
                        address: _addressController.text,
                        phone: _phoneController.text,
                        cashierName: _cashierController.text,
                        logoUrl: provider.storeProfile.logoUrl,
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0061A4), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Simpan Profil & Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 2: Printer
            _buildSection(
              title: 'Printer & Struk',
              icon: Icons.print,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: provider.activePrinter,
                    decoration: const InputDecoration(labelText: 'Printer Aktif', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                    items: const [
                      DropdownMenuItem(value: 'Epson TM-T82X (USB)', child: Text('Epson TM-T82X (USB)')),
                      DropdownMenuItem(value: 'Bluetooth Printer 58mm', child: Text('Bluetooth Printer 58mm')),
                      DropdownMenuItem(value: 'Tidak ada printer', child: Text('Tidak ada printer')),
                    ],
                    onChanged: (val) => provider.updatePrinterSettings(printer: val),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchRow(
                    label: 'Cetak struk otomatis',
                    value: provider.autoPrintReceipt,
                    onChanged: (val) => provider.updatePrinterSettings(autoPrint: val),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _footerController, label: 'Pesan Footer Struk', maxLines: 3),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('Test Print Struk'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: const BorderSide(color: Color(0xFF0061A4)), foregroundColor: const Color(0xFF0061A4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 3: Sistem
            _buildSection(
              title: 'Sistem & Masukan',
              icon: Icons.settings_system_daydream,
              child: Column(
                children: [
                  _buildDropdownRow(
                    label: 'Bahasa',
                    icon: Icons.language,
                    value: provider.language,
                    items: ['Indonesia', 'English'],
                    onChanged: (val) => provider.updateSystemSettings(lang: val),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchRow(
                    label: 'Tema Gelap',
                    icon: Icons.dark_mode,
                    value: provider.isDarkMode,
                    onChanged: (val) => provider.updateSystemSettings(dark: val),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleContactDev,
                    icon: const Icon(Icons.chat),
                    label: const Text('Hubungi Developer (WhatsApp)'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.backup),
                    label: const Text('Cadangkan Data JSON'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: const BorderSide(color: Colors.grey), foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 4: Logout
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.05))),
              child: Column(
                children: [
                  Container(width: 56, height: 56, decoration: const BoxDecoration(color: Color(0xFFFFDAD6), shape: BoxShape.circle), child: const Icon(Icons.logout, color: Color(0xFF93000A), size: 30)),
                  const SizedBox(height: 12),
                  const Text('Keluar dari Sesi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Pastikan semua transaksi telah selesai sebelum keluar dari aplikasi.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    final isDark = Provider.of<PosProvider>(context, listen: false).isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12253C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF003178)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003178))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSwitchRow({required String label, required bool value, required ValueChanged<bool> onChanged, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 10)],
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF0061A4)),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5FAFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showLogoUrlPrompt(BuildContext context, PosProvider provider) {
    final controller = TextEditingController(text: provider.storeProfile.logoUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL Logo Baru'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'https://...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              provider.updateStoreProfile(StoreProfile(
                name: provider.storeProfile.name,
                address: provider.storeProfile.address,
                phone: provider.storeProfile.phone,
                cashierName: provider.storeProfile.cashierName,
                logoUrl: controller.text,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
