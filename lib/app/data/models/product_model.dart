class ProductModel {
  int? id;
  String? image;
  String? name;
  int? quantity;
  double? price;
  double? rating;
  String? reviews;
  String? size;
  bool? isFavorite;
  bool inCart;
  String? description;
  String? category;
  String? brand;
  String? color;
  bool? featured;
  double? discount;
  bool? inStock;
  DateTime? createdAt;
  DateTime? updatedAt;

  ProductModel({
    this.id,
    this.image,
    this.name,
    this.price,
    this.rating,
    this.reviews,
    this.size,
    this.isFavorite,
    this.quantity = 0,
    this.inCart = false,
    this.description,
    this.category,
    this.brand,
    this.color,
    this.featured,
    this.discount,
    this.inStock,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String? image = json['image']?.toString();

    if (image != null && image.isNotEmpty && !image.startsWith('http')) {
      if (image.startsWith('/uploads/')) {
        image = 'http://localhost:8080$image';
      } else {
        image = 'http://localhost:8080/uploads/$image';
      }
    }

    DateTime? parseDate(String? value) =>
        value == null ? null : DateTime.tryParse(value);

    return ProductModel(
      id: json['id'] as int?,
      image: image,
      name: json['name'] as String?,
      quantity: json['quantity'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: json['reviews'] as String?,
      size: json['size'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      inCart: json['inCart'] as bool? ?? false,
      description: json['description'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      featured: json['featured'] as bool?,
      discount: (json['discount'] as num?)?.toDouble(),
      inStock: json['inStock'] as bool?,
      createdAt: parseDate(json['createdAt']?.toString()),
      updatedAt: parseDate(json['updatedAt']?.toString()),
    );
  }

  factory ProductModel.fromDb(Map<String, dynamic> row) {
    return ProductModel(
      id: row['id'] as int?,
      image: row['image'] as String?,
      name: row['name'] as String?,
      quantity: row['quantity'] as int?,
      price: (row['price'] as num?)?.toDouble(),
      rating: (row['rating'] as num?)?.toDouble(),
      reviews: row['reviews'] as String?,
      size: row['size'] as String?,
      isFavorite: (row['isFavorite'] as int?) == 1,
      inCart: (row['inCart'] as int?) == 1,
      description: row['description'] as String?,
      category: row['category'] as String?,
      brand: row['brand'] as String?,
      color: row['color'] as String?,
      featured: (row['featured'] as int?) == 1,
      discount: (row['discount'] as num?)?.toDouble(),
      inStock: (row['inStock'] as int?) == 1,
      createdAt: _parseMillis(row['createdAt'] as int?),
      updatedAt: _parseMillis(row['updatedAt'] as int?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'quantity': quantity,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'size': size,
      'isFavorite': isFavorite,
      'inCart': inCart,
      'description': description,
      'category': category,
      'brand': brand,
      'color': color,
      'featured': featured,
      'discount': discount,
      'inStock': inStock,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'quantity': quantity,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'size': size,
      'isFavorite': (isFavorite ?? false) ? 1 : 0,
      'inCart': inCart ? 1 : 0,
      'description': description,
      'category': category,
      'brand': brand,
      'color': color,
      'featured': (featured ?? false) ? 1 : 0,
      'discount': discount,
      'inStock': (inStock ?? true) ? 1 : 0,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  static DateTime? _parseMillis(int? value) {
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
}


