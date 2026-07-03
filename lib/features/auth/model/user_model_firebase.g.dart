// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model_firebase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModelFirebase _$UserModelFirebaseFromJson(Map<String, dynamic> json) =>
    UserModelFirebase(
      id: _stringFromId(json['id']),
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      telepon: json['telepon'] as String?,
      nama: json['nama'] as String?,
      role: json['role'] as String?,
      namaToko: json['nama_toko'] as String?,
      jenisProduk: json['jenis_produk'] as String?,
      namaMakanan: json['nama_makanan'] as String?,
      statusJualan: _boolFromStatus(json['status_jualan']),
      jamOperasional: json['jam_operasional'] as String?,
      lokasi: json['lokasi'] as String?,
    );

Map<String, dynamic> _$UserModelFirebaseToJson(UserModelFirebase instance) =>
    <String, dynamic>{
      'id': _idToValue(instance.id),
      'email': instance.email,
      'password': instance.password,
      'telepon': instance.telepon,
      'nama': instance.nama,
      'role': instance.role,
      'nama_toko': instance.namaToko,
      'jenis_produk': instance.jenisProduk,
      'nama_makanan': instance.namaMakanan,
      'status_jualan': _statusToBool(instance.statusJualan),
      'jam_operasional': instance.jamOperasional,
      'lokasi': instance.lokasi,
    };
