import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:labella_app/network_utils/api.dart';
import '../../main.dart';
import '../login/onboard.dart';

List<Widget> bookings = List.empty(growable: true);
dynamic data = '';

class MinhasReservas extends StatefulWidget {
  const MinhasReservas({super.key});

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<MinhasReservas> {
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
        title: const Text("Minhas Reservas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
              color: Colors.white
            )),
        backgroundColor: const Color.fromRGBO(30, 30, 30, 1.000),
      ),
      body: buildBookingPage(),
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

  FutureBuilder<List<Widget>> buildBookingPage() {
    return FutureBuilder(
      future: loadBookingData(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return buildNavigation(context, snapshot.data);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        }
      }),
    );
  }

  Widget buildNavigation(BuildContext context, bookings) {
    final items = <Widget>[]
      // ignore: prefer_inlined_adds
      ..add(descriptionText(context))
      ..addAll(bookings);

    return ListView(children: items);
  }

  Widget descriptionText(context) {
    Widget widget;
    if (bookings.isNotEmpty) {
      widget = Container(
        padding: const EdgeInsets.only(top: 15, left: 24, right: 24, bottom: 0),
        child: const Text("",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16)),
      );
    } else {
      widget = Container(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: const Column(
          children: [
            Text("Não há reservas",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 16)),
          ],
        ),
      );
    }
    return widget;
  }

  Future<List<Widget>> loadBookingData() async {
    var uri = '/booking/list';

    var request = await Network().getData(uri);
    bookings.clear();
    if (request.statusCode == 401) {
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

    if (request.statusCode == 200) {
      data = json.decode(request.body);

      if (!data.isEmpty) {
        for (var prog in data['data']) {
          bookings.add(setAddBooking(prog));
        }
      }
    }

    return bookings;
  }

  Widget errorWidget(errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(errorText),
      ],
    );
  }

  Widget buttonDeleteBooking(bookingId, blocked) {
    if (blocked) {
      return Container();
    } else {
      return ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content:
                const Text('Tem certeza que deseja cancelar esta reserva?'),
            actions: [
              TextButton(
                onPressed: () {
                  deleteBooking(bookingId);
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text('Sim'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              Color.fromRGBO(139, 0, 0, 1.000)),
        ),
        child: const Text('Cancelar'),
      );
    }
  }

  deleteBooking(bookingId) async {
    var uri = '/booking/delete/$bookingId';
    var response = await Network().deleteData(uri);

    if (response.statusCode == 200) {
      print(response.body);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sucesso'),
          content: Text(jsonDecode(response.body)['data']),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: Text(jsonDecode(response.body)['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget setAddBooking(booking) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 18, right: 24),
            child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
              elevation: 2,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: booking['url_image'],
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black)),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 30,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.only(right: 16, left: 16, top: 16),
                    height: 150,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(225, 225, 225, 1),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            booking['item_name'],
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ShowDescription(booking),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: <Widget>[
                                        const Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          // ignore: prefer_const_constructors
                                          child: Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                          ),
                                        ),
                                        Text(
                                            // ignore: prefer_interpolation_to_compose_strings
                                            "Data da reserva: " +
                                                booking['booking_date'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                height: 1.1)),
                                      ],
                                    ),
                                  ),

                                  //Horario
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5),
                                              // ignore: prefer_const_constructors
                                              child: Icon(
                                                Icons.schedule,
                                                size: 12,
                                              ),
                                            ),
                                            Text(
                                                // ignore: prefer_interpolation_to_compose_strings
                                                "Hora reservada: " +
                                                    booking['booking_time'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    height: 1.1)),
                                          ],
                                        ),
                                        // ignore: prefer_const_constructors

                                        // ignore: prefer_const_constructors, prefer_interpolation_to_compose_strings
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buttonDeleteBooking(
                                booking['id'], booking['booking_blocked']),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ShowDescription(booking) {
    if (booking[booking['item_description']] != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 30),
        child: Text(
          booking['item_description'],
          style: const TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
        ),
      );
    } else {
      return Container();
    }
  }
}
