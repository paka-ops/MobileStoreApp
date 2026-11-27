// dart
import 'person.dart';

class Admin extends Person {
  final List<String>? privileges;

  Admin({
    required String id,
    required String firstname,
    required String lastname,
    String? email,
    String? phone,
    this.privileges,
  }) : super(id: id, firstname: firstname, lastname: lastname, email: email, phone: phone);

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    id: json['id'] as String,
    firstname: json['firstname'] as String? ?? '',
    lastname: json['lastname'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    privileges: (json['privileges'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['privileges'] = privileges;
    return map;
  }
}
