import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  final Future<Database> database;

  LoginScreen({this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Controle de contas mensal"),
      ),
      body: LoginForm(
        database: database,
      ),
    );
  }
}
