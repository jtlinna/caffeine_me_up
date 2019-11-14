import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/utils/formatters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrinkData {
  int type;
  DateTime consumedAt;

  DrinkData({this.type, this.consumedAt});

  static DrinkData fromMap(Map<dynamic, dynamic> data) {
    return data == null
        ? null
        : new DrinkData(
            type: data['type'],
            consumedAt: (data['consumedAt'] as Timestamp).toDate());
  }

  Map toMap() {
    Map map = new Map();
    map['type'] =  type;
    map['consumedAt'] =  Timestamp.fromDate(consumedAt);
    return map;
  }

  @override
  String toString() =>
      'Drink ${DrinkType.asString(type)} -- Consumed at ${formatDateTime(consumedAt)}';
}
