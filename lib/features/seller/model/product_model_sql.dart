class ProductModelSql {
  final int? id;
  final int idPedagang;
  final String namaProduk;
  final double harga;
  final String deskripsi;
  final String imagePath;

  ProductModelSql({
    this.id,
    required this.idPedagang,
    required this.namaProduk,
    required this.harga,
    required this.deskripsi,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pedagang': idPedagang,
      'nama_produk': namaProduk,
      'harga': harga,
      'deskripsi': deskripsi,
      'image_path': imagePath,
    };
  }

  factory ProductModelSql.fromMap(Map<String, dynamic> map) {
    return ProductModelSql(
      id: map['id']?.toInt(),
      idPedagang: map['id_pedagang']?.toInt() ?? 0,
      namaProduk: map['nama_produk'] ?? '',
      harga: map['harga']?.toDouble() ?? 0.0,
      deskripsi: map['deskripsi'] ?? '',
      imagePath: map['image_path'] ?? '',
    );
  }
}
