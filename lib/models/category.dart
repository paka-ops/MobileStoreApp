// dart
import 'package:mobile_store_app/models/product.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  List<Product> products = [];

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'description': description,
      };
}
