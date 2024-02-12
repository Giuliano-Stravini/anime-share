import 'dart:async';

import 'package:alreadywatched/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider {
  var user = AppUser();

  StreamSubscription? _listener;

  fetchUserSnapshot({required String uid}) {
    if (_listener != null) {
      _listener?.cancel();
    }
    _listener = FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        user.favoriteIds.clear();

        // (doc.data['animes'] as List).forEach((i) {
        //   user.favoriteIds.add(i['id']);
        // });
      }
    });
  }

  updateFavoriteList(int id, String uid) async {
    if (user.favoriteIds.contains(id)) {
      user.favoriteIds.remove(id);
    } else {
      user.favoriteIds.add(id);
    }
    var animes = <Map<String, int>>[];

    user.favoriteIds.forEach((i) {
      animes.add({"id": i});
    });

    await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .update({"animes": animes});
  }

  bool checkFavorite(int id) {
    return user.favoriteIds.contains(id);
  }

  DataStatus isLogged = DataStatus.loading;

  checkUser() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      isLogged = DataStatus.loading;
      if (firebaseUser != null) {
        user.uid = firebaseUser.uid;
        fetchUserSnapshot(uid: firebaseUser.uid);

        isLogged = DataStatus.done;
      } else {
        isLogged = DataStatus.failed;
      }
    });
  }

  login({required String email, required String password}) async {
    try {
      isLogged = DataStatus.loading;
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      isLogged = DataStatus.done;
    } catch (e) {
      isLogged = DataStatus.failed;
      print(e);
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      var authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("user")
          .doc(authResult.user!.uid)
          .set({
        "animes": [
          {"id": 0}
        ],
        "friends": [],
        "name": "default",
        "email": email
      });
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

enum DataStatus { done, loading, failed }
