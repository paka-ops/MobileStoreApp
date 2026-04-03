// dart
import 'dart:convert';

import 'package:mobile_store_app/models/enums.dart';
import 'package:mobile_store_app/models/product.dart';

import 'order_content.dart';

class Order {
  String orderId;
  String storeId;
  Map<dynamic,dynamic> maker;
  DateTime createdAt;
  OrderStatus status;
  Map<Product,dynamic> products = {};

  Order({
    required this.orderId,
    required this.storeId,
   required  this.createdAt,
    required this.maker,
    required this.status,
  });

  factory Order.fromJson(Map<dynamic, dynamic> json) {
    return Order(
      orderId: json['id'] ,
      maker: json['maker']  ,
      createdAt: DateTime.parse(json['creationDate'] as String) ,
      storeId: json['store']['id'] ,
      status: OrderStatus.values.firstWhere((element) => element.name == json['status'])
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'makerId': maker,
    'createdAt': createdAt?.toIso8601String(),
    'storeId': storeId,
    'status': status
  };
}
