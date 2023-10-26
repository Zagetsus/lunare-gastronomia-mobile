import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../network_utils/api.dart';
import '../home/home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromRGBO(154, 97, 109, 1.000),
          fontSize: 16,
        ),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.white,
    );
    return snackBar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(right: 0, left: 0),
              child: IconButton(
                icon: const Icon(Icons.navigate_before),
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            );
          },
        ),
        backgroundColor: Color.fromRGBO(45, 45, 48, 1.000),
      ),
      key: _scaffoldKey,
      body: Container(
        color: Color.fromRGBO(45, 45, 48, 1.000),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, top: 36),
                    child: SizedBox(
                      width: 500,
                      child: Text(
                        "Login",
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          height: 1.1,
                          color: Colors.white,
                          fontSize: 38.0,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // ignore: prefer_const_constructors

                        //BTN
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 16),
                                    decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ), //<-- Cor da lunha
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        labelText: "E-mail",
                                        labelStyle: const TextStyle(
                                            fontFamily: 'Circular',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            fontSize: 18)),
                                    validator: (emailValue) {
                                      if (emailValue!.isEmpty) {
                                        return "Por favor, digite o e-mail";
                                      }
                                      email = emailValue;
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        fontFamily: 'Circular',
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 18),
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                        fillColor: Colors.white,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ), //<-- Cor da lunha
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        labelText: 'Senha',
                                        labelStyle: TextStyle(
                                            fontFamily: 'Circular',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            fontSize: 18)),
                                    validator: (passwordValue) {
                                      if (passwordValue!.isEmpty) {
                                        return "Por favor, digite algum texto";
                                      } else if (passwordValue.length < 1) {
                                        return "A senha deve ter no mínimo 3 caracteres";
                                      } else {
                                        password = passwordValue;
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 10),
        width: double.infinity,
        height: 50,
        child: MaterialButton(
          color: Color.fromRGBO(139, 0, 0, 1.000),
          height: 50,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Text(
            "Entrar",
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              FocusManager.instance.primaryFocus?.unfocus();
              _login();
            }
          },
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    var data = {
      'email': email,
      'password': password,
    };

    var res = await Network().authData(data, '/sanctum/token');
    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(_showMsg(body['error']));
    } else if (body.containsKey("token") && body['token'] != null) {
      localStorage.setString('token', json.encode(body['token']));
      var request = await Network().getData('/user');
      var data = json.decode(request.body);
      if (!data.isEmpty) {
        localStorage.setString('user', json.encode(data));
      }

      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(_showMsg(body['message']));
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _launchURL() async {
    const url = 'https://app.labellagastronomia.com/password/reset';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Houve um problema para abrir a url $url';
    }
  }
}
