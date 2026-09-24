class Withdrawal{
  String? id;
  double amount;
  String message;
  DateTime date;
  Withdrawal({this.id, required this.amount , required this.message,required this.date});
  factory Withdrawal.fromJson(Map<String,dynamic> json)=>
      Withdrawal(id: json["id"], amount: json["amount"], message: json["message"], date: json["date"]);
  Map<String,dynamic> toJson()=>{
    "amount" : amount,
    "message" : message,
    "date" : date
  };
}