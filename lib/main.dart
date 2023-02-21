import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_lesson/person_model.dart';
import 'package:hive_lesson/todo_model.dart';
import 'package:hive_lesson/univer_data.dart';
import 'package:hive_lesson/view_univers.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(UniverAdapter());
  Hive.registerAdapter(UniverResponseAdapter());
  Hive.registerAdapter(TodoModelAdapter());
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
      home: const MyHomePage2(title: 'Flutter Demo Home Page'),
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
  Box<UniverResponse>? box;
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
                    box!.put(name.text,
                        data ?? UniverResponse(univers: [], name: name.text));
                    setState(() {});
                  },
                  child: const Text("Save"))
            ],
          );
        });
  }

  hiveInit() async {
    box = await Hive.openBox('country');
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
      body: ListView.builder(
          itemCount: box?.values.length ?? 0,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ViewUniversPage(
                            data: box?.values.elementAt(index))));
              },
              child: Container(
                color: Colors.lightBlue,
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(box?.values.elementAt(index).name ?? ""),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          box!.deleteAt(index);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete))
                  ],
                ),
              ),
            );
          }),
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

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage2> createState() => _MyHomePageState2();
}

class _MyHomePageState2 extends State<MyHomePage2> {
  final name = TextEditingController();
  final time = TextEditingController();
  final firebaseStore = FirebaseFirestore.instance;
  Box<TodoModel>? boxTodo;

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
                TextFormField(
                  controller: time,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    var res = await firebaseStore.collection("todo").add(
                        TodoModel(name: name.text, time: time.text).toJson());

                    boxTodo!.put(
                        res.id, TodoModel(name: name.text, time: time.text));
                    setState(() {});
                  },
                  child: const Text("Save"))
            ],
          );
        });
  }

  hiveInit() async {
    boxTodo = await Hive.openBox('todo');
    var res = await firebaseStore.collection("todo").get();
    for (var element in res.docs) {
      boxTodo!.put(element.id, TodoModel.fromJson(element.data()));
    }
    setState(() {});
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
      body: ListView.builder(
          itemCount: boxTodo?.values.length ?? 0,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.lightBlue,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(boxTodo?.values.elementAt(index).name ?? ""),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        boxTodo!.deleteAt(index);
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete))
                ],
              ),
            );
          }),
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
