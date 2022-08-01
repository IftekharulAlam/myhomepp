// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Timer timer;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => addValue());
  }

  void addValue() {
    setState(() {
      counter++;
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future getall() async {
    http.Response response = await http
        .get(Uri.parse("http://192.168.0.100:8000/getTemparatureDataApp"));

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      throw Exception("Error loading data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          // color: Colors.white,
          // backgroundColor: Colors.blue,
          // strokeWidth: 4.0,
          onRefresh: () async {
            return Future<void>.delayed(const Duration(seconds: 1));
          },
          child: FutureBuilder(
            future: getall(),
            builder: (BuildContext context, AsyncSnapshot sn) {
              if (sn.hasData) {
                List unis = sn.data;
                return GestureDetector(
                  onTap: () {
                    _refreshIndicatorKey.currentState?.show();
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Temp: ${unis.last["tempData"]} *C"),
                             Text("Humidity: ${unis.last["humidity"]} %"),
                          ],
                        ),
                        subtitle: Text(" ID: ${unis.last["ID"]}"),
                      ),
                    ),
                  ),
                );
              }
              if (sn.hasError) {
                return const Center(child: Text("Error Loading Data"));
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
