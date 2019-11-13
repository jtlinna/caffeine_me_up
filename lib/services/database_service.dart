import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference _userCollection =
      Firestore.instance.collection("users");

  UserData _mapUserData(DocumentSnapshot snapshot) {
    return snapshot != null && snapshot.data != null
        ? new UserData(displayName: snapshot.data['displayName'] ?? '')
        : null;
  }

  Stream<UserData> userData(String uid) {
    return _userCollection.document(uid).snapshots().map(_mapUserData);
  }

  Future<DatabaseResponse> updateUserData(String uid,
      {String displayName}) async {
    Map<String, dynamic> data = new Map();
    if (displayName != null) {
      data['displayName'] = displayName;
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
