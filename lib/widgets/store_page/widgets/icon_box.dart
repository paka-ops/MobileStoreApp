import 'package:flutter/cupertino.dart';

/**
 * Class for drawer Icon Decoration;
 */
class IconBox extends StatelessWidget{
  IconData icon;

  Color color;

  IconBox({required IconData this.icon, required Color this.color});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}