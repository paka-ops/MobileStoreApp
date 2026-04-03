

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/login_screen.dart';
import 'package:mobile_store_app/screens/welcome_screen_before_login.dart';

import 'models/Store.dart';
// Crée cette clé en dehors de tes classes (variable globale)
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
main() {

  runApp(const MyApp());
}
class MyApp extends StatefulWidget{
  const MyApp();
  @override
  State createState() => _MyAppState();
}
class _MyAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Store.dart App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => WelcomePreLoginScreen(),
        "/login": (context) => LoginScreen(),
      },
    );
  }
}
