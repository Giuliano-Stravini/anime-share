import 'package:mobx/mobx.dart';

class User {
  @observable
  ObservableFuture<ObservableList<int>> favoriteIds =
      ObservableFuture<ObservableList<int>>.value(ObservableList<int>());
  String name;
  String email;
}
