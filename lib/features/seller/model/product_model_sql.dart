class ProductModelSql {
  final int? id;
  final int idPedagang;
  final String namaProduk;
  final double harga;
  final String deskripsi;
  final String imagePath;
  final int stok;
  final bool isTersedia;
  final String kategori;
  final String variasi;

  ProductModelSql({
    this.id,
    required this.idPedagang,
    required this.namaProduk,
    required this.harga,
    required this.deskripsi,
    required this.imagePath,
    this.stok = 0,
    this.isTersedia = true,
    this.kategori = 'Umum',
    this.variasi = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pedagang': idPedagang,
      'nama_produk': namaProduk,
      'harga': harga,
      'deskripsi': deskripsi,
      'image_path': imagePath,
      'stok': stok,
      'is_tersedia': isTersedia ? 1 : 0,
      'kategori': kategori,
      'variasi': variasi,
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
      stok: map['stok']?.toInt() ?? 0,
      isTersedia: (map['is_tersedia'] ?? 1) == 1,
      kategori: map['kategori'] ?? 'Umum',
      variasi: map['variasi'] ?? '',
    );
  }
}
