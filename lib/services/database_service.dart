import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/drink_data.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _userCollection =
      Firestore.instance.collection("users");

  final Map<int, int> _emptyLifetimeConsumptions = {
    DrinkType.Coffee: 0,
    DrinkType.Tea: 0
  };

  List<DrinkData> _mapConsumedDrinks(DocumentSnapshot snapshot) {
    List<dynamic> consumedDrinks = snapshot.data['consumedDrinks'];
    if (consumedDrinks == null) {
      return new List<DrinkData>();
    }

    return consumedDrinks.map((data) => DrinkData.fromMap(data)).toList();
  }

  Map<int, int> _mapLifetimeConsumptions(DocumentSnapshot snapshot) {
    Map<dynamic, dynamic> lifetimeConsumptions =
        snapshot.data['lifetimeConsumptions'];

    return lifetimeConsumptions != null
        ? lifetimeConsumptions
            .map((type, amount) => MapEntry<int, int>(int.parse(type), amount))
        : Map<int, int>.from(_emptyLifetimeConsumptions);
  }

  UserData _mapUserData(DocumentSnapshot snapshot) {
    return snapshot != null && snapshot.data != null
        ? new UserData(
            uid: snapshot.documentID,
            displayName: snapshot.data['displayName'] ?? '',
            consumedDrinks: _mapConsumedDrinks(snapshot),
            lastConsumedDrink:
                DrinkData.fromMap(snapshot.data['lastConsumedDrink']),
            lifetimeConsumptions: _mapLifetimeConsumptions(snapshot))
        : null;
  }

  Stream<UserData> userData(String uid) {
    return _userCollection.document(uid).snapshots().map(_mapUserData);
  }

  Future<DatabaseResponse> updateUserData(String uid,
      {String displayName,
      List<DrinkData> consumedDrinks,
      DrinkData lastConsumedDrink,
      Map<int, int> lifetimeConsumptions}) async {
    Map<String, dynamic> data = new Map();
    if (displayName != null) {
      data['displayName'] = displayName;
    }

    if (consumedDrinks != null) {
      data['consumedDrinks'] =
          consumedDrinks.map((drink) => drink.toMap()).toList();
    }

    if (lastConsumedDrink != null) {
      data['lastConsumedDrink'] = lastConsumedDrink.toMap();
    }

    if (lifetimeConsumptions != null) {
      data['lifetimeConsumptions'] = lifetimeConsumptions.map((type, amount) {
        return MapEntry(type.toString(), amount);
      });
    }

    try {
      await _userCollection.document(uid).setData(data);
      return new DatabaseResponse(data: null, errorMessage: null);
    } catch (e) {
      print('updateUserData failed: $e');
      return new DatabaseResponse(
          data: null,
          errorMessage: new ErrorMessage(message: "Something went wrong"));
    }
  }

  Future<DatabaseResponse> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _userCollection.document(uid).get();
      return new DatabaseResponse(data: _mapUserData(doc), errorMessage: null);
    } catch (e) {
      print('getUserData failed: $e');
      return new DatabaseResponse(
          data: null,
          errorMessage: new ErrorMessage(message: "Something went wrong"));
    }
  }
}
