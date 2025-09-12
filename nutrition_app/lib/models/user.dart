class User {
  String? username;
  String? email_id;
  String? password;
  String? token;

  User({
    this.username,
    this.email_id,
    this.password,
    this.token,
  });

  // Convert a User object into a map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (email_id != null) data['email_id'] = email_id;
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (token != null) data['token'] = token;
    return data;
  }

  // Create a User object from a map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email_id: json['email_id'],
      username: json['username'],
      password: json['password'],
      token: json['token'],
    );
  }
}
