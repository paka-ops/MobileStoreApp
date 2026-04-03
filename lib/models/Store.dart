

import 'package:mobile_store_app/models/subscription.dart';

class Store {
  final String id;
  final String name;
  final String? employerId;
  final String? location;
  final List<String>? productIds;
  Subscription? subscription;

  Store({
    required this.id,
    required this.name,
    this.location,
    this.employerId,
    this.productIds,
    this.subscription
  });

  factory Store.fromJson(Map<String, dynamic> json) =>  Store(
    id: json['id'] ,
    name: json['name'] as String? ?? '',
    location: json['location'] as String?,
    employerId: json['employerId'] as String? ?? json['employer_id'] as String?,
    productIds: (json['productIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
    subscription:json['subscription']==null?null: Subscription.fromJson(json['subscription'])
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'employerId': employerId,
    'productIds': productIds,
  };
}
