import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===================== REALTIME STREAMS =====================

  // Stream satu user (profil/toko) secara realtime berdasarkan id (uid)
  Stream<UserModelFirebase?> streamUserById(String id) {
    return _firestore.collection('users').doc(id).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModelFirebase.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Stream semua pedagang secara realtime (untuk explore, order, beranda pembeli).
  // Filter dilakukan di sisi klien agar tidak butuh composite index Firestore.
  Stream<List<UserModelFirebase>> streamAllPedagang() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModelFirebase.fromMap(doc.data()))
          .where((user) =>
              user.role == 'pedagang' ||
              user.role == 'pedagang_dan_pembeli' ||
              (user.namaToko != null && user.namaToko!.isNotEmpty))
          .toList();
    });
  }

  // Fungsi Register CREATE
  Future<bool> registerUser(UserModelFirebase pengguna) async {
    try {
      // 1. Register di Firebase Authentication
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: pengguna.email,
        password: pengguna.password,
      );

      final String uid = userCredential.user!.uid;

      // 2. Simpan profil tambahan ke Firestore
      // Buat instance baru dengan id = uid dari Firebase Auth
      final userWithUid = UserModelFirebase(
        id: uid,
        email: pengguna.email,
        password: pengguna.password,
        telepon: pengguna.telepon,
        nama: pengguna.nama,
        role: pengguna.role,
        namaToko: pengguna.namaToko,
        jenisProduk: pengguna.jenisProduk,
        namaMakanan: pengguna.namaMakanan,
        statusJualan: pengguna.statusJualan,
        jamOperasional: pengguna.jamOperasional,
        lokasi: pengguna.lokasi,
      );

      await _firestore.collection('users').doc(uid).set(userWithUid.toMap());
      return true;
    } catch (e) {
      log('Error registering user: ${e.toString()}');
      return false;
    }
  }

  // Fungsi Login GET
  Future<UserModelFirebase?> loginUser(UserModelFirebase pengguna) async {
    try {
      // 1. Sign in dengan Firebase Authentication
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: pengguna.email,
        password: pengguna.password,
      );

      final String uid = userCredential.user!.uid;

      // 2. Ambil data dari Firestore
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        // Gabungkan dengan password yang dimasukkan saat login (jika diperlukan untuk model lokal)
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['password'] = pengguna.password;
        return UserModelFirebase.fromMap(data);
      }
      return null;
    } catch (e) {
      log('Error logging in: ${e.toString()}');
      rethrow;
    }
  }

  // Fungsi untuk mengambil semua data user
  Future<List<UserModelFirebase>> getAllUsers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        return UserModelFirebase.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      log('Error getting all users: ${e.toString()}');
      return [];
    }
  }

  // Fungsi untuk menghapus user berdasarkan ID
  Future<void> deleteUser(String id) async {
    try {
      // Hapus data Firestore
      await _firestore.collection('users').doc(id).delete();
      
      // Catatan: Menghapus user dari Firebase Authentication secara remote membutuhkan Firebase Admin SDK,
      // tapi jika ini adalah user yang sedang login saat ini, kita bisa menghapusnya lewat _auth.currentUser?.delete().
      // Di sini kita hapus dokumen Firestore-nya dulu.
    } catch (e) {
      log('Error deleting user: ${e.toString()}');
    }
  }

  // Fungsi untuk memperbarui data user
  Future<bool> updateUser(UserModelFirebase pengguna) async {
    if (pengguna.id == null) return false;
    try {
      await _firestore.collection('users').doc(pengguna.id).update(pengguna.toMap());
      return true;
    } catch (e) {
      log('Error updating user: ${e.toString()}');
      return false;
    }
  }

  // Get user by id
  Future<UserModelFirebase?> getUserById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return UserModelFirebase.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      log('Error getting user by id: ${e.toString()}');
      return null;
    }
  }

  // Get all pedagang
  Future<List<UserModelFirebase>> getAllPedagang() async {
    try {
      // Menggunakan Filter.or jika didukung oleh package cloud_firestore Anda
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where(
            Filter.or(
              Filter('role', isEqualTo: 'pedagang'),
              Filter('role', isEqualTo: 'pedagang_dan_pembeli'),
              Filter('nama_toko', isNull: false),
            ),
          )
          .get();

      return querySnapshot.docs.map((doc) {
        return UserModelFirebase.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      log('Error getting all pedagang with Filter.or, falling back to local filtering: ${e.toString()}');
      // Fallback: Ambil semua user lalu filter secara lokal jika query Filter.or gagal atau tidak didukung
      try {
        final List<UserModelFirebase> allUsers = await getAllUsers();
        return allUsers.where((user) {
          return user.role == 'pedagang' ||
              user.role == 'pedagang_dan_pembeli' ||
              (user.namaToko != null && user.namaToko!.isNotEmpty);
        }).toList();
      } catch (err) {
        log('Fallback failed: ${err.toString()}');
        return [];
      }
    }
  }
}
