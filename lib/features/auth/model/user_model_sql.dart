import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModelSql {
  final int? id;
  final String email;
  final String password;
  final String? telepon;
  final String? nama;
  final String? role;
  final String? namaToko;
  final String? jenisProduk;
  final String? namaMakanan;
  final bool? statusJualan;
  final String? jamOperasional;
  final String? lokasi;
  final String? fotoToko;

  UserModelSql({
    this.id,
    required this.email,
    required this.password,
    this.telepon,
    this.nama,
    this.role,
    this.namaToko,
    this.jenisProduk,
    this.namaMakanan,
    this.statusJualan,
    this.jamOperasional,
    this.lokasi,
    this.fotoToko,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'password': password,
      'nama': nama,
      'telepon': telepon,
      'role': role,
      'nama_toko': namaToko,
      'jenis_produk': jenisProduk,
      'nama_makanan': namaMakanan,
      'status_jualan': (statusJualan ?? true) ? 1 : 0,
      'jam_operasional': jamOperasional,
      'lokasi': lokasi,
      'foto_toko': fotoToko,
    };
  }

  factory UserModelSql.fromMap(Map<String, dynamic> map) {
    return UserModelSql(
      id: map['id'] != null ? map['id'] as int : null,
      email: map['email'] as String,
      password: map['password'] as String,
      telepon: map['telepon'] != null ? map['telepon'] as String : null,
      nama: map['nama'] != null ? map['nama'] as String : null,
      role: map['role'] != null ? map['role'] as String : null,
      namaToko: map['nama_toko'] != null ? map['nama_toko'] as String : null,
      jenisProduk: map['jenis_produk'] != null ? map['jenis_produk'] as String : null,
      namaMakanan: map['nama_makanan'] != null ? map['nama_makanan'] as String : null,
      statusJualan: map['status_jualan'] != null ? map['status_jualan'] == 1 : true,
      jamOperasional: map['jam_operasional'] != null ? map['jam_operasional'] as String : null,
      lokasi: map['lokasi'] != null ? map['lokasi'] as String : null,
      fotoToko: map['foto_toko'] != null ? map['foto_toko'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModelSql.fromJson(String source) =>
      UserModelSql.fromMap(json.decode(source) as Map<String, dynamic>);
}
