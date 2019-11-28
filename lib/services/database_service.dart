import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/constants/group_invitation_status.dart';
import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/drink_data.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/models/group_invitation.dart';
import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:cafeine_me_up/models/group_tuple.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final CollectionReference _userCollection =
      Firestore.instance.collection('users');

  final CollectionReference _groupCollection =
      Firestore.instance.collection('groups');

  final CollectionReference _groupInvitationCollection =
      Firestore.instance.collection('groupInvitations');

  final Map<int, int> _emptyLifetimeConsumptions = {
    DrinkType.Coffee: 0,
    DrinkType.Tea: 0
  };

  List<DrinkData> _mapConsumedDrinks(List<dynamic> consumedDrinks) {
    if (consumedDrinks == null) {
      return new List<DrinkData>();
    }

    return consumedDrinks.map((data) => DrinkData.fromMap(data)).toList();
  }

  Map<int, int> _mapLifetimeConsumptions(
      Map<dynamic, dynamic> lifetimeConsumptions) {
    return lifetimeConsumptions != null
        ? lifetimeConsumptions
            .map((type, amount) => MapEntry<int, int>(int.parse(type), amount))
        : Map<int, int>.from(_emptyLifetimeConsumptions);
  }

  List<GroupTuple> _mapUserGroups(List<dynamic> groups) {
    return groups != null
        ? groups.map((data) => GroupTuple.fromMap(data)).toList()
        : new List<GroupTuple>();
  }

  List<GroupMemberData> _mapGroupMembers(DocumentSnapshot snapshot) {
    List<dynamic> members = snapshot.data['members'];

    if (members == null) {
      return new List<GroupMemberData>();
    }

    return members.map((member) {
      Map<dynamic, dynamic> userData = member['userData'];

      return new GroupMemberData(
          role: member['role'],
          userData: new UserData(
              uid: member['userId'],
              displayName: userData['displayName'] ?? '',
              avatar: userData['avatar'] ?? '',
              consumedDrinks: _mapConsumedDrinks(userData['consumedDrinks']),
              lastConsumedDrink:
                  DrinkData.fromMap(userData['lastConsumedDrink']),
              lifetimeConsumptions:
                  _mapLifetimeConsumptions(userData['lifetimeConsumptions']),
              groups: _mapUserGroups(userData['groups'])));
    }).toList();
  }

  UserData _mapUserData(DocumentSnapshot snapshot) {
    return snapshot != null && snapshot.data != null
        ? new UserData(
            uid: snapshot.documentID,
            displayName: snapshot.data['displayName'] ?? '',
            avatar: snapshot.data['avatar'] ?? '',
            consumedDrinks: _mapConsumedDrinks(snapshot.data['consumedDrinks']),
            lastConsumedDrink:
                DrinkData.fromMap(snapshot.data['lastConsumedDrink']),
            lifetimeConsumptions:
                _mapLifetimeConsumptions(snapshot.data['lifetimeConsumptions']),
            groups: _mapUserGroups(snapshot.data['groups']))
        : null;
  }

  GroupData _mapGroupData(DocumentSnapshot snapshot) {
    return snapshot != null && snapshot.data != null
        ? new GroupData(
            groupId: snapshot.documentID,
            groupName: snapshot.data['groupName'] ?? '',
            members: _mapGroupMembers(snapshot))
        : null;
  }

  List<GroupInvitation> _mapGroupInviation(DocumentSnapshot snapshot) {
    List<GroupInvitation> result = new List<GroupInvitation>();
    if (snapshot == null || snapshot.data == null) {
      return result;
    }

    snapshot.data.forEach((groupId, invitation) {
      int status = invitation['status'] ?? GroupInvitationStatus.Unknown;
      if (status == GroupInvitationStatus.Open) {
        result.add(new GroupInvitation(
            groupId: groupId,
            groupName: invitation['groupName'] ?? '',
            status: invitation['status'] ?? -1));
      }
    });
    return result;
  }

  Map<String, dynamic> _createUserMap(
      {String displayName,
      String avatar,
      List<DrinkData> consumedDrinks,
      DrinkData lastConsumedDrink,
      Map<int, int> lifetimeConsumptions,
      List<GroupTuple> groups}) {
    Map<String, dynamic> data = new Map();
    if (displayName != null) {
      data['displayName'] = displayName;
    }

    if(avatar != null) {
      data['avatar'] = avatar;
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

  Stream<GroupData> groupData(String groupId) {
    return _groupCollection.document(groupId).snapshots().map(_mapGroupData);
  }

  Stream<List<GroupInvitation>> groupInvitations(String uid) {
    return _groupInvitationCollection
        .document(uid)
        .snapshots()
        .map(_mapGroupInviation);
  }

  Future<DatabaseResponse> updateUserData(String uid,
      {String displayName,
      String avatar,
      List<DrinkData> consumedDrinks,
      DrinkData lastConsumedDrink,
      Map<int, int> lifetimeConsumptions}) async {
    Map<String, dynamic> data = _createUserMap(
        displayName: displayName,
        avatar: avatar,
        consumedDrinks: consumedDrinks,
        lastConsumedDrink: lastConsumedDrink,
        lifetimeConsumptions: lifetimeConsumptions);

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

  Future<DatabaseResponse> updateGroupInvitationStatus(
      {@required String uid,
      @required String groupId,
      @required int newStatus}) async {
    try {
      await _groupInvitationCollection.document(uid).setData({
        groupId: {'status': newStatus}
      }, merge: true);

      return new DatabaseResponse(data: null, errorMessage: null);
    } catch (e) {
      print(e);
      return new DatabaseResponse(
          data: null,
          errorMessage: new ErrorMessage(message: "Something went wrong"));
    }
  }
}
