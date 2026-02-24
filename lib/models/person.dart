// dart
class Person {
  final String id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phone;
  final String? username;

  Person({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phone,
    this.username
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    firstname: json['firstname'] as String? ?? json['first_name'] as String? ?? '',
    lastname: json['lastname'] as String? ?? json['last_name'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    username: json['username'] as String?
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'username': username
  };
}
