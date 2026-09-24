class Withdrawal {
  String? id;
  double amount;
  String message;
  DateTime date;
  Withdrawal({this.id, required this.amount , required this.message,required this.date});
  factory Withdrawal.fromJson(Map<String,dynamic> json)=>
      Withdrawal(
        id: json["id"],
        amount: parseAmount(json["amount"]),
        message: json["message"] ?? "",
        date: parseServerDate(json["date"]),
      );
  Map<String,dynamic> toJson()=>{
    "amount" : amount,
    "message" : message,
    "date" : date.toIso8601String()
  };

  /// Le serveur peut renvoyer le montant en nombre ou en chaîne.
  static double parseAmount(dynamic value){
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  /// Le serveur peut renvoyer la date en ISO-8601 (String) ou en timestamp
  /// (numérique) : on accepte les deux formats.
  static DateTime parseServerDate(dynamic value){
    if (value is DateTime) return value;
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }
}
