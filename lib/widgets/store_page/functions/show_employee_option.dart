/*import 'package:flutter/material.dart';

import '../../../models/employee.dart';

void _showEmployeeOptions(BuildContext context, Employee emp) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("Supprimer l'employé"),
          onTap: () {
            Navigator.pop(context);
            _confirmDeleteEmployee(context, emp);
          },
        ),
      ],
    ),
  );
}

 */