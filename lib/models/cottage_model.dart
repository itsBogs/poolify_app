class CottageModel {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final String image;
  final String status;

  CottageModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.image,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'capacity': capacity,
      'image': image,
      'status': status,
    };
  }

  factory CottageModel.fromMap(Map<String, dynamic> map) {
    return CottageModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      capacity: map['capacity'],
      image: map['image'],
      status: map['status'],
    );
  }

  CottageModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? capacity,
    String? image,
    String? status,
  }) {
    return CottageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      image: image ?? this.image,
      status: status ?? this.status,
    );
  }
}
