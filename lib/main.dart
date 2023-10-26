import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labella_app/screen/home/home.dart';
import 'package:labella_app/screen/login/onboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences localStorage = localStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  localStorage = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Labella App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: const Locale('pt', 'BR'),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labella App',
      theme: ThemeData(
          primaryColor: Color.fromRGBO(30, 30, 30, 1.000),
          fontFamily: 'Circular',
          scaffoldBackgroundColor: Color.fromRGBO(30, 30, 30, 1.000)),
      debugShowCheckedModeBanner: false,
      home: const CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    //SharedPreferences
    var token = localStorage.getString('token');

    if (token != null) {
      setState(() {
        isAuth = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      child = const Home();
    } else {
      child = Onboard();
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(child: child),
        ],
      ),
    );
  }
}
