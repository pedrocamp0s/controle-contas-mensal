import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'controle_de_contas.db'),
    onCreate: (db, version) async {
      return await db.execute(
          "CREATE TABLE users(username TEXT PRIMARY KEY, password TEXT, email TEXT)");
    },
    version: 1,
  );

  Database db = await database;
  await db.transaction((txn) {
    return txn.execute(
        "CREATE TABLE IF NOT EXISTS bills(id INTEGER PRIMARY KEY, description TEXT, value REAL, dueDate INTEGER, owner TEXT)");
  });
  print(await db.query('bills'));

  runApp(
    MyApp(
      database: database,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Future<Database> database;

  MyApp({this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(
        database: database,
      ),
    );
  }
}
