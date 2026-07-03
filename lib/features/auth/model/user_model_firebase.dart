import 'package:json_annotation/json_annotation.dart';
import 'user_model_sql.dart';

part 'user_model_firebase.g.dart';

bool? _boolFromStatus(dynamic status) {
  if (status == null) return null;
  if (status is bool) return status;
  if (status is num) return status == 1;
  return status.toString() == 'true' || status.toString() == '1';
}

dynamic _statusToBool(bool? status) => status;

String? _stringFromId(dynamic id) => id?.toString();
dynamic _idToValue(String? id) => id;

@JsonSerializable(explicitToJson: true)
class UserModelFirebase {
  @JsonKey(fromJson: _stringFromId, toJson: _idToValue)
  final String? id;
  
  @JsonKey(defaultValue: '')
  final String email;
  
  @JsonKey(defaultValue: '')
  final String password;
  
  final String? telepon;
  final String? nama;
  final String? role;
  
  @JsonKey(name: 'nama_toko')
  final String? namaToko;
  
  @JsonKey(name: 'jenis_produk')
  final String? jenisProduk;
  
  @JsonKey(name: 'nama_makanan')
  final String? namaMakanan;
  
  @JsonKey(name: 'status_jualan', fromJson: _boolFromStatus, toJson: _statusToBool)
  final bool? statusJualan;
  
  @JsonKey(name: 'jam_operasional')
  final String? jamOperasional;
  
  final String? lokasi;

  UserModelFirebase({
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
  });

  factory UserModelFirebase.fromJson(Map<String, dynamic> json) =>
      _$UserModelFirebaseFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelFirebaseToJson(this);

  factory UserModelFirebase.fromMap(Map<String, dynamic> map) =>
      UserModelFirebase.fromJson(map);

  Map<String, dynamic> toMap() => toJson();

  factory UserModelFirebase.fromSql(UserModelSql sqlModel) {
    return UserModelFirebase(
      id: sqlModel.id?.toString(),
      email: sqlModel.email,
      password: sqlModel.password,
      telepon: sqlModel.telepon,
      nama: sqlModel.nama,
      role: sqlModel.role,
      namaToko: sqlModel.namaToko,
      jenisProduk: sqlModel.jenisProduk,
      namaMakanan: sqlModel.namaMakanan,
      statusJualan: sqlModel.statusJualan,
      jamOperasional: sqlModel.jamOperasional,
      lokasi: sqlModel.lokasi,
    );
  }

  UserModelSql toSql() {
    return UserModelSql(
      id: id != null ? int.tryParse(id!) : null,
      email: email,
      password: password,
      telepon: telepon,
      nama: nama,
      role: role,
      namaToko: namaToko,
      jenisProduk: jenisProduk,
      namaMakanan: namaMakanan,
      statusJualan: statusJualan,
      jamOperasional: jamOperasional,
      lokasi: lokasi,
    );
  }
}
