// dart
import 'package:mobile_store_app/models/stock.dart';

class OrderContent {
  final String orderId;
  final String productId;
  final int qty;
  final Stock? stock;
  OrderContent({
    required this.orderId,
    required this.productId,
    required this.qty,
    required this.stock
  });

  factory OrderContent.fromJson(Map<String, dynamic> json) => OrderContent(
    orderId: json['orderId'] as String? ?? json['order_id'] as String? ?? '',
    productId: json['productId'] as String? ?? json['product_id'] as String? ?? '',
    qty: (json['qty'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 0,
    stock : Stock.fromJson(json['stock'])
  );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'productId': productId,
    'qty': qty,
    'stock': stock
  };
}
