/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/employee.dart';

class EmployerSelection extends StatelessWidget{
  BuildContext context;
  List<Employee> employees;
  String userType;

  EmployerSelection({required this.context,super.key,required this.employees,required this.userType});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Équipe de vente",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (employees.isEmpty)
                  const Text(
                    "Aucun employé",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                else
                  ...employees.map((emp) => _buildClickableAvatar(context, emp)),

                if (userType == "employer")
                  IconButton(
                    onPressed: () => _showAddEmployeeForm(context),
                    icon: const Icon(
                      Icons.add_circle,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

 */