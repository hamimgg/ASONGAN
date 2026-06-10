import 'dart:developer';

import 'package:asongan_app/features/auth/model/user_model_sql.dart';
import 'package:asongan_app/features/seller/model/product_model_sql.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ppkd.db');

    return await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            nama TEXT,
            telepon TEXT,
            role TEXT,
            nama_toko TEXT,
            jenis_produk TEXT,
            nama_makanan TEXT,
            status_jualan INTEGER DEFAULT 1,
            jam_operasional TEXT DEFAULT '',
            lokasi TEXT DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE produk(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_pedagang INTEGER,
            nama_produk TEXT,
            harga REAL,
            deskripsi TEXT,
            image_path TEXT,
            stok INTEGER DEFAULT 0,
            is_tersedia INTEGER DEFAULT 1,
            kategori TEXT DEFAULT 'Umum',
            variasi TEXT DEFAULT '',
            FOREIGN KEY (id_pedagang) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS produk');
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            nama TEXT,
            telepon TEXT,
            role TEXT,
            nama_toko TEXT,
            jenis_produk TEXT,
            nama_makanan TEXT,
            status_jualan INTEGER DEFAULT 1,
            jam_operasional TEXT DEFAULT '',
            lokasi TEXT DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE produk(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_pedagang INTEGER,
            nama_produk TEXT,
            harga REAL,
            deskripsi TEXT,
            image_path TEXT,
            stok INTEGER DEFAULT 0,
            is_tersedia INTEGER DEFAULT 1,
            kategori TEXT DEFAULT 'Umum',
            variasi TEXT DEFAULT '',
            FOREIGN KEY (id_pedagang) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Fungsi Register CREATE
  Future<bool> registerUser(UserModelSql pengguna) async {
    final db = await database;
    try {
      await db.insert('users', pengguna.toMap());
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // Fungsi Login GET
  Future<UserModelSql?> loginUser(UserModelSql pengguna) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [pengguna.email, pengguna.password],
    );
    log(results.toString());

    if (results.isNotEmpty) {
      return UserModelSql.fromMap(results.first);
    }
    return null;
  }

  // Fungsi untuk mengambil semua data user
  Future<List<UserModelSql>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('users');
    log(results.toString());

    return results.map((map) => UserModelSql.fromMap(map)).toList();
  }

  // Fungsi untuk menghapus user berdasarkan ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi untuk memperbarui data user
  Future<bool> updateUser(UserModelSql pengguna) async {
    final db = await database;
    try {
      int count = await db.update(
        'users',
        pengguna.toMap(),
        where: 'id = ?',
        whereArgs: [pengguna.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  // ===================== CRUD PRODUK =====================

  // CREATE
  Future<bool> insertProduct(ProductModelSql produk) async {
    final db = await database;
    try {
      await db.insert('produk', produk.toMap());
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // READ (Berdasarkan ID Pedagang)
  Future<List<ProductModelSql>> getProductsByPedagang(int idPedagang) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'produk',
      where: 'id_pedagang = ?',
      whereArgs: [idPedagang],
    );
    return results.map((map) => ProductModelSql.fromMap(map)).toList();
  }

  // UPDATE
  Future<bool> updateProduct(ProductModelSql produk) async {
    final db = await database;
    try {
      int count = await db.update(
        'produk',
        produk.toMap(),
        where: 'id = ?',
        whereArgs: [produk.id],
      );
      return count > 0;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  // DELETE
  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  // READ ALL (Untuk tampil di buyer home)
  Future<List<ProductModelSql>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('produk');
    return results.map((map) => ProductModelSql.fromMap(map)).toList();
  }

  // Get user by id
  Future<UserModelSql?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return UserModelSql.fromMap(results.first);
    }
    return null;
  }

  // Get all pedagang
  Future<List<UserModelSql>> getAllPedagang() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'role = ? OR role = ? OR nama_toko IS NOT NULL',
      whereArgs: ['pedagang', 'pedagang_dan_pembeli'],
    );
    return results.map((map) => UserModelSql.fromMap(map)).toList();
  }
}
