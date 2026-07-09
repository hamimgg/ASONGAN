import 'package:asongan_app/features/seller/model/product_model_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asongan_app/features/buyer/model/buyer_dummy_data.dart';

class FirebaseProductService {
  static final FirebaseProductService _instance = FirebaseProductService._internal();
  factory FirebaseProductService() => _instance;
  FirebaseProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===================== REALTIME STREAMS =====================

  List<ProductModelFirebase> _getDummyProducts() {
    return dummyRecommendedProducts.map((p) {
      String desc = 'Jajanan lezat terdekat';
      String kat = 'Umum';
      String varOption = '';
      if (p.id == 'p1') {
        desc = 'Es cendol durian segar dengan pemanis gula aren asli.';
        kat = 'Minuman';
        varOption = 'Dingin';
      } else if (p.id == 'p2') {
        desc = 'Batagor renyah dengan bumbu kacang kental spesial.';
        kat = 'Makanan Ringan';
        varOption = 'Pedas / Sedang';
      } else if (p.id == 'p3') {
        desc = 'Bakso urat daging sapi asli dengan kuah kaldu hangat.';
        kat = 'Makanan Berat';
        varOption = 'Lengkap';
      } else if (p.id == 'p4') {
        desc = 'Klepon ketan isi gula merah cair taburan kelapa parut.';
        kat = 'Makanan Ringan';
        varOption = 'Porsi Standar';
      }
      return ProductModelFirebase(
        id: p.id,
        pedagangId: p.sellerId,
        namaProduk: p.name,
        harga: p.price.toDouble(),
        deskripsi: desc,
        imagePath: p.imagePath,
        stok: 10,
        isTersedia: true,
        kategori: kat,
        variasi: varOption,
      );
    }).toList();
  }

  // Stream semua produk secara realtime (untuk beranda pembeli)
  Stream<List<ProductModelFirebase>> streamAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      final List<ProductModelFirebase> list = snapshot.docs
          .map((doc) => ProductModelFirebase.fromMap(doc.data(), docId: doc.id))
          .toList();

      final List<ProductModelFirebase> dummyProds = _getDummyProducts();

      for (var dummy in dummyProds) {
        if (!list.any((p) => p.id == dummy.id)) {
          list.add(dummy);
        }
      }

      return list;
    });
  }

  // Stream produk milik satu pedagang secara realtime (untuk kelola dagangan & detail toko)
  Stream<List<ProductModelFirebase>> streamProductsByPedagang(String pedagangId) {
    return _firestore
        .collection('products')
        .where('pedagang_id', isEqualTo: pedagangId)
        .snapshots()
        .map((snapshot) {
      final List<ProductModelFirebase> list = snapshot.docs
          .map((doc) => ProductModelFirebase.fromMap(doc.data(), docId: doc.id))
          .toList();

      final List<ProductModelFirebase> dummyProds = _getDummyProducts()
          .where((p) => p.pedagangId == pedagangId)
          .toList();

      for (var dummy in dummyProds) {
        if (!list.any((p) => p.id == dummy.id)) {
          list.add(dummy);
        }
      }

      return list;
    });
  }

  // ===================== ONE-TIME READS =====================

  // Get all products
  Future<List<ProductModelFirebase>> getAllProducts() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      final List<ProductModelFirebase> list = querySnapshot.docs.map((doc) {
        return ProductModelFirebase.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }).toList();

      final List<ProductModelFirebase> dummyProds = _getDummyProducts();

      for (var dummy in dummyProds) {
        if (!list.any((p) => p.id == dummy.id)) {
          list.add(dummy);
        }
      }

      return list;
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
  Future<String?> addProduct(ProductModelFirebase product) async {
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
      return null;
    } catch (e) {
      print('Error adding product: $e');
      return e.toString();
    }
  }

  // Update a product
  Future<String?> updateProduct(ProductModelFirebase product) async {
    if (product.id == null) return 'Product ID is null';
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      return null;
    } catch (e) {
      print('Error updating product: $e');
      return e.toString();
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
