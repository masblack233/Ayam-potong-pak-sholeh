import '../core/enums.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double basePrice;        // harga per ekor atau per kg
  final ProductType type;
  final String? imageUrl;
  final double? minWeightKg;     // berat min per ekor (untuk tipe perEkor)
  final double? maxWeightKg;
  final double weightStep;       // kelipatan (0.5 atau 1.0)
  final bool isAvailable;
  final int stock;               // stok dalam ekor atau kg
  final String? category;        // Utuh, Dada, Paha, dll
  final double? flashSalePrice;
  final DateTime? flashSaleEnd;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.type,
    this.imageUrl,
    this.minWeightKg,
    this.maxWeightKg,
    this.weightStep = 1.0,
    this.isAvailable = true,
    this.stock = 0,
    this.category,
    this.flashSalePrice,
    this.flashSaleEnd,
    required this.createdAt,
  });

  bool get hasActiveFlashSale =>
      flashSalePrice != null &&
      flashSaleEnd != null &&
      flashSaleEnd!.isAfter(DateTime.now());

  double get effectivePrice =>
      hasActiveFlashSale ? flashSalePrice! : basePrice;

  double get discountPercent {
    if (!hasActiveFlashSale) return 0;
    return ((basePrice - flashSalePrice!) / basePrice * 100).roundToDouble();
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        basePrice: (json['base_price'] as num).toDouble(),
        type: json['type'] == 'per_ekor'
            ? ProductType.perEkor
            : ProductType.perKg,
        imageUrl: json['image_url'] as String?,
        minWeightKg: (json['min_weight_kg'] as num?)?.toDouble(),
        maxWeightKg: (json['max_weight_kg'] as num?)?.toDouble(),
        weightStep: (json['weight_step'] as num?)?.toDouble() ?? 1.0,
        isAvailable: json['is_available'] as bool? ?? true,
        stock: json['stock'] as int? ?? 0,
        category: json['category'] as String?,
        flashSalePrice: (json['flash_sale_price'] as num?)?.toDouble(),
        flashSaleEnd: json['flash_sale_end'] != null
            ? DateTime.parse(json['flash_sale_end'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'base_price': basePrice,
        'type': type == ProductType.perEkor ? 'per_ekor' : 'per_kg',
        'image_url': imageUrl,
        'min_weight_kg': minWeightKg,
        'max_weight_kg': maxWeightKg,
        'weight_step': weightStep,
        'is_available': isAvailable,
        'stock': stock,
        'category': category,
        'flash_sale_price': flashSalePrice,
        'flash_sale_end': flashSaleEnd?.toIso8601String(),
      };

  Product copyWith({
    double? basePrice,
    bool? isAvailable,
    int? stock,
    double? flashSalePrice,
    DateTime? flashSaleEnd,
    String? imageUrl,
  }) {
    return Product(
      id: id,
      name: name,
      description: description,
      basePrice: basePrice ?? this.basePrice,
      type: type,
      imageUrl: imageUrl ?? this.imageUrl,
      minWeightKg: minWeightKg,
      maxWeightKg: maxWeightKg,
      weightStep: weightStep,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
      category: category,
      flashSalePrice: flashSalePrice ?? this.flashSalePrice,
      flashSaleEnd: flashSaleEnd ?? this.flashSaleEnd,
      createdAt: createdAt,
    );
  }
}
