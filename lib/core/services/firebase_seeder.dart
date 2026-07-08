import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDummyData() async {
    try {
      // 1. Seed Dummy Sellers (users collection)
      final sellersRef = _firestore.collection('users');
      final s1Doc = await sellersRef.doc('s1').get();

      if (!s1Doc.exists) {
        print('Seeding dummy sellers...');
        final dummySellers = {
          's1': {
            'id': 's1',
            'nama': 'Pak Budi',
            'role': 'pedagang',
            'nama_toko': 'Siomay Pak Budi',
            'lokasi': '200m dari kamu',
            'status_jualan': true,
            'email': 'pakbudi@asongan.com',
            'password': 'password123',
            'foto_toko': 'assets/images/tukang_siomay.png',
          },
          's2': {
            'id': 's2',
            'nama': 'Ajo',
            'role': 'pedagang',
            'nama_toko': 'Sate Padang Ajo',
            'lokasi': '450m dari kamu',
            'status_jualan': true,
            'email': 'ajo@asongan.com',
            'password': 'password123',
            'foto_toko': 'assets/images/tukang_satepadang.png',
          },
          's3': {
            'id': 's3',
            'nama': 'Mang Asep',
            'role': 'pedagang',
            'nama_toko': 'Cendol Durian Mang Asep',
            'lokasi': '500m dari kamu',
            'status_jualan': true,
            'email': 'mangasep@asongan.com',
            'password': 'password123',
            'foto_toko': 'assets/images/es_cendol.png',
          },
          's4': {
            'id': 's4',
            'nama': 'Mas Joko',
            'role': 'pedagang',
            'nama_toko': 'Bakso Urat Mas Joko',
            'lokasi': '750m dari kamu',
            'status_jualan': true,
            'email': 'masjoko@asongan.com',
            'password': 'password123',
            'foto_toko': 'assets/images/bakso.png',
          },
          's5': {
            'id': 's5',
            'nama': 'Bu RT',
            'role': 'pedagang',
            'nama_toko': 'Kue Klepon Bu RT',
            'lokasi': '1km dari kamu',
            'status_jualan': true,
            'email': 'burt@asongan.com',
            'password': 'password123',
            'foto_toko': 'assets/images/klepon.png',
          },
        };

        for (var entry in dummySellers.entries) {
          await sellersRef.doc(entry.key).set(entry.value);
        }
        print('Dummy sellers seeded successfully!');
      }

      // 2. Seed Dummy Products (products collection)
      final productsRef = _firestore.collection('products');
      final p1Doc = await productsRef.doc('p1').get();

      if (!p1Doc.exists) {
        print('Seeding dummy products...');
        final dummyProducts = {
          'p1': {
            'id': 'p1',
            'pedagang_id': 's3',
            'nama_produk': 'Es Cendol Durian',
            'harga': 15000.0,
            'deskripsi': 'Es cendol durian segar dengan pemanis gula aren asli.',
            'image_path': 'assets/images/es_cendol.png',
            'stok': 20,
            'is_tersedia': true,
            'kategori': 'Minuman',
            'variasi': 'Dingin',
          },
          'p2': {
            'id': 'p2',
            'pedagang_id': 's1',
            'nama_produk': 'Batagor Spesial',
            'harga': 18000.0,
            'deskripsi': 'Batagor renyah dengan bumbu kacang kental spesial.',
            'image_path': 'assets/images/batagor.png',
            'stok': 15,
            'is_tersedia': true,
            'kategori': 'Makanan Ringan',
            'variasi': 'Pedas / Sedang',
          },
          'p3': {
            'id': 'p3',
            'pedagang_id': 's4',
            'nama_produk': 'Bakso Urat Mantap',
            'harga': 20000.0,
            'deskripsi': 'Bakso urat daging sapi asli dengan kuah kaldu hangat.',
            'image_path': 'assets/images/bakso.png',
            'stok': 30,
            'is_tersedia': true,
            'kategori': 'Makanan Berat',
            'variasi': 'Lengkap',
          },
          'p4': {
            'id': 'p4',
            'pedagang_id': 's5',
            'nama_produk': 'Kue Klepon Lumer',
            'harga': 10000.0,
            'deskripsi': 'Klepon ketan isi gula merah cair taburan kelapa parut.',
            'image_path': 'assets/images/klepon.png',
            'stok': 50,
            'is_tersedia': true,
            'kategori': 'Makanan Ringan',
            'variasi': 'Porsi Standar',
          },
        };

        for (var entry in dummyProducts.entries) {
          await productsRef.doc(entry.key).set(entry.value);
        }
        print('Dummy products seeded successfully!');
      }
    } catch (e) {
      print('Error seeding dummy data: $e');
    }
  }
}
