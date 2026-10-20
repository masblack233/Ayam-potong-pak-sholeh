import 'package:flutter/foundation.dart';
import '../core/supabase_service.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Semua';

  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _products
        .map((p) => p.category ?? 'Lainnya')
        .toSet()
        .toList();
    return ['Semua', ...cats];
  }

  List<Product> get filteredProducts {
    if (_selectedCategory == 'Semua') return _products;
    return _products
        .where((p) => (p.category ?? 'Lainnya') == _selectedCategory)
        .toList();
  }

  List<Product> get flashSaleProducts =>
      _products.where((p) => p.hasActiveFlashSale).toList();

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await SupabaseService.client
          .from('products')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);
      _products = (data as List).map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      _error = 'Gagal memuat produk: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addProduct(Product product) async {
    try {
      await SupabaseService.client
          .from('products')
          .insert(product.toJson());
      await fetchProducts();
      return null;
    } catch (e) {
      return 'Gagal menambah produk: $e';
    }
  }

  Future<String?> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await SupabaseService.client
          .from('products')
          .update(data)
          .eq('id', id);
      await fetchProducts();
      return null;
    } catch (e) {
      return 'Gagal memperbarui produk: $e';
    }
  }

  Future<String?> deleteProduct(String id) async {
    try {
      await SupabaseService.client.from('products').update({
        'is_available': false,
      }).eq('id', id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Gagal menghapus produk: $e';
    }
  }
}
