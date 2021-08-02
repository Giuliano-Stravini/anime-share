import 'dart:async';

import 'package:alreadywatched/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider {
//   var user = User();

//   StreamSubscription _listener;

//   fetchUserSnapshot({String uid}) {
//     if (_listener != null) {
//       _listener.cancel();
//     }
//     _listener =
//         Firestore().collection("user").document(uid).snapshots().listen((doc) {
//       if (doc.exists) {
//         user.favoriteIds.clear();

//         (doc.data['animes'] as List).forEach((i) {
//           user.favoriteIds.add(i['id']);
//         });
//       }
//     });
//   }

//   updateFavoriteList(int id, String uid) async {
//     if (user.favoriteIds.contains(id)) {
//       user.favoriteIds.remove(id);
//     } else {
//       user.favoriteIds.add(id);
//     }
//     var animes = List<Map<String, int>>();

//     user.favoriteIds.forEach((i) {
//       animes.add({"id": i});
//     });

//     await Firestore()
//         .collection("user")
//         .document(uid)
//         .updateData({"animes": animes});
//   }

//   bool checkFavorite(int id) {
//     return user.favoriteIds.contains(id);
//   }

//   DataStatus isLogged;

//   checkUser() {
//     FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) async {
//       isLogged = DataStatus.loading;
//       if (firebaseUser != null) {
//         user.uid = firebaseUser.uid;
//         fetchUserSnapshot(uid: firebaseUser.uid);

//         isLogged = DataStatus.done;
//       } else {
//         isLogged = DataStatus.failed;
//       }
//     });
//   }

//   login({String email, String password}) async {
//     try {
//       isLogged = DataStatus.loading;
//       await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);
//       isLogged = DataStatus.done;
//     } catch (e) {
//       isLogged = DataStatus.failed;
//       print(e);
//     }
//   }

//   Future<String> signUp({String email, String password}) async {
//     try {
//       var authResult = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);

//       await Firestore()
//           .collection("user")
//           .document(authResult.user.uid)
//           .setData({
//         "animes": [
//           {"id": 0}
//         ],
//         "friends": [],
//         "name": "default",
//         "email": email
//       });
//       return null;
//     } catch (e) {
//       print(e);
//       return e.toString();
//     }
//   }

//   signOut() async {
//     await FirebaseAuth.instance.signOut();
//   }
}

enum DataStatus { done, loading, failed }
