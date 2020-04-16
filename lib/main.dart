import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = "https://api.hgbrasil.com/finance";

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController realController = TextEditingController();
  TextEditingController dollarController = TextEditingController();
  TextEditingController euroController = TextEditingController();
  double dollar;
  double euro;

  void _resetvalues() {
    realController.clear();
    dollarController.clear();
    euroController.clear();
  }

  void _realChanged(String value) {
    dollarController.text = (double.parse(value) * dollar).toStringAsFixed(2);
    euroController.text = (double.parse(value) * euro).toStringAsFixed(2);
  }

  void _dollarChanged(String value) {
    realController.text = (double.parse(value) * dollar).toStringAsFixed(2);
    euroController.text =
        (double.parse(value) * dollar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String value) {
    realController.text = (double.parse(value) * euro).toStringAsFixed(2);
    dollarController.text =
        (double.parse(value) * euro / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "\$ Currency Converter \$",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetvalues,
            color: Colors.white,
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<Map>(
        future: getCurrentCurrencies(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Loading ...",
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
              ));
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "Error loading data :(",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ));
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
                          color: Colors.amber,
                        ),
                        buildTextFormField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextFormField("Dollars", "US\$", dollarController,
                            _dollarChanged),
                        Divider(),
                        buildTextFormField(
                            "Euros", "E\$", euroController, _euroChanged)
                      ],
                    ));
              }
          }
        },
      ),
    );
  }
}

Future<Map> getCurrentCurrencies() async {
  http.Response response = await http.get(url);
  return jsonDecode(response.body);
}

buildTextFormField(String labelText, String prefix,
    TextEditingController controller, Function f) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.number,
    controller: controller,
    onChanged: f,
  );
}
