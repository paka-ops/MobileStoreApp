// dart
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/stock.dart';

class Product {
  final String id;
  final String name;
  double? buyingPrice;
  double? sellingPrice;
  double? quantity;
  final Category? category;
  final Stock? stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.stock
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    category: Category.fromJson(json['categoryDto']),
    stock: Stock.fromJson(json['stock'] as Map<String,dynamic>? ?? null)
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'buyingPrice': buyingPrice,
    'sellingPrice': sellingPrice,
    'stock': quantity,
  };
}
