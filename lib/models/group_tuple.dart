class GroupTuple {
  String id;
  String name;
  int role;

  GroupTuple({this.id, this.name, this.role});

  static GroupTuple fromMap(Map<dynamic, dynamic> data) {
    return data == null
        ? null
        : new GroupTuple(
            id: data['id'], name: data['name'], role: data['role']);
  }

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['name'] = name;
    map['role'] = role;
    return map;
  }

  @override
  String toString() => 'GroupTuple $id -- Consumed at $name';
}
