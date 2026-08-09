import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import 'pos_screen.dart';
import 'stock_screen.dart';
import 'reports_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static _MainNavigationScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationScreenState>();

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void setTabIndex(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _screens = const [
    PosScreen(),
    StockScreen(),
    HistoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'id': 'pos', 'label': 'cashier', 'icon': Icons.point_of_sale},
    {'id': 'stok', 'label': 'stock', 'icon': Icons.inventory_2},
    {'id': 'riwayat', 'label': 'history', 'icon': Icons.history},
    {'id': 'laporan', 'label': 'reports', 'icon': Icons.analytics},
    {'id': 'pengaturan', 'label': 'settings', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape || width > 700;

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
      body: Row(
        children: [
          if (isLandscape) _buildSidebar(provider),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isLandscape ? null : _buildBottomNav(provider),
    );
  }

  Widget _buildSidebar(PosProvider provider) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        border: Border(
          right: BorderSide(
            color: provider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Sidebar
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: provider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                    image: provider.storeProfile.logoUrl.isEmpty
                      ? null
                      : provider.storeProfile.logoUrl.startsWith('assets/')
                        ? DecorationImage(image: AssetImage(provider.storeProfile.logoUrl), fit: BoxFit.contain)
                        : provider.storeProfile.logoUrl.startsWith('http')
                          ? DecorationImage(image: NetworkImage(provider.storeProfile.logoUrl), fit: BoxFit.contain)
                          : DecorationImage(image: MemoryImage(base64Decode(provider.storeProfile.logoUrl)), fit: BoxFit.contain),
                  ),
                  child: provider.storeProfile.logoUrl.isEmpty ? const Icon(Icons.store, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.storeProfile.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: provider.isDarkMode ? Colors.lightBlueAccent : const Color(0xFF0D47A1),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Developed by Xeerodev',
                        style: TextStyle(fontSize: 8, color: provider.isDarkMode ? Colors.white38 : Colors.grey, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isActive = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF0D47A1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive ? [BoxShadow(color: const Color(0xFF0D47A1).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            size: 20,
                            color: isActive ? Colors.white : (provider.isDarkMode ? Colors.white70 : const Color(0xFF45464D)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.tr(item['label']),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isActive ? Colors.white : (provider.isDarkMode ? Colors.white70 : const Color(0xFF45464D)),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item['id'] == 'pos' && provider.cartTotalItems > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.white : const Color(0xFF0D47A1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.cartTotalItems}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? const Color(0xFF0D47A1) : Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Sidebar Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: provider.isDarkMode ? const Color(0xFF0B1C30) : const Color(0xFFF8F9FF),
              border: Border(
                top: BorderSide(
                  color: provider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Theme Toggle
                InkWell(
                  onTap: () => provider.toggleDarkMode(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: provider.isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              size: 16,
                              color: const Color(0xFF0D47A1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.isDarkMode ? (provider.language == 'Indonesia' ? 'Gelap' : 'Dark') : (provider.language == 'Indonesia' ? 'Terang' : 'Light'),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: provider.isDarkMode ? Colors.black26 : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            provider.isDarkMode ? 'DARK' : 'LIGHT',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cashier Info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: provider.isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF0D47A1),
                        child: Text(
                          provider.storeProfile.cashierName.isNotEmpty ? provider.storeProfile.cashierName[0].toUpperCase() : 'K',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.storeProfile.cashierName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: provider.isDarkMode ? Colors.white : const Color(0xFF0B1C30),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(provider.language == 'Indonesia' ? 'Kasir Aktif' : 'Active Cashier', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(PosProvider provider) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: provider.isDarkMode ? const Color(0xFF12253C) : Colors.white,
        border: Border(
          top: BorderSide(
            color: provider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isActive = _selectedIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              width: 65,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isActive ? 18 : 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF0D47A1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'],
                          size: 20,
                          color: isActive ? Colors.white : Colors.grey,
                        ),
                      ),
                      if (item['id'] == 'pos' && provider.cartTotalItems > 0 && !isActive)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle),
                            child: Text(
                              '${provider.cartTotalItems}',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.tr(item['label']),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? const Color(0xFF0D47A1) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
