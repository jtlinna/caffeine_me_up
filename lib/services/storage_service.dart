import 'dart:io';

import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/storage_response.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage();

  Future<StorageResponse> uploadAvatar(
      {@required String uid, @required File avatar}) async {
    try {
      StorageUploadTask task = _firebaseStorage
          .ref()
          .child('avatars/$uid/avatar.png')
          .putFile(avatar);
      StorageTaskSnapshot snapshot = await task.onComplete;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return new StorageResponse(downloadUrl: downloadUrl, errorMessage: null);
    } catch (e) {
      print('uploadAvatar failed : $e');
      return new StorageResponse(
          downloadUrl: null,
          errorMessage: new ErrorMessage(message: 'Something went wrong'));
    }
  }
}
