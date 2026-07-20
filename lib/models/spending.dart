import 'package:mobile_store_app/models/person.dart';

class Spending{
  String? id;
  String? description;
  double? price;
  Person? person;
  String? storeId;
  DateTime? createdAt;

  Spending({this.id,this.description ,this.price, this.person, this.createdAt,this.storeId});
  factory Spending.fromJson(Map<String,dynamic> json){
    return Spending(
      id: json["id"],
      description: json["description"],
      price: json["price"],
      person: Person.fromJson(json["person"]),
      storeId: json['storeId'],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  Map<String,dynamic> toJson()=>{
  "description":description,
  "price":price,
    "storeId":storeId,
  };

}