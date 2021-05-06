import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../screens/signup_screen.dart';
import '../screens/bill_list_screen.dart';

import '../models/user.dart';

class LoginForm extends StatefulWidget {
  final Future<Database> database;

  LoginForm({this.database});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerForUsername = TextEditingController();
  final _controllerForPassword = TextEditingController();

  String _validateUsername(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um nome de usuário para continuar';
    }

    return validationResult;
  }

  String _validatePassword(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite uma senha para continuar';
    }

    return validationResult;
  }

  Future<List<User>> getUsers() async {
    final Database db = await this.widget.database;

    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User(
        username: maps[i]['username'],
        password: maps[i]['password'],
        email: maps[i]['email'],
      );
    });
  }

  void _closeDialog() {
    Navigator.pop(context);
  }

  void showErrorMessage(String message) async {
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Não foi possível logar'),
            children: [
              Column(
                children: [
                  Container(
                    child: Text(message),
                    margin: EdgeInsets.only(top: 30, bottom: 30),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: _closeDialog,
                      child: Text('OK'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    void _makeLogin() async {
      if (_formKey.currentState.validate()) {
        List<User> users = await getUsers();

        bool userExists = false;

        for (var user in users) {
          if (this._controllerForUsername.text == user.username) {
            userExists = true;
            if (this._controllerForPassword.text == user.password) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BillListScreen(
                    username: this._controllerForUsername.text,
                    database: this.widget.database,
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              showErrorMessage('A senha inserida está errada!');
            }
          }
        }

        if (!userExists) {
          showErrorMessage('O usuário inserido não existe!');
        }
      }
    }

    void _doSignup() async {
      List<User> users = await getUsers();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(
            database: this.widget.database,
            users: users,
          ),
        ),
      );
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: this._controllerForUsername,
              decoration: InputDecoration(
                labelText: 'Nome de usuário',
                errorMaxLines: 2,
              ),
              validator: this._validateUsername,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForPassword,
              decoration: InputDecoration(
                labelText: 'Senha',
                errorMaxLines: 2,
              ),
              validator: this._validatePassword,
              obscureText: true,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: _makeLogin,
                  child: Text('Entrar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                margin: EdgeInsets.only(right: 20),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _doSignup,
                  child: Text('Inscrever-se'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
