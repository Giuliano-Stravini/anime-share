import 'package:alreadywatched/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {
  @observable
  var user = User();

  @action
  fetchUserSnapshot({String uid}) {
    Firestore().collection("user").where(uid).snapshots().listen((docs) {
      if (docs.documents.isNotEmpty) {
        var doc = docs.documents.first;
        user.favoriteIds.value.clear();

        (doc.data['animes'] as List).forEach((i) {
          user.favoriteIds.value.add(i['id']);
        });
      }
    });
  }

  @action
  updateFavoriteList(int id) async {
    if (user.favoriteIds.value.contains(id)) {
      user.favoriteIds.value.remove(id);
    } else {
      user.favoriteIds.value.add(id);
    }
    var animes = List<Map<String, int>>();

    user.favoriteIds.value.forEach((i) {
      animes.add({"id": i});
    });

    await Firestore()
        .collection("user")
        .document("D3SAzycwFpOT5JjE6ePj")
        .updateData({"animes": animes});
  }

  @action
  bool checkFavorite(int id) {
    return user.favoriteIds.value.contains(id);
  }

  @observable
  DataStatus isLogged;

  @action
  checkUser() {
    FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) async {
      isLogged = DataStatus.loading;
      if (firebaseUser != null) {
        fetchUserSnapshot(uid: firebaseUser.uid);

        isLogged = DataStatus.done;
      } else {
        isLogged = DataStatus.failed;
      }
    });
  }

  @action
  login({String email, String password}) async {
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

  @action
  signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

@observable
enum DataStatus { done, loading, failed }
