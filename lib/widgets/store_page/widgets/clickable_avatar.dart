/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/employee.dart';

class ClickableAvatar extends StatelessWidget{
  final Employee emp;
  final String userType;
  const ClickableAvatar({super.key, required this.emp, required this.userType});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onLongPress: () {
        // On n'affiche les options que si l'utilisateur est un "employer" (admin)
        if (userType == "employer") {
          _showEmployeeOptions(context, emp);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              emp.username ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

 */