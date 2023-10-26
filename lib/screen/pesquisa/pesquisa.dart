import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:labella_app/network_utils/api.dart';

import '../../main.dart';
import '../login/onboard.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({Key? key});

  @override
  State<StatefulWidget> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  late List<Widget> items = [];
  dynamic data = '';
  Map<int, dynamic> selectedAnswers = {};
  int questionNumber = 0;

  @override
  void initState() {
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
        title: const Text(
          "Pesquisa",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color.fromRGBO(30, 30, 30, 1.000),
      ),
      body: FutureBuilder<List<Widget>>(
        future: loadSurveyData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildNavigation(context, snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveSurveyData,
        child: const Icon(Icons.save),
        backgroundColor: Color.fromRGBO(0, 122, 204, 1.000),
      ),
    );
  }

  Future<List<Widget>> loadSurveyData() async {
    if (items.isNotEmpty) {
      items.clear();
      questionNumber = 0;
      for (var add in data['data']) {
        questionNumber++;
        items.add(setAddMenu(add, questionNumber));
      }
      return items;
    } else {
      var uri = '/survey/user';
      var request = await Network().getData(uri);
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
        questionNumber = 0;
        if (data.isNotEmpty) {
          for (var item in data['data']) {
            questionNumber++;
            items.add(setAddMenu(item, questionNumber));
          }
        }
      }

      return items;
    }
  }

  Widget buildNavigation(BuildContext context, List<Widget> menuItems) {
    final items = <Widget>[]
      ..add(descriptionText(context))
      ..addAll(menuItems);

    return ListView(children: items);
  }

  Widget descriptionText(context) {
    if (items.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 15, left: 24, right: 24, bottom: 0),
        child: const Text(
          "",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: const Column(
          children: [
            Text(
              "Não há pesquisa cadastrada",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget setAddMenu(item, int questionNumber) {
    Map<int, TextEditingController> commentControllers = {};
    int questionId = item['survey_questions']['id'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${questionNumber}. ${item['survey_questions']['question']}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: item['survey_questions']['survey_answers'].length,
            itemBuilder: (context, index) {
              final answer = item['survey_questions']['survey_answers'][index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(answer['answer'], style: TextStyle(color: Colors.white)),
                leading: Radio(
                  value: answer['id'],
                  groupValue: selectedAnswers[questionId]?['answer'],
                  onChanged: (value) {
                    setState(() {
                      selectedAnswers[questionId] = {
                        'answer': value,
                        'comment': selectedAnswers[questionId]?['comment'],
                        'id': item['id'],
                      };
                    });
                  },
                ),
              );
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Comentário',
              labelStyle: TextStyle(color: Colors.white)
            ),
            controller: commentControllers[item['survey_questions']['id']],
            onChanged: (value) {
              setState(() {
                selectedAnswers[questionId]?['comment'] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void saveSurveyData() async {
    bool allRadiosSelected = selectedAnswers.length == items.length;

    if (!allRadiosSelected) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text('Por favor, selecione uma opção para cada pergunta'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    List<Map<String, dynamic>> responses = [];

    selectedAnswers.forEach((questionId, answerData) {
      Map<String, dynamic> response = {
        'survey_form_id': answerData['id'],
        'survey_question_id': questionId,
        'answer': answerData['answer'],
        'comment': answerData['comment'],
      };

      responses.add(response);
    });

    var requestBody = {
      'responses': responses,
    };

    var uri = '/survey/clients/response';
    var response = await Network().postData(requestBody, uri);

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pesquisa respondida!'),
          content: Text('A pesquisa foi respondida com sucesso, obrigado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ops!'),
          content:
              Text('Você tem permissão para responder apenas uma vez por dia!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text('Ocorreu um erro ao enviar a resposta.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
