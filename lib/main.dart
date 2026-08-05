import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pos_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/setup_store_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PosProvider(),
      child: const KasirkuApp(),
    ),
  );
}

class KasirkuApp extends StatefulWidget {
  const KasirkuApp({super.key});

  @override
  State<KasirkuApp> createState() => _KasirkuAppState();
}

class _KasirkuAppState extends State<KasirkuApp> {
  String _currentAuthView = 'login'; // 'login' or 'setup'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PosProvider>(context);

    Widget home;
    if (!provider.isLoggedIn) {
      if (!provider.storeProfile.isConfigured && _currentAuthView == 'setup') {
        home = SetupStoreScreen(onSwitchToLogin: () => setState(() => _currentAuthView = 'login'));
      } else {
        home = LoginScreen(onSwitchToSetup: () => setState(() => _currentAuthView = 'setup'));
      }
    } else {
      home = const MainNavigationScreen();
    }

    return MaterialApp(
      title: 'Kasirku POS',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FF),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF0D47A1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1C30),
      ),
      home: home,
    );
  }
}
