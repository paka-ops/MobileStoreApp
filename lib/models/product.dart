// dart
class Product {
  final String id;
  final String name;
  final double? price;
  final int? quantity;

  Product({
    required this.id,
    required this.name,
    this.price,
    this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    price: (json['price'] != null) ? (json['price'] as num).toDouble() : null,
    quantity: (json['quantity'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': quantity,
  };
}
