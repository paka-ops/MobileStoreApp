import 'package:mobile_store_app/models/person.dart';

class Withdrawal {
  String? id;
  String? description;
  double? price;
  Person? person;
  String? storeId;
  DateTime? createdAt;

  Withdrawal({
    this.id,
    this.description,
    this.price,
    this.person,
    this.storeId,
    this.createdAt,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      person: json['person'] != null
          ? Person.fromJson(Map<String, dynamic>.from(json['person']))
          : null,
      storeId: json['storeId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'price': price,
        'storeId': storeId,
      };
}

typedef Withdrawall = Withdrawal;
