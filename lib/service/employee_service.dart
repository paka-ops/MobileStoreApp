
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/employee.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
class EmployeeService{
  String? token = UserService().getToken();
  String baseUrl = UserService.baseUrl;
  Future<List<Employee>> getEmployeeOfStore(String storeId,BuildContext context) async{
    try{
      var response = await http.get(
          Uri.parse("$baseUrl/v1/employee?storeId=$storeId"),
          headers: {
            "Authorization": "Bearer $token"
          }
      ).timeout(Duration(seconds: 15));
     if(response.statusCode == 200){
       Map<dynamic,dynamic> body = jsonDecode(response.body );
       List<dynamic> employeeList = body.values.first;
       List<Employee> employees = [];
       employeeList.forEach((e){
         Employee employee = Employee.fromJson(e);
         employees.add(employee);
       });
       return employees;
     }else if(response.statusCode == 402){
       showSubscriptionExpiredMessage(context);
     }
     return[];
    }catch(e){
      showExceptionMessage(context);
      throw Exception();
    }

}
Future<Employee?>  addEmployee(Map<String,dynamic> employee,String storeId,BuildContext context) async{
  try{
    var req = jsonEncode(employee);
    var response = await http.post(
        Uri.parse("$baseUrl/v1/employee?storeId=$storeId"),
        body: req,
        headers: {
          "Authorization" : "Bearer $token",
          "content-type" :"application/json"
        }
    ).timeout(Duration(seconds: 15));
    if(response.statusCode == 201) {
      String res = response.body;
      Map<String, dynamic> employeeMap = jsonDecode(response.body);
      Employee savedEmployee = Employee.fromJson(employeeMap.values.first);
      return savedEmployee;
    }else if(response.statusCode == 402){
      showSubscriptionExpiredMessage(context);
      return null;
    }
  }catch(e){
    showExceptionMessage(context);
    throw Exception();
  }
  return null;


}
Future<bool> deleteEmployee(Employee emp,BuildContext context) async{
  try{
    var response  = await http.delete(Uri.parse("$baseUrl/v1/employee/${emp.id}"),headers: {
      "Authorization": "Bearer $token"
    }).timeout(Duration(seconds: 15));
    if(response.statusCode == 204){
      return true;
    }else if(response.statusCode == 402){
      showSubscriptionExpiredMessage(context);
    }
    return false;
  }catch(e){
    showExceptionMessage(context);
    throw Exception(e);
  }

  }

}