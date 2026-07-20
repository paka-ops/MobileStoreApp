/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/employee.dart';
import '../../../service/employee_service.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../utils/message.dart';

void _confirmDeleteEmployee({required BuildContext context,required Employee emp,required bool isDeletingEmployee}) {
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(builder: (stContext,setDelEmployeeState){
      return AlertDialog(
        title: const Text("Confirmation"),
        content: Text("Voulez-vous vraiment supprimer ${emp.username} ?"),
        actions: [
          TextButton(onPressed:
              (){
            setDelEmployeeState(()=>isDeletingEmployee = false);
            Navigator.pop(context);
          }, child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed:isDeletingEmployee?null : () async {
              setDelEmployeeState(()=>isDeletingEmployee =true);
              EmployeeService empService = EmployeeService();
              bool deleted = await empService.deleteEmployee(emp,context);
              setDelEmployeeState(()=> isDeletingEmployee = false);
              if(deleted == true){
                showSuccessMessage("employée ${emp.username} est supprimé de votre boutique", context);
              }
              Navigator.pop(context);
              _fetchAllData();
            },
            child:isDeletingEmployee?CircularProgressIndicator(): const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }),
  );
}

 */