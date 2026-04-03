class Subscription{
  DateTime? startDate;
  DateTime? expirationDate;
  String? duration;
  String? plan;
  Subscription({required this.startDate,required this.duration,required this.expirationDate,required this.plan});
   factory Subscription.fromJson(Map<String,dynamic> json)=>Subscription(
    startDate: DateTime.parse(json['startDate']),
    expirationDate: DateTime.parse(json['expirationDate']) ,
    duration: json['duration'],
    plan: json['plan']
  );
}