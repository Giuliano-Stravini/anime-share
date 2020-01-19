// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserStore on UserStoreBase, Store {
  final _$userAtom = Atom(name: 'UserStoreBase.user');

  @override
  User get user {
    _$userAtom.context.enforceReadPolicy(_$userAtom);
    _$userAtom.reportObserved();
    return super.user;
  }

  @override
  set user(User value) {
    _$userAtom.context.conditionallyRunInAction(() {
      super.user = value;
      _$userAtom.reportChanged();
    }, _$userAtom, name: '${_$userAtom.name}_set');
  }

  final _$isLoggedAtom = Atom(name: 'UserStoreBase.isLogged');

  @override
  DataStatus get isLogged {
    _$isLoggedAtom.context.enforceReadPolicy(_$isLoggedAtom);
    _$isLoggedAtom.reportObserved();
    return super.isLogged;
  }

  @override
  set isLogged(DataStatus value) {
    _$isLoggedAtom.context.conditionallyRunInAction(() {
      super.isLogged = value;
      _$isLoggedAtom.reportChanged();
    }, _$isLoggedAtom, name: '${_$isLoggedAtom.name}_set');
  }

  final _$updateFavoriteListAsyncAction = AsyncAction('updateFavoriteList');

  @override
  Future updateFavoriteList(int id) {
    return _$updateFavoriteListAsyncAction
        .run(() => super.updateFavoriteList(id));
  }

  final _$UserStoreBaseActionController =
      ActionController(name: 'UserStoreBase');

  @override
  dynamic fetchUserSnapshot({String uid}) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction();
    try {
      return super.fetchUserSnapshot(uid: uid);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool checkFavorite(int id) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction();
    try {
      return super.checkFavorite(id);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic checkUser() {
    final _$actionInfo = _$UserStoreBaseActionController.startAction();
    try {
      return super.checkUser();
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }
}
