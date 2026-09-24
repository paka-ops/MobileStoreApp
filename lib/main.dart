import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/widgets/common/app_background.dart';
import 'package:mobile_store_app/screens/login_screen.dart';
import 'package:mobile_store_app/screens/welcome_screen_before_login.dart';

import 'models/Store.dart';
import 'utils/app_colors.dart';

// Clé globale du ScaffoldMessenger (snackbars au-dessus de tout)
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "BouTiKa",
        theme: buildAppTheme(false),
        darkTheme: buildAppTheme(true),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        // Toile de fond unique : dégradé lavande derrière toutes les pages
        // (les écrans utilisent un Scaffold transparent).
        builder: (context, child) => AppBackground(
          child: child ?? const SizedBox.shrink(),
        ),
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        initialRoute: "/",
        routes: {
          "/": (context) => WelcomePreLoginScreen(),
          "/login": (context) => LoginScreen(),
        },
      ),
    );
  }
}
