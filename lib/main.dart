import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const url = 'https://api.hgbrasil.com/finance?format=json&key=894e7b41';

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.black,
          primaryColor: Colors.white,
          primaryTextTheme:
              TextTheme(headline6: TextStyle(color: Colors.white)),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            hintStyle: TextStyle(color: Colors.black),
          )),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(url);
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

  double real = double.parse(text);
  dollarController.text = (real/dollar).toStringAsFixed(2);
  euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Conversor'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(0, 176, 67, 1),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.black, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados!",
                    style: TextStyle(color: Colors.black, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Color.fromRGBO(0, 176, 67, 1),
                      ),
                      buildTextField("Dollar", "US\$", dollarController, _dollarChanged),
                      Divider(),
                      buildTextField("Real", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Euro", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        border: OutlineInputBorder(),
        prefixText: prefix + "  "),
    style: TextStyle(
      color: Colors.black,
    ),
    keyboardType: TextInputType.number,
    onChanged: function,
  );
}
