import 'package:hive/hive.dart';

part 'wish_model.g.dart';

@HiveType(typeId: 1)
class WishModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? image;

  @HiveField(3)
  String price;

  @HiveField(4)
  Map<String, dynamic>? pledgedBy;

  @HiveField(5)
  String? associatedEvent;

  WishModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.pledgedBy,
    this.associatedEvent,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "price": price,
      "pledgedBy": pledgedBy,
      "associatedEvent": associatedEvent,
    };
  }

  static WishModel fromJson(Map<String, dynamic> json) {
    return WishModel(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      price: json["price"],
      pledgedBy: json["pledgedBy"],
      associatedEvent: json["associatedEvent"],
    );
  }
}
