
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_store_app/models/employee.dart';
import 'package:mobile_store_app/service/user_service.dart';
class EmployeeService{
  String? token = UserService().getToken();
  String baseUrl = UserService.baseUrl;
  Future<List<Employee>> getEmployeeOfStore(String storeId) async{
    var response = await http.get(
      Uri.parse("$baseUrl/v1/employee?storeId=$storeId"),
      headers: {
        "Authorization": "Bearer $token"
      }
    );
    Map<dynamic,dynamic> body = jsonDecode(response.body );
    print("employe = $body");
    List<dynamic> employeeList = body.values.first;
    List<Employee> employees = [];
    employeeList.forEach((e){
      Employee employee = Employee.fromJson(e);
      print("employee repo $e");
      employees.add(employee);
    });
    return employees;
}
Future<Employee>  addEmployee(Map<String,dynamic> employee,String storeId) async{
    var req = jsonEncode(employee);
    var response = await http.post(
      Uri.parse("$baseUrl/v1/employee?storeId=$storeId"),
      body: req,
      headers: {
        "Authorization" : "Bearer $token",
        "content-type" :"application/json"
      }
    );
   String res =  response.body;
    Map<String,dynamic> employeeMap = jsonDecode(response.body);
    Employee savedEmployee = Employee.fromJson(employeeMap.values.first);
    return savedEmployee;

}
}