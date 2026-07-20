import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_store_app/widgets/store_page/widgets/icon_box.dart';

/**
 * Class for drawer items;
 */
class DrawerItem extends StatelessWidget{
  IconData icon;

  String title;

  Color color;

  VoidCallback onTap;

  DrawerItem({
    required IconData this.icon,
    required Color this.color,
    required String this.title,
    required VoidCallback this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: IconBox(icon: icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}