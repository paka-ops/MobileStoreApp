// dart
import 'person.dart';

class Employee extends Person {
  final String? jobTitle;
  final double? salary;
  final String? storeId;

  Employee({
    required String id,
    required String firstname,
    required String lastname,
    required String username,
    String? email,
    String? phone,
    this.jobTitle,
    this.salary,
    this.storeId,
  }) : super(id: id, firstname: firstname, lastname: lastname, email: email, phone: phone,username: username);

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'] as String,
    firstname: json['firstname'] as String? ?? '',
    lastname: json['secondName'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    username: json['username'] as String? ?? '',
    jobTitle: json['jobTitle'] as String? ?? json['job_title'] as String?,
    salary: (json['salary'] != null) ? (json['salary'] as num).toDouble() : null,
    storeId: json['storeId'] as String? ?? json['store_id'] as String?,
  );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'jobTitle': jobTitle,
      'salary': salary,
      'storeId': storeId,
    });
    return map;
  }
}
