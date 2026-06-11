# 🛒 Asongan

> Menghubungkan pedagang kaki lima dengan pembeli di sekitar mereka.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?logo=sqlite&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📖 Tentang Aplikasi

**Asongan** adalah aplikasi mobile berbasis Flutter yang dirancang untuk memberdayakan pedagang kaki lima (PKL) di Indonesia. Aplikasi ini menjadi jembatan antara pedagang dengan pembeli terdekat, memudahkan transaksi dan meningkatkan visibilitas usaha kecil di lingkungan sekitar.

Aplikasi ini dikembangkan sebagai bentuk kepedulian terhadap ekosistem UMKM lokal, khususnya pedagang asongan yang selama ini kesulitan menjangkau pelanggan baru.

---

## ✨ Fitur Utama

### Untuk Pembeli
- 🔍 Temukan pedagang dan menu di sekitar lokasi
- 📋 Lihat daftar menu lengkap beserta harga
- 💬 Hubungi pedagang langsung via WhatsApp
- 👤 Kelola profil akun pribadi

### Untuk Pedagang (Seller)
- 🏪 Kelola profil toko (nama, deskripsi, lokasi)
- 🍜 Manajemen menu (tambah, edit, hapus)
- 📸 Upload foto menu dari galeri atau kamera
- 📊 Dashboard ringkasan toko

---

## 🛠️ Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework utama UI |
| Dart | Bahasa pemrograman |
| sqflite | Database lokal (SQLite) |
| image_picker | Pemilihan foto dari galeri/kamera |
| shared_preferences | Penyimpanan preferensi pengguna |
| path_provider | Manajemen path file lokal |

---

## 📁 Struktur Proyek

```
lib/
├── main.dart               # Entry point aplikasi
├── models/
│   ├── pedagang_model.dart # Model data pedagang
│   └── menu_model.dart     # Model data menu
├── database/
│   └── db_helper.dart      # Helper SQLite (sqflite)
├── screens/
│   ├── buyer/              # Halaman untuk pembeli
│   └── seller/             # Halaman untuk pedagang
├── widgets/
│   ├── app_drawer.dart     # Drawer navigasi & role switching
│   └── main_wrapper.dart   # Wrapper navigasi utama (IndexedStack)
└── utils/
    └── constants.dart      # Konstanta aplikasi
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Android Emulator atau perangkat fisik (Android 6.0+)

### Langkah Instalasi

1. Clone repository ini
   ```bash
   git clone https://github.com/username/asongan.git
   cd asongan
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi
   ```bash
   flutter run
   ```

### Build APK

```bash
# Debug (untuk testing)
flutter build apk --debug

# Release (untuk distribusi)
flutter build apk --release
```

File APK tersedia di: `build/app/outputs/flutter-apk/`

---

## 🎨 Desain & Branding

| Elemen | Nilai |
|---|---|
| Warna Primer | `#F5A623` (Orange) |
| Warna Sekunder | `#1C1C1E` (Near Black) |
| Font | Default Flutter (Roboto) |

---

## 🗄️ Skema Database

### Tabel `pedagang`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | Primary key (autoincrement) |
| nama | TEXT | Nama pedagang |
| deskripsi | TEXT | Deskripsi toko |
| lokasi | TEXT | Lokasi berjualan |
| foto | TEXT | Path foto profil |

### Tabel `menu`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | Primary key (autoincrement) |
| pedagang_id | INTEGER | Foreign key ke tabel pedagang |
| nama | TEXT | Nama menu |
| harga | INTEGER | Harga menu |
| deskripsi | TEXT | Deskripsi menu |
| foto | TEXT | Path foto menu |

---

## 👥 Kontributor

| Nama | Peran |
|---|---|
| [Hamim Abdillah] | Developer |

---

## 📄 Lisensi

Proyek ini menggunakan lisensi [MIT](LICENSE).

---

## 🙏 Acknowledgements

Aplikasi ini dibangun dengan semangat untuk memberdayakan pedagang kaki lima Indonesia. Terima kasih kepada seluruh PKL yang menginspirasi lahirnya aplikasi ini.

---

<p align="center">Made with ❤️ for Indonesia's street vendors</p>
