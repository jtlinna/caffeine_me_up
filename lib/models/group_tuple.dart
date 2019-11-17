class GroupTuple {
  String id;
  String name;

  GroupTuple({this.id, this.name});

  static GroupTuple fromMap(Map<dynamic, dynamic> data) {
    return data == null
        ? null
        : new GroupTuple(id: data['id'], name: data['name']);
  }

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['name'] = name;
    return map;
  }

  @override
  String toString() => 'GroupTuple $id -- Consumed at $name';
}
