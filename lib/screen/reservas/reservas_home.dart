import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:labella_app/screen/cardapio/dias_semana.dart';
import 'package:labella_app/screen/home/home.dart';
import 'package:labella_app/screen/reservas/minhas_reservas.dart';
import '../../main.dart';

class Reservas extends StatefulWidget {
  const Reservas({super.key});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<Reservas> {
  String name = '';

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(45, 45, 48, 1.000),
      appBar: AppBar(
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
        title: const Text("Reservas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.5,
            )),
        backgroundColor: const Color.fromRGBO(30, 30, 30, 1.000),
      ),
      body: Center(
          child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25),
                child: Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const DiasSemana(isReserva: true)));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(
                            left: 1.0, top: 11.0, bottom: 11.0, right: 11.0),
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
                              icon: Image(
                                image: AssetImage(
                                    'assets/images/app/restaurante-48.png'),
                              ),
                              label: const Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text("Nova reserva",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize: 18)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const DiasSemana(isReserva: true)));
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Colors.transparent),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const MinhasReservas()));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(
                            left: 1.0, top: 11.0, bottom: 11.0, right: 11.0),
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
                              icon: Image(
                                image: AssetImage('assets/images/app/book.png'),
                              ),
                              label: const Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text("Minhas reservas",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize: 18)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const MinhasReservas()));
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Colors.transparent),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  _loadUserData() async {
    //final teste = await FirebaseMessaging.instance.getToken();
    // print('Token FCM => ${teste}');
    if (localStorage.getString('user').toString().isEmpty) {
      name = "Sem dados";
    } else {
      var user = jsonDecode(localStorage.getString('user').toString());
      if (user != null) {
        setState(() {
          name = user['name'];
        });
      }
    }
  }
}
