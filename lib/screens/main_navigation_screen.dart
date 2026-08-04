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

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PosScreen(),
    StockScreen(),
    ReportsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Row(
        children: [
          if (isLandscape) ...[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Badge(
                    label: Text('${provider.cartTotalItems}'),
                    isLabelVisible: provider.cartTotalItems > 0,
                    child: const Icon(Icons.point_of_sale),
                  ),
                  label: const Text('Kasir'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.inventory_2),
                  label: Text('Stok'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.bar_chart),
                  label: Text('Laporan'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.receipt_long),
                  label: Text('Riwayat'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Pengaturan'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isLandscape
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0D47A1),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${provider.cartTotalItems}'),
                    isLabelVisible: provider.cartTotalItems > 0,
                    child: const Icon(Icons.point_of_sale),
                  ),
                  label: 'Kasir',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2),
                  label: 'Stok',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Laporan',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Riwayat',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Pengaturan',
                ),
              ],
            ),
    );
  }
}
