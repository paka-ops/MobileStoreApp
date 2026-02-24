// dart
import 'order_content.dart';

class Order {
  final String id;
  final String? customerId;
  final DateTime? createdAt;
  final String? status;
  final List<OrderContent> contents;
  final double? total;

  Order({
    required this.id,
    this.customerId,
    this.createdAt,
    this.status,
    this.contents = const [],
    this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final list = (json['orderContentDtos'] ?? json['contents'] ?? []) as List<dynamic>;
    final contents = list.map((e) => OrderContent.fromJson(e as Map<String, dynamic>)).toList();
    return Order(
      id: json['id'] as String,
      customerId: json['customerId'] as String? ?? json['customer_id'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      status: json['status'] as String?,
      contents: contents,
      total: (json['total'] != null) ? (json['total'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'createdAt': createdAt?.toIso8601String(),
    'status': status,
    'contents': contents.map((c) => c.toJson()).toList(),
    'total': total,
  };
}
