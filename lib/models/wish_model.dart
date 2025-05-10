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

  // Add copyWith method to create modified copies
  WishModel copyWith({
    String? id,
    String? name,
    String? image,
    String? price,
    Map<String, dynamic>? pledgedBy,
    String? associatedEvent,
  }) {
    return WishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      pledgedBy:
          pledgedBy, // Deliberately not using ??. We want it to be null if null is passed
      associatedEvent: associatedEvent ?? this.associatedEvent,
    );
  }

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
