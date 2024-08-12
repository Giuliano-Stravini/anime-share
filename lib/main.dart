import 'package:alreadywatched/responsive.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  runApp(MyApp());
}

final HttpLink httpLink = HttpLink(
  'https://graphql.anilist.co',
  defaultHeaders: {
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
    cache: GraphQLCache(),
    link: httpLink,
  ),
);

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int navigationIndex;

  @override
  void initState() {
    navigationIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: LayoutBuilder(builder: (context, constraintBox) {
          var userStore = UserProvider();
          return MultiProvider(
            providers: [
              Provider<UserProvider>(
                create: (_) => userStore,
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData.dark().copyWith(
                primaryColor: const Color(0xFF120703),
                colorScheme: ThemeData.dark().colorScheme.copyWith(
                      primary: const Color(0xFFE6B17E),
                    ),
                timePickerTheme: TimePickerThemeData(),
                buttonTheme:
                    ButtonThemeData(buttonColor: const Color(0xFFE6B17E)),
              ),
              home: Scaffold(
                  bottomNavigationBar: NavigationBar(
                    height: 40,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                    indicatorColor: Colors.orange,
                    selectedIndex: navigationIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        navigationIndex = value;
                      });
                    },
                    destinations: <Widget>[
                      NavigationDestination(
                          tooltip: 'home',
                          icon: Icon(Icons.list),
                          label: 'home'),
                      NavigationDestination(
                          tooltip: 'favorite',
                          icon: Icon(Icons.star),
                          label: 'favorite'),
                      NavigationDestination(
                          tooltip: 'profile',
                          icon: Icon(Icons.person),
                          label: 'profile')
                    ],
                  ),
                  body: <Widget>[
                    YearsAnimeList(),
                    Container(
                      color: Colors.amber,
                    ),
                    Container(
                      color: Colors.orange,
                    )
                  ][navigationIndex]

                  //      CheckUser(
                  //   userStore: userStore,
                  // ),

                  ),
            ),
          );
        }),
      ),
    );
  }
}

// class CheckUser extends StatefulWidget {
//   CheckUser({Key key, this.userStore}) : super(key: key);

//   final UserProvider userStore;

//   @override
//   _CheckUserState createState() => _CheckUserState();
// }

// class _CheckUserState extends State<CheckUser> {
//   @override
//   void initState() {
//     super.initState();
//     widget.userStore.checkUser();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var _userStore = Provider.of<UserProvider>(context);

//     switch (_userStore.isLogged) {
//       case DataStatus.done:
//         return HomePage(
//           userStore: _userStore,
//         );
//         break;
//       case DataStatus.failed:
//         return LoginPage();
//         break;
//       default:
//         return Container();
//     }
//   }
// }

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var _userStore = Provider.of<UserProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text("Logo"),
            Spacer(),
            TextField(
              controller: _emailController,
              onChanged: (String newValue) {
                _emailController.value.copyWith(text: newValue);
              },
              decoration: InputDecoration(
                hintText: "E-mail",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: _passwordController,
              onChanged: (String newValue) {
                _passwordController.value.copyWith(text: newValue);
              },
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.vpn_key),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() {
                    _isObscure = !_isObscure;
                  }),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6B17E)),
                  onPressed: () {
                    // _userStore.login(
                    //     email: _emailController.value.text,
                    //     password: _passwordController.value.text);
                  },
                  child: Text("Login"),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6B17E)),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SignUpPage())),
                child: Text("SignUp"),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    var _userStore = Provider.of<UserProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              onChanged: (String newValue) {
                _emailController.value.copyWith(text: newValue);
              },
              decoration: InputDecoration(
                hintText: "E-mail",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: _passwordController,
              onChanged: (String newValue) {
                _passwordController.value.copyWith(text: newValue);
              },
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.vpn_key),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() {
                    _isObscure = !_isObscure;
                  }),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: !_loading
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6B17E)),
                        onPressed: () async {
                          // setState(() {
                          //   _loading = true;
                          // });
                          // String error = await _userStore.signUp(
                          //     email: _emailController.value.text,
                          //     password: _passwordController.value.text);

                          // if (error == null) {
                          //   Navigator.pop(context);
                          // } else {
                          //   ScaffoldMessenger.of(context)
                          //       .showSnackBar(SnackBar(content: Text(error)));
                          // }

                          // setState(() {
                          //   _loading = false;
                          // });

                          // print(error);
                        },
                        child: Text("Register"),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            const Color(0xFFE6B17E)),
                      )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
