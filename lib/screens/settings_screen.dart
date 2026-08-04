import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/store_profile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);

    final nameController =
        TextEditingController(text: provider.storeProfile.name);
    final addressController =
        TextEditingController(text: provider.storeProfile.address);
    final phoneController =
        TextEditingController(text: provider.storeProfile.phone);
    final cashierController =
        TextEditingController(text: provider.storeProfile.cashierName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Toko'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Switch
            SwitchListTile(
              title: const Text('Mode Gelap (Dark Mode)'),
              subtitle: const Text('Ubah tampilan aplikasi menjadi gelap'),
              value: provider.isDarkMode,
              onChanged: (val) => provider.toggleDarkMode(),
            ),
            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Profil Toko',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Toko',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Toko',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cashierController,
              decoration: const InputDecoration(
                labelText: 'Nama Kasir Aktif',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                provider.updateStoreProfile(
                  StoreProfile(
                    name: nameController.text,
                    address: addressController.text,
                    phone: phoneController.text,
                    cashierName: cashierController.text,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil toko berhasil disimpan!')),
                );
              },
              child: const Text('Simpan Pengaturan', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
