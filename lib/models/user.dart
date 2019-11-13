class User {
  String uid;
  String email;
  bool verified;

  User({this.uid, this.email, this.verified});

  @override
  String toString() => '$uid - Email $email (verified $verified)';
}
