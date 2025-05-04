import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String username;

  @HiveField(3)
  String email;

  @HiveField(4)
  String? profilePicture;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "username": username,
      "email": email,
      "profilePicture": profilePicture,
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      name: json["name"],
      username: json["username"],
      email: json["email"],
      profilePicture: json["profilePicture"],
    );
  }
}
