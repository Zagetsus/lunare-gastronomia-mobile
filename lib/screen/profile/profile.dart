// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../network_utils/api.dart';
import '../login/onboard.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

// ignore: unused_element

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    var user = jsonDecode(localStorage.getString('user').toString());
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Color.fromRGBO(45, 45, 48, 1.000),
    );
    return snackBar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(45, 45, 48, 1.000),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(right: 0, left: 0),
                child: IconButton(
                  icon: const Icon(Icons.navigate_before),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              );
            },
          ),
          title: Text('Minha conta',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5
              ),
          ),
          backgroundColor: Color.fromRGBO(30, 30, 30, 1.000),
        ),
        body: Center(
            child: ListView(children: [
          Padding(
              padding: const EdgeInsets.only(
                  bottom: 24, top: 24, left: 24, right: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Center(
                        child: ElevatedButton(
                            onPressed: () {
                              logout();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  left: 1.0,
                                  top: 11.0,
                                  bottom: 11.0,
                                  right: 11.0),
                              backgroundColor: Color.fromRGBO(45, 45, 48, 1.000),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: OutlinedButton.icon(
                                      onPressed: () {
                                        logout();
                                      },
                                      icon: Image(
                                        image: AssetImage(
                                            'assets/images/app/sair.png'),
                                      ),
                                      label: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text("Sair do aplicativo",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                fontSize: 18)),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.transparent),
                                      )),
                                ),
                              ],
                            )),
                      )),
                ],
              )),
        ])));
  }

  void logout() async {
    localStorage.clear();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Onboard();
        },
      ),
      (_) => false,
    );

    /* var res = await Network().deleteData('/api/oauth/token');
    if (res.statusCode == 200 || res.statusCode == 401) {
      localStorage.clear();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return Onboard();
          },
        ),
        (_) => false,
      );
    }
    */
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  _launchURL(url, mail) async {
    Uri uri;

    if (!mail) {
      uri = Uri.parse(url);
    } else {
      uri = url;
    }

    if (!mail && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mail) {
      try {
        await launchUrl(url);
      } on Exception catch (e) {
        return e.toString();
      }
    } else {
      throw 'Houve um problema para abrir a url $url';
    }
  }
}
