

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/category_detail_screen.dart';
import 'package:mobile_store_app/screens/category_list_screen.dart';
import 'package:mobile_store_app/screens/login_screen.dart';
import 'package:mobile_store_app/screens/store_page.dart';
import 'package:mobile_store_app/screens/welcome_screen.dart';
import 'package:mobile_store_app/screens/welcome_screen_before_login.dart';

import 'models/Store.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget{
  const MyApp();
  @override
  State createState() => _MyAppState();
}
class _MyAppState extends State<MyApp>{
 var store = Store(
  id: "dsqfjlk",
  name: 'Magasin Central Kara',
  location: 'Grand Marché de Kara',
  productIds: ['p5', 'p6'],
  );
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
        "/store": (context) => StoreDetailScreen(store: store),
        "/categories" : (context) => CategoryListScreen(),
      },
    );
  }
}
