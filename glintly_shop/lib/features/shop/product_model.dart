import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final int priceCents;
  final String imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        priceCents: json['price_cents'] as int,
        imageUrl: json['image_url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price_cents': priceCents,
        'image_url': imageUrl,
      };

  @override
  List<Object?> get props => [id, title, description, priceCents, imageUrl];
}