import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/drink_data.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/group_tuple.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _userCollection =
      Firestore.instance.collection('users');

  final CollectionReference _groupCollection =
      Firestore.instance.collection('groups');

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

  Map<String, dynamic> _createUserMap(
      {String displayName,
      List<DrinkData> consumedDrinks,
      DrinkData lastConsumedDrink,
      Map<int, int> lifetimeConsumptions,
      List<GroupTuple> groups}) {
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

    if (groups != null) {
      data['groups'] = groups.map((group) {
        return group.toMap();
      }).toList();
    }

    return data;
  }

  Stream<UserData> userData(String uid) {
    return _userCollection.document(uid).snapshots().map(_mapUserData);
  }

  Future<DatabaseResponse> updateUserData(String uid,
      {String displayName,
      List<DrinkData> consumedDrinks,
      DrinkData lastConsumedDrink,
      Map<int, int> lifetimeConsumptions,
      List<GroupTuple> groups}) async {
    Map<String, dynamic> data = _createUserMap(
        displayName: displayName,
        consumedDrinks: consumedDrinks,
        lastConsumedDrink: lastConsumedDrink,
        lifetimeConsumptions: lifetimeConsumptions,
        groups: groups);

    try {
      await _userCollection.document(uid).setData(data, merge: true);
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

  Future<DatabaseResponse> createGroup(
      UserData creator, String groupName, bool isPrivate) async {
    try {
      String id = groupName.toLowerCase().trim().replaceAll(' ', '-');
      print(id);
      DocumentSnapshot existingGroup =
          await _groupCollection.document(id).get();
      print(existingGroup.data);
      if (existingGroup.data != null) {
        return new DatabaseResponse(
            data: null,
            errorMessage: new ErrorMessage(
                message: 'Group with name $groupName already exists'));
      }
      
      List<GroupTuple> userGroups = [GroupTuple(id: id, name: groupName)];
      Map<String, dynamic> userData = _createUserMap(
          displayName: creator.displayName,
          consumedDrinks: creator.consumedDrinks,
          lastConsumedDrink: creator.lastConsumedDrink,
          lifetimeConsumptions: creator.lifetimeConsumptions,
          groups: userGroups);

      Map<String, dynamic> groupData = {
        'groupName': groupName,
        'isPrivate': isPrivate,
        'members': [
          {'role': UserRole.Admin, 'userId': creator.uid, 'userData': userData}
        ]
      };

      await _groupCollection.document(id).setData(groupData);

      return updateUserData(creator.uid, groups: userGroups);
    } catch (e) {
      print(e);
      return new DatabaseResponse(
          data: null,
          errorMessage: new ErrorMessage(message: "Something went wrong"));
    }
  }
}
