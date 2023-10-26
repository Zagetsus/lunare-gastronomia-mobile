import 'dart:convert';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labella_app/network_utils/api.dart';
import '../../main.dart';
import '../login/onboard.dart';

List<Widget> items = List.empty(growable: true);
dynamic data = '';

class Cardapio extends StatefulWidget {
  const Cardapio({Key? key, required this.day, required this.isReserva})
      : super(key: key);

  final String day;
  final bool isReserva;
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<Cardapio> {
  String name = '';
  String bookingDate = '';

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
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              );
            },
          ),
          title: const Text("Cardápio",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              )),
          backgroundColor: const Color.fromRGBO(30, 30, 30, 1.000),
        ),
        body: FutureBuilder(
          future: loadMenuData(),
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
        ));
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

  FutureBuilder<List<Widget>> buildMenuPage() {
    return FutureBuilder(
      future: loadMenuData(),
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

  Widget buildNavigation(BuildContext context, menuItems) {
    final items = <Widget>[]
      // ignore: prefer_inlined_adds
      ..add(descriptionText(context))
      ..addAll(menuItems);

    return ListView(children: items);
  }

  Widget descriptionText(context) {
    Widget widget;
    if (items.isNotEmpty) {
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
            Text("Não há items cadastrados para este dia",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16)),
          ],
        ),
      );
    }
    return widget;
  }

  Future<List<Widget>> loadMenuData() async {
    var day = widget.day;
    var type = "";

    if (widget.isReserva) {
      type = "reserva";
    } else {
      type = "principal";
    }
    var uri = '/menu/$day/list/$type';

    var request = await Network().getData(uri);
    items.clear();

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
      bookingDate = data['data'][0]['data_cardapio'];
      if (!data.isEmpty) {
        for (var item in data['data']) {
          items.add(setAddMenu(item));
        }
      }
    }

    return items;
  }

  Widget errorWidget(errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(errorText),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, cardapio_item_id) async {
    final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, childWidget) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: childWidget!);
        });
    if (newTime != null) {
      setState(() {
        var uri = '/booking/register';
        var requestBody = {
          'day': widget.day,
          'time_removal': formatTimeOfDay(newTime),
          'date_removal': bookingDate,
          'cardapio_item_id': cardapio_item_id,
        };
        saveBooking(requestBody, uri);
      });
    }
  }

  void saveBooking(requestBody, uri) async {
    var response = await Network().postData(requestBody, uri);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Reserva efetuada'),
                content: const Text('Parabéns, você efetuou a sua reserva.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'))
                ],
              ));
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

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formatter = DateFormat.Hm(); // Formato de 24 horas: "HH:mm"
    return formatter.format(dateTime);
  }

  Widget setAddMenu(item) {
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
                      imageUrl: item['url_image'],
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
                    padding:
                        const EdgeInsets.only(right: 16, left: 16, top: 16),
                    height: 180,
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
                            item['item_name'],
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        showDescription(item),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            // ignore: prefer_interpolation_to_compose_strings
                            "Calorias: " + item['calories'],
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            // ignore: prefer_interpolation_to_compose_strings
                            "Data: " + item['data_cardapio_formated'],
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        widget.isReserva
                            ? bookingRegister(
                                item['reservationBlocked'], item['id'])
                            : Container(),
                        Expanded(child: Container()),
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

  Widget showDescription(item) {
    if (item[item['item_description']] != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          // ignore: prefer_interpolation_to_compose_strings
          "Descrição: " + item['item_description'],
          style: const TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget bookingRegister(blocked, cardapio_item_id) {
    if (blocked) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text("Fora do horário permitido para reservas no dia",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          ElevatedButton(
            onPressed: () => _selectTime(context, cardapio_item_id),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromRGBO(139, 0, 0, 1.000)),
            ),
            child: const Text('Reservar'),
          ),
        ],
      );
    }
  }
}
