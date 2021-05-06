import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../widgets/signup_form.dart';

import '../models/user.dart';

class SignUpScreen extends StatelessWidget {
  final Future<Database> database;
  final List<User> users;

  SignUpScreen({this.database, this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: SignUpForm(database: database, users: users),
    );
  }
}
