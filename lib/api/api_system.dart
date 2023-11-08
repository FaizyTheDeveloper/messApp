import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mess_app/models/user_chat.dart';

class APISystem {
  //to store self information
  static UserChat me = UserChat(
    image: user.photoURL.toString(),
    name: user.displayName.toString(),
    about: 'Hey I\'m using MessApp',
    lastActive: '',
    isOnline: false,
    id: user.uid,
    createAt: '',
    email: user.email,
    pushToken: '',
  );

  //to return current user
  static get user => auth.currentUser!;

  //for authentication on google
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing storage firebase
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for checking user is exist or not
  static Future<bool> isUserExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for getting currnet user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) {
      if (user.exists) {
        me = UserChat.fromJson(user.data()!);
        print('My data : ${user.data()}');
      } else {
        userCreate().then(
          (user) => getSelfInfo(),
        );
      }
    });
  }

  //to create new user
  static Future<void> userCreate() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = UserChat(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: 'Hey I\'m using MessApp',
      lastActive: time,
      isOnline: false,
      id: user.uid,
      createAt: time,
      email: user.email,
      pushToken: '',
    );

    return firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  //TO GET ALL USERS FROM DATABASE
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for checking user is exist or not
  static Future<void> updateUserExist() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfileImage(File file) async {
    final extension = file.path.split('.').last;

    print('extension : $extension');

    final ref = storage.ref().child('profilepictures/${user.uid}.$extension');

    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$extension'))
        .then((p0) {
      print('data transmitted : ${p0.bytesTransferred / 1000} kb');
    });

    me.image = await ref.getDownloadURL();

    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }



  //********************used for chat purpose******************//


  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
    return firestore
        .collection('messages')
        .snapshots();
  }


}
