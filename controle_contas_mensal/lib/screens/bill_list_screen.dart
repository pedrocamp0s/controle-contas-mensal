import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../widgets/bill_form.dart';

import '../models/bill.dart';

class BillListScreen extends StatefulWidget {
  final String username;
  final Future<Database> database;

  BillListScreen({this.username, this.database});

  @override
  _BillListScreenState createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  List<Bill> bills = [];
  bool loadingBills = true;

  Future<List<Bill>> getBills() async {
    // Get a reference to the database.
    final Database db = await this.widget.database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db
        .query('bills', where: "owner = ?", whereArgs: [this.widget.username]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Bill(
        id: maps[i]['id'],
        description: maps[i]['description'],
        value: maps[i]['value'],
        dueDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['dueDate']),
        owner: maps[i]['owner'],
      );
    });
  }

  Future<void> insertBill(Bill bill) async {
    final Database db = await this.widget.database;

    await db.insert(
      'bills',
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBill(Bill bill) async {
    final db = await this.widget.database;

    await db.update(
      'bills',
      bill.toMap(),
      where: "id = ?",
      whereArgs: [bill.id],
    );
  }

  Future<void> deleteBill(int id) async {
    final db = await this.widget.database;

    await db.delete(
      'bills',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  void _createBill(String description, num value, DateTime dueDate) async {
    await insertBill(
      new Bill(
          description: description,
          value: value,
          dueDate: dueDate,
          id: this.bills.length + 1,
          owner: this.widget.username),
    );
    setState(() {
      getBillsAsync();
    });
  }

  void _editBill(Bill bill) async {
    await updateBill(bill);
    setState(() {
      getBillsAsync();
    });
  }

  void _deleteBill(int id) async {
    await deleteBill(id);
    setState(() {
      getBillsAsync();
    });
  }

  void getBillsAsync() async {
    this.bills = await getBills();
    setState(() {
      this.loadingBills = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBillsAsync();
  }

  @override
  Widget build(BuildContext context) {
    void _handleNewBill() {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              children: [BillForm(createBill: _createBill)],
              title: Text('Nova conta'),
            );
          });
    }

    void _handleEditBill(Bill bill) {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              children: [
                BillForm(
                  editBill: _editBill,
                  bill: bill,
                )
              ],
              title: Text('Editar conta'),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Controle de contas mensal"),
      ),
      body: Column(
        children: [
          Container(
            child: Text(
              'Olá ' +
                  this.widget.username +
                  ', suas contas à pagar esse mês são:',
              style: TextStyle(fontSize: 20),
            ),
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
          ),
          this.loadingBills
              ? Center(
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                  heightFactor: 10,
                )
              : this.bills.length == 0
                  ? Container(
                      child: Text(
                          'Você não possui nenhuma conta ainda, use o botão para cadastrar!'),
                      margin:
                          EdgeInsets.symmetric(vertical: 100, horizontal: 50))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: this.bills.length,
                        itemBuilder: (context, index) {
                          Bill billItem = this.bills[index];
                          return Card(
                            elevation: 5,
                            margin:
                                EdgeInsets.only(left: 70, right: 70, top: 30),
                            child: ListTile(
                              title: Text(billItem.description),
                              subtitle: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        child: Icon(Icons.money),
                                        margin: EdgeInsets.only(right: 20),
                                      ),
                                      Text(
                                        billItem.value.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: Icon(Icons.date_range),
                                        margin: EdgeInsets.only(right: 20),
                                      ),
                                      Text(
                                        billItem.dueDate.day.toString() +
                                            '-' +
                                            billItem.dueDate.month.toString() +
                                            '-' +
                                            billItem.dueDate.year.toString(),
                                        style: TextStyle(
                                            color: billItem.dueDate
                                                    .difference(DateTime.now())
                                                    .isNegative
                                                ? Colors.red
                                                : Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteBill(billItem.id)),
                              onTap: () => _handleEditBill(billItem),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleNewBill,
        label: Text('Nova conta'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
