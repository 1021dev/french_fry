class User {
  String uid;
  String username;
  String avatarUrl;
  String phone;
  String deviceToken;

  User({this.uid, this.username, this.avatarUrl, this.phone, this.deviceToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String,
        phone: json['phone'] as String,
        deviceToken: json['deviceToken'] ?? '');
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'avatarUrl': avatarUrl,
        'phone': phone,
        'deviceToken': deviceToken
      };
}
