import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pos_provider.dart';
import '../models/store_profile.dart';

class SetupStoreScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const SetupStoreScreen({super.key, required this.onSwitchToLogin});

  @override
  State<SetupStoreScreen> createState() => _SetupStoreScreenState();
}

class _SetupStoreScreenState extends State<SetupStoreScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _logoBase64 = '';
  final String _defaultLogoUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuDHsGLOsUm9DlHUA9xeRpCapc2k1euPnzJcmzpRt_wjWQPVJ88L-F49scQ4D_RlATOmxa6YMFv0pCAsI4x-dd6QdWtAB905MfQ3qhy3SOvLTO3cs4m0qbR2VW1p_HjznuBoJlpBAzfz-sdyrHgJPXGqln6c8EYAzHv3zIYHz9ttb0WPoyhCysDwpOqTnI-xPbgNTL0sIJRDK-l4OsaXraEo8hWnDzmq1zLD29zlhgkabE8Nt99H39twcjRBwCh9wxz6tg';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context, listen: false);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            decoration: BoxDecoration(
              color: width > 700 ? Colors.white : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(24),
              boxShadow: width > 700 ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))] : null,
              border: width > 700 ? Border.all(color: Colors.blue.withOpacity(0.2)) : null,
            ),
            child: Flex(
              direction: width > 800 ? Axis.horizontal : Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left Branding (Desktop)
                if (width > 800)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3E4FE).withOpacity(0.6),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                        border: Border(right: BorderSide(color: Colors.black.withOpacity(0.05))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 180,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 20)],
                              border: Border.all(color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Image.network(
                              _defaultLogoUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Atur Toko Anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), letterSpacing: -1),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Kelola inventaris, lacak penjualan, dan kembangkan bisnis Anda dengan Kasirku POS.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFF45464D), height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          _buildInfoPoint(Icons.cloud_off, 'Berbasis Offline', 'Data tersimpan aman di perangkat Anda tanpa perlu internet.'),
                          _buildInfoPoint(Icons.code, 'Pengembang', 'Dikembangkan oleh Xeerodev untuk solusi UMKM modern.'),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.speed, color: Color(0xFF0D47A1), size: 24),
                                SizedBox(width: 12),
                                Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dibuat untuk Kecepatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D47A1))), Text('Dioptimalkan untuk lingkungan ritel cepat.', style: TextStyle(fontSize: 10, color: Color(0xFF45464D)))]))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Right Form
                Container(
                  width: width > 800 ? 500 : double.infinity,
                  padding: EdgeInsets.all(width > 800 ? 50 : 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (width <= 800) ...[
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFF0D47A1).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: const Icon(Icons.storefront, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 24),
                        const Text('Atur Toko Anda', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        const Text('Registrasi toko usaha baru Anda secara offline.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF45464D))),
                        const SizedBox(height: 40),
                      ],

                      Align(alignment: Alignment.centerLeft, child: Text('Upload Logo Toko', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1).withOpacity(0.8)))),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          final photo = await picker.pickImage(source: ImageSource.gallery, maxWidth: 300, imageQuality: 60);
                          if (photo != null) {
                            final bytes = await photo.readAsBytes();
                            setState(() => _logoBase64 = base64Encode(bytes));
                          }
                        },
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.5)),
                          ),
                          child: _logoBase64.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(base64Decode(_logoBase64), width: 50, height: 50, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Logo Terpilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                                            Text('Klik untuk mengganti', style: TextStyle(fontSize: 9, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.cloud_upload, color: Color(0xFF2196F3)),
                                    ],
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, color: Color(0xFF2196F3), size: 24),
                                    Text('Upload Logo (Opsional)', style: TextStyle(fontSize: 11, color: Color(0xFF45464D))),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildLabelField('Nama Toko', Icons.storefront, _nameController, 'cth. Kedai Kopi Sentral'),
                      const SizedBox(height: 16),
                      _buildLabelField('Alamat Toko', Icons.location_on, _addressController, 'Alamat jalan lengkap', maxLines: 2),
                      const SizedBox(height: 16),
                      _buildLabelField('Nomor HP', Icons.call, _phoneController, 'cth. 081234567890'),

                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama toko wajib diisi!'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                            return;
                          }
                          provider.updateStoreProfile(StoreProfile(
                            name: _nameController.text,
                            address: _addressController.text,
                            phone: _phoneController.text,
                            cashierName: 'Kasir Utama',
                            logoUrl: _logoBase64.isEmpty ? _defaultLogoUrl : _logoBase64,
                            isConfigured: true,
                          ));
                          provider.login();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 4),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Mulai Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), SizedBox(width: 12), Icon(Icons.arrow_forward)]),
                      ),

                      const SizedBox(height: 16),
                      const Center(child: Text('Dengan melanjutkan, Anda menyetujui Ketentuan Layanan kami.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey))),
                      const SizedBox(height: 16),
                      const Divider(),
                      Center(child: TextButton(onPressed: widget.onSwitchToLogin, child: const Text('Sudah punya akun? Masuk di sini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1))),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF45464D))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelField(String label, IconData icon, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Padding(padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0), child: Icon(icon, color: const Color(0xFF2196F3), size: 20)),
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2196F3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF2196F3).withOpacity(0.5))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
