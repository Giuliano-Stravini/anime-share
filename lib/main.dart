import 'package:alreadywatched/l10n/app_localizations.dart';
import 'package:alreadywatched/responsive.dart';
import 'package:alreadywatched/stores/user_store.dart';
import 'package:alreadywatched/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

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

class MyApp extends StatelessWidget {
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
                  // bottomNavigationBar: BottomNavigationBar(
                  //   type: BottomNavigationBarType.shifting,
                  //   items: [
                  //     BottomNavigationBarItem(
                  //         icon: Icon(Icons.waterfall_chart), label: 'Label'),
                  //     BottomNavigationBarItem(
                  //         icon: Icon(Icons.waterfall_chart), label: 'Label'),
                  //     BottomNavigationBarItem(
                  //         icon: Icon(Icons.waterfall_chart), label: 'Label'),
                  //     BottomNavigationBarItem(
                  //         icon: Icon(Icons.waterfall_chart), label: 'Label'),
                  //   ],
                  // ),
                  body: YearsAnimeList()

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
            CustomTextField(
              controller: _emailController,
              hintText: "E-mail",
              prefixIcon: Icons.email,
            ),
            CustomTextField(
              controller: _passwordController,
              hintText: "Password",
              prefixIcon: Icons.vpn_key,
              obscureText: _isObscure,
              showToggle: true,
              onToggleObscure: () => setState(() {
                _isObscure = !_isObscure;
              }),
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
            CustomTextField(
              controller: _emailController,
              hintText: "E-mail",
              prefixIcon: Icons.email,
            ),
            CustomTextField(
              controller: _passwordController,
              hintText: "Password",
              prefixIcon: Icons.vpn_key,
              obscureText: _isObscure,
              showToggle: true,
              onToggleObscure: () => setState(() {
                _isObscure = !_isObscure;
              }),
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final bool showToggle;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.onToggleObscure,
    this.showToggle = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}
