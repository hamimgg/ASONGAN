import 'package:asongan_app/features/seller/model/product_model_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProductService {
  static final FirebaseProductService _instance = FirebaseProductService._internal();
  factory FirebaseProductService() => _instance;
  FirebaseProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===================== REALTIME STREAMS =====================

  // Stream semua produk secara realtime (untuk beranda pembeli)
  Stream<List<ProductModelFirebase>> streamAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModelFirebase.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // Stream produk milik satu pedagang secara realtime (untuk kelola dagangan & detail toko)
  Stream<List<ProductModelFirebase>> streamProductsByPedagang(String pedagangId) {
    return _firestore
        .collection('products')
        .where('pedagang_id', isEqualTo: pedagangId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModelFirebase.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // ===================== ONE-TIME READS =====================

  // Get all products
  Future<List<ProductModelFirebase>> getAllProducts() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        return ProductModelFirebase.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }).toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  // Get products by pedagang ID
  Future<List<ProductModelFirebase>> getProductsByPedagang(String pedagangId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('pedagang_id', isEqualTo: pedagangId)
          .get();
      return querySnapshot.docs.map((doc) {
        return ProductModelFirebase.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }).toList();
    } catch (e) {
      print('Error getting products by pedagang: $e');
      return [];
    }
  }

  // Add a product
  Future<bool> addProduct(ProductModelFirebase product) async {
    try {
      final docRef = _firestore.collection('products').doc();
      final productWithId = ProductModelFirebase(
        id: docRef.id,
        pedagangId: product.pedagangId,
        namaProduk: product.namaProduk,
        harga: product.harga,
        deskripsi: product.deskripsi,
        imagePath: product.imagePath,
        stok: product.stok,
        isTersedia: product.isTersedia,
        kategori: product.kategori,
        variasi: product.variasi,
      );
      await docRef.set(productWithId.toMap());
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Update a product
  Future<bool> updateProduct(ProductModelFirebase product) async {
    if (product.id == null) return false;
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}
