import 'package:flutter/material.dart';

import '../models/bill.dart';

class BillForm extends StatefulWidget {
  final Function createBill;
  final Function editBill;
  final Bill bill;

  BillForm({this.createBill, this.bill, this.editBill});

  @override
  _BillFormState createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _controllerForValue = TextEditingController();
  final _controllerForDescription = TextEditingController();
  final _controllerForDate = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (this.widget.bill != null) {
      this._controllerForDescription.text = this.widget.bill.description;
      this._controllerForValue.text = this.widget.bill.value.toString();
      this.selectedDate = this.widget.bill.dueDate;
      this._controllerForDate.text = this.widget.bill.dueDate.day.toString() +
          '-' +
          this.widget.bill.dueDate.month.toString() +
          '-' +
          this.widget.bill.dueDate.year.toString();
    }
  }

  String _validateValue(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite o valor da conta';
    } else {
      final n = num.tryParse(value);

      if (n != null && n < 0) {
        validationResult = 'O valor da conta não pode ser negativo';
      }
    }

    return validationResult;
  }

  void _create() {
    this.widget.createBill(
          this._controllerForDescription.text,
          num.parse(this._controllerForValue.text),
          selectedDate,
        );
    Navigator.pop(context);
  }

  void _edit() {
    this.widget.bill.description = this._controllerForDescription.text;
    this.widget.bill.value = num.parse(this._controllerForValue.text);
    this.widget.bill.dueDate = this.selectedDate;
    this.widget.editBill(this.widget.bill);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    void _selectDate() async {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: this.selectedDate, // Refer step 1
          firstDate: DateTime(2000),
          lastDate: DateTime(2025),
          cancelText: 'Cancelar',
          helpText: 'Selecione uma data');
      if (picked != null && picked != this.selectedDate) {
        setState(() {
          this.selectedDate = picked;
          this._controllerForDate.text = picked.day.toString() +
              '-' +
              picked.month.toString() +
              '-' +
              picked.year.toString();
        });
      }
    }

    void _cancel() {
      Navigator.pop(context);
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: this._controllerForDescription,
              decoration: InputDecoration(
                labelText: 'Descrição da conta',
                errorMaxLines: 2,
              ),
            ),
            margin: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForValue,
              decoration: InputDecoration(
                labelText: '* Valor',
                errorMaxLines: 2,
              ),
              validator: this._validateValue,
              keyboardType: TextInputType.number,
            ),
            margin: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForDate,
              decoration: InputDecoration(
                labelText: '* Data de vencimento',
                errorMaxLines: 2,
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            margin: EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 10),
          ),
          Row(
            children: [
              this.widget.bill == null
                  ? Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _create,
                        child: Text('Criar conta'),
                      ),
                      margin: EdgeInsets.all(10),
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _edit,
                        child: Text('Editar conta'),
                      ),
                      margin: EdgeInsets.all(10),
                    ),
              Container(
                child: ElevatedButton(
                  onPressed: _cancel,
                  child: Text('Cancelar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }
}
