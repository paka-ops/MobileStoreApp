// dart
import 'person.dart';

class Employer extends Person {
  final String? companyName;

  Employer({
    required String id,
    required String firstname,
    required String lastname,
    String? email,
    String? phone,
    this.companyName,
  }) : super(id: id, firstname: firstname, lastname: lastname, email: email, phone: phone);

  factory Employer.fromJson(Map<String, dynamic> json) => Employer(
    id: json['id'] as String,
    firstname: json['firstname'] as String? ?? '',
    lastname: json['lastname'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    companyName: json['companyName'] as String? ?? json['company_name'] as String?,
  );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['companyName'] = companyName;
    return map;
  }
}
