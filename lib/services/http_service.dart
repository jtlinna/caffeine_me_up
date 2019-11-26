import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class HttpService {
  final HttpsCallable _createGroupHandle =
      CloudFunctions(region: 'europe-west2')
          .getHttpsCallable(functionName: 'createGroup');

  final HttpsCallable _inviteUserHandle = CloudFunctions(region: 'europe-west2')
      .getHttpsCallable(functionName: 'inviteUser');

  final HttpsCallable _updateGroupDataHandle =
      CloudFunctions(region: 'europe-west2')
          .getHttpsCallable(functionName: 'updateGroupData');

  final HttpsCallable _deleteUserHandle = CloudFunctions(region: 'europe-west2')
      .getHttpsCallable(functionName: 'deleteUser');

  Future<ErrorMessage> createGroup({String groupName, bool isPrivate}) async {
    try {
      HttpsCallableResult result = await _createGroupHandle
          .call({'groupName': groupName, 'isPrivate': isPrivate});
      print('createGroup: Got result : ${result.data}');
      switch (result.data['status']) {
        case 0:
          return null;
        case -1:
          return new ErrorMessage(
              message: 'Only verified users are allowed to create groups');
        case -2:
          return new ErrorMessage(message: 'Invalid group name');
        case -3:
          return new ErrorMessage(
              message: 'Group with name $groupName already exists');
        default:
          return new ErrorMessage(message: 'Something went wrong');
      }
    } on CloudFunctionsException catch (e) {
      print(
          'createGroup: Got error: Code ${e.code} -- Msg ${e.message} -- Details ${e.details}');
      return new ErrorMessage(message: 'Something went wrong');
    } catch (e) {
      print('createGroup: Got error: $e');
      return new ErrorMessage(message: 'Something went wrong');
    }
  }

  Future<ErrorMessage> inviteUser({String email, String groupId}) async {
    try {
      HttpsCallableResult result =
          await _inviteUserHandle.call({'email': email, 'groupId': groupId});
      print('inviteUser: Got result : ${result.data}');
      switch (result.data['status']) {
        case 0:
          return null;
        case -1:
          return new ErrorMessage(message: 'No user found with e-mail $email');
        case -2:
          return new ErrorMessage(
              message: 'Only admins are allowed to invite new users');
        case -3:
          return new ErrorMessage(message: 'User already in the group');
        case -4:
          return new ErrorMessage(
              message: 'User $email has already been invited to this group');
        default:
          return new ErrorMessage(message: 'Something went wrong');
      }
    } on CloudFunctionsException catch (e) {
      print(
          'inviteUser: Got error: Code ${e.code} -- Msg ${e.message} -- Details ${e.details}');
      return new ErrorMessage(message: 'Something went wrong');
    } catch (e) {
      print('inviteUser: Got error: $e');
      return new ErrorMessage(message: 'Something went wrong');
    }
  }

  Future<ErrorMessage> updateGroupData(
      {@required String groupId, String groupName}) async {
    try {
      HttpsCallableResult result = await _updateGroupDataHandle
          .call({'groupId': groupId, 'groupName': groupName});
      print('updateGroupData: Got result : ${result.data}');
      switch (result.data['status']) {
        case 0:
          return null;
        case -1:
          return new ErrorMessage(message: 'Invalid permissions');
        default:
          return new ErrorMessage(message: 'Something went wrong');
      }
    } on CloudFunctionsException catch (e) {
      print(
          'updateGroupData: Got error: Code ${e.code} -- Msg ${e.message} -- Details ${e.details}');
      return new ErrorMessage(message: 'Something went wrong');
    } catch (e) {
      print('updateGroupData: Got error: $e');
      return new ErrorMessage(message: 'Something went wrong');
    }
  }

  Future<ErrorMessage> deleteUser() async{
    
    try {
      HttpsCallableResult result = await _deleteUserHandle
          .call();
      print('deleteUser: Got result : ${result.data}');
      switch (result.data['status']) {
        case 0:
          return null;
        case -1:
          return new ErrorMessage(message: 'Cannot delete account while owner of one or more groups');
        default:
          return new ErrorMessage(message: 'Something went wrong');
      }
    } on CloudFunctionsException catch (e) {
      print(
          'deleteUser: Got error: Code ${e.code} -- Msg ${e.message} -- Details ${e.details}');
      return new ErrorMessage(message: 'Something went wrong');
    } catch (e) {
      print('deleteUser: Got error: $e');
      return new ErrorMessage(message: 'Something went wrong');
    }
  }
}
