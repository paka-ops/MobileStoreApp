
class Stock{
  String id;
  double totalSell;
  double baseStock;
  double buyingPrice;
  double sellingPrice;
  String? productId;
  double? previousStock;
  DateTime? date;
   Stock({
    required this.id,
    required this.totalSell,
    required this.baseStock,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.date,
     this.productId,
     this.previousStock
  });
   factory Stock.fromJson(Map<String,dynamic>? json)=>Stock(
       id: json?['id'],
       totalSell: json?['totalSell'] ??0.0,
       baseStock: json?['baseStock']??0.0,
       buyingPrice: json?['buyingPrice']??0.0,
       sellingPrice: json?['sellingPrice']??0.0,
       date: DateTime.parse(json?['date'] ?? DateTime.now().toIso8601String()),
       productId: json?['productId'],
       previousStock: json?['previousStock']

   );
}