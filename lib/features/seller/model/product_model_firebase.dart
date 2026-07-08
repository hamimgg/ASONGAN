class ProductModelFirebase {
  final String? id;
  final String pedagangId;
  final String namaProduk;
  final double harga;
  final String deskripsi;
  final String imagePath;
  final int stok;
  final bool isTersedia;
  final String kategori;
  final String variasi;

  ProductModelFirebase({
    this.id,
    required this.pedagangId,
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
      'pedagang_id': pedagangId,
      'nama_produk': namaProduk,
      'harga': harga,
      'deskripsi': deskripsi,
      'image_path': imagePath,
      'stok': stok,
      'is_tersedia': isTersedia,
      'kategori': kategori,
      'variasi': variasi,
    };
  }

  factory ProductModelFirebase.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ProductModelFirebase(
      id: docId ?? map['id'],
      pedagangId: map['pedagang_id'] ?? '',
      namaProduk: map['nama_produk'] ?? '',
      harga: (map['harga'] as num?)?.toDouble() ?? 0.0,
      deskripsi: map['deskripsi'] ?? '',
      imagePath: map['image_path'] ?? '',
      stok: (map['stok'] as num?)?.toInt() ?? 0,
      isTersedia: map['is_tersedia'] ?? true,
      kategori: map['kategori'] ?? 'Umum',
      variasi: map['variasi'] ?? '',
    );
  }
}
