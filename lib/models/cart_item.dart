import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;         // jumlah ekor (untuk perEkor)
  final double weightKg;     // berat dalam kg (untuk perKg)
  final String? notes;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.weightKg = 1.0,
    this.notes,
  });

  double get subtotal {
    if (product.type.name == 'perKg') {
      return product.effectivePrice * weightKg;
    }
    return product.effectivePrice * quantity;
  }

  double get totalWeightKg {
    if (product.type.name == 'perKg') return weightKg;
    return (product.minWeightKg ?? 1.0) * quantity;
  }

  CartItem copyWith({int? quantity, double? weightKg, String? notes}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toOrderItem() => {
        'product_id': product.id,
        'product_name': product.name,
        'product_type': product.type.name,
        'unit_price': product.effectivePrice,
        'quantity': quantity,
        'weight_kg': weightKg,
        'subtotal': subtotal,
        'notes': notes,
      };
}
