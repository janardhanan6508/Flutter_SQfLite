import 'package:flutter/material.dart';
import 'package:flutter_sqlite/fruit_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Sqflite(),
    );
  }
}

class Sqflite extends StatefulWidget {
  Sqflite({Key? key}) : super(key: key);
  @override
  State<Sqflite> createState() => _SqfliteState();
}

class _SqfliteState extends State<Sqflite> {
  int? selectedId;
  TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: textController,
        ),
      ),
      body: Center(
        child: FutureBuilder<List<FruitClass>>(
            future: DabaBaseHelper.instance.getFruits(),
            builder: (BuildContext context,
                AsyncSnapshot<List<FruitClass>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }
              return snapshot.data!.isEmpty
                  ? const Center(child: Text('No fruit available in list'))
                  : ListView(
                      children: snapshot.data!.map((fruit) {
                        return Center(
                          child: Card(
                            color: selectedId == fruit.id
                                ? Colors.grey
                                : Colors.white,
                            child: ListTile(
                              title: Text(fruit.name),
                              onTap: () {
                                setState(() {
                                  if (selectedId == null) {
                                    textController.text = fruit.name;
                                    selectedId = fruit.id;
                                  } else {
                                    textController.text = '';
                                    selectedId = null;
                                  }
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  DabaBaseHelper.instance.remove(fruit.id!);
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async {
          print(textController.text);
          selectedId != null
              ? await DabaBaseHelper.instance
                  .update(FruitClass(name: textController.text, id: selectedId))
              : await DabaBaseHelper.instance
                  .add(FruitClass(name: textController.text));
          setState(() {
            textController.clear();
            selectedId = null;
          });
        },
      ),
    );
  }
}

class DabaBaseHelper {
  DabaBaseHelper();
  DabaBaseHelper._privateConstructor();
  static final DabaBaseHelper instance = DabaBaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'fruits.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
   CREATE TABLE fruits(
     id INTEGER PRIMARY KEY,
   name TEXT
   )''');
  }

  Future<List<FruitClass>> getFruits() async {
    Database db = await instance.database;
    var fruits = await db.query('fruits', orderBy: 'name');
    List<FruitClass> fruitList = fruits.isNotEmpty
        ? fruits.map((e) => FruitClass.fromMap(e)).toList()
        : [];
    return fruitList;
  }

  Future<int> add(FruitClass fruitClass) async {
    Database db = await instance.database;
    return await db.insert('fruits', fruitClass.toMap());
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('fruits', where: 'id =?', whereArgs: [id]);
  }

  Future<int> update(FruitClass fruitClass) async {
    Database db = await instance.database;
    return await db.update('fruits', fruitClass.toMap(),
        where: 'id =?', whereArgs: [fruitClass.id]);
  }
}
