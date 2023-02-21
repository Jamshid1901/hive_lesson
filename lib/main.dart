import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_lesson/person_model.dart';
import 'package:hive_lesson/univer_data.dart';
import 'package:hive_lesson/view_univers.dart';
import 'package:http/http.dart' as http;

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  Box<Person>? box;
  UniverResponse? data;
  final name = TextEditingController();

  void _incrementCounter(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Name"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    var res = await http.get(Uri.parse(
                        "http://universities.hipolabs.com/search?country=${name.text}"));
                    data = UniverResponse.fromJson(
                        jsonDecode(res.body), name.text);

                    setState(() {});
                  },
                  child: Text("Save"))
            ],
          );
        });
  }

  hiveInit() async {
    box = await Hive.openBox('personName');
  }

  @override
  void initState() {
    hiveInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: data == null
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ViewUniversPage(data: data)));
              },
              child: Container(
                padding: EdgeInsets.all(24),
                color: Colors.lightBlue,
                child: Text(data?.name ?? ""),
              ),
            ),
      // ListView.builder(
      //     itemCount: box?.values.length ?? 0,
      //     itemBuilder: (context, index) {
      //       return Container(
      //         color: Colors.lightBlue,
      //         margin: EdgeInsets.only(bottom: 8),
      //         padding: EdgeInsets.all(24),
      //         child: Row(
      //           children: [
      //             Column(
      //               children: [
      //                 Text(box?.values.elementAt(index).name ?? ""),
      //                 Text(
      //                     (box?.values.elementAt(index).count ?? 0).toString()),
      //                 Text(box?.keys.elementAt(index) ?? ""),
      //               ],
      //             ),
      //             IconButton(
      //                 onPressed: () {
      //                   box!.deleteAt(index);
      //                   setState(() {});
      //                 },
      //                 icon: const Icon(Icons.delete))
      //           ],
      //         ),
      //       );
      //     }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
