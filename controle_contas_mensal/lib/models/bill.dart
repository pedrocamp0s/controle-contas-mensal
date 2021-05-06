class Bill {
  int id;
  String description;
  num value;
  DateTime dueDate;
  String owner;

  Bill({this.id, this.description, this.value, this.dueDate, this.owner});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'owner': owner
    };
  }
}
