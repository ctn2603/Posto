class Users {
  final List<Map<String, dynamic>> users;
  const Users({required this.users});

  factory Users.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedUsers = List<Map<String, dynamic>>.from(
      json['users'].map((user) => Map<String, dynamic>.from(user)),
    );
    return Users(users: parsedUsers);
  }
}
