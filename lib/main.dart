import 'package:alreadywatched/responsive.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

final HttpLink httpLink = HttpLink(
  uri: 'https://graphql.anilist.co',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
);

// final AuthLink authLink = AuthLink(
//   getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
//   // OR
//   // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
// );

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: httpLink,
  ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: LayoutBuilder(builder: (context, constraintBox) {
          Responsive().init(
              maxHeight: constraintBox.maxHeight,
              maxWidth: constraintBox.maxWidth);

          var userStore = UserStore();
          return MultiProvider(
            providers: [
              Provider<UserStore>(
                create: (_) => userStore,
              )
            ],
            child: MaterialApp(
              theme: ThemeData.dark().copyWith(
                  appBarTheme: AppBarTheme(
                      textTheme: TextTheme(
                          title: TextStyle(
                              fontSize: Responsive().horizontal(6),
                              color: Colors.white))),
                  textTheme: TextTheme(
                      body1: TextStyle(fontSize: Responsive().horizontal(4)),
                      title: TextStyle(
                          fontSize: Responsive().horizontal(6),
                          color: Colors.black))),
              home: Scaffold(body: CheckUser()),
            ),
          );
        }),
      ),
    );
  }
}

class CheckUser extends StatefulWidget {
  CheckUser({Key key}) : super(key: key);

  @override
  _CheckUserState createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    UserStore().checkUser();
  }

  @override
  Widget build(BuildContext context) {
    var _userStore = Provider.of<UserStore>(context);

    return Observer(
      builder: (_) {
        switch (_userStore.isLogged) {
          case DataStatus.done:
            return HomePage(
              userStore: _userStore,
            );
            break;
          case DataStatus.failed:
            return LoginPage();
            break;
          default:
            return Container();
        }
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
