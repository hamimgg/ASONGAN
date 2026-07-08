# Dokumentasi Integrasi Firebase - ASONGAN App

Dokumentasi ini menjelaskan konfigurasi, arsitektur, dan perubahan yang telah diimplementasikan untuk melakukan migrasi penyimpanan data lokal (dummy data/SQLite) ke **Firebase (Cloud Firestore & Firebase Authentication)** secara realtime dan dinamis di aplikasi ASONGAN.

---

## 1. Inisialisasi Firebase & Penyemaian Data (Seeding)

Firebase telah diinisialisasi pada titik masuk utama aplikasi (`lib/main.dart`):
*   **Inisialisasi Platform**: Menggunakan konfigurasi otomatis dari `firebase_options.dart` untuk platform Android (`sun-asongan`).
*   **Offline Persistence (Tembolok Firestore)**: Mengaktifkan penyimpanan luring dengan kapasitas tak terbatas sehingga aplikasi tetap dapat berjalan saat koneksi internet terputus:
    ```dart
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    ```
*   **Database Seeder**: Memanggil `FirebaseSeeder.seedDummyData()` secara otomatis pada saat aplikasi dijalankan untuk pertama kali guna menyuntikkan data toko pedagang (`users` collection) dan produk jualan (`products` collection) jika database Firestore masih kosong.

---

## 2. Struktur Model & Layanan Data Firebase

Seluruh sistem sekarang menggunakan model data Firebase untuk mempertahankan konsistensi:

### Model Data
1.  **`UserModelFirebase`** (lib/features/auth/model/user_model_firebase.dart): Merepresentasikan profil pengguna (pembeli/pedagang) termasuk status buka toko (`status_jualan`), waktu operasional, lokasi, dan foto toko.
2.  **`ProductModelFirebase`** (lib/features/seller/model/product_model_firebase.dart): Merepresentasikan produk jualan, stok, kategori, variasi, dan ketersediaan.

### Layanan Data (Services)
1.  **`FirebaseAuthService`** (lib/features/auth/data/firebase_auth_service.dart):
    *   `registerUser()`: Mendaftarkan akun ke Firebase Authentication, kemudian membuat dokumen profil pengguna di Firestore dengan `uid` yang sama.
    *   `loginUser()`: Melakukan sign-in dengan email & password ke Firebase Auth dan mengambil detail profil dari Firestore.
    *   `streamUserById(id)`: Aliran realtime (Stream) untuk memantau perubahan satu profil user/toko secara langsung.
    *   `streamAllPedagang()`: Aliran realtime (Stream) daftar seluruh pedagang terdaftar.
2.  **`FirebaseProductService`** (lib/core/services/firebase_product_service.dart):
    *   `streamAllProducts()`: Aliran realtime (Stream) seluruh produk jualan (untuk beranda pembeli).
    *   `streamProductsByPedagang(pedagangId)`: Aliran realtime (Stream) produk milik pedagang tertentu.
    *   Operasi CRUD: `addProduct()`, `updateProduct()`, dan `deleteProduct()` langsung menyasar Firestore secara asinkron.

---

## 3. Implementasi Realtime pada Halaman Aplikasi

Seluruh halaman utama aplikasi ASONGAN telah terintegrasi dengan Firebase secara dinamis:

### A. Fitur Autentikasi & Profil (Auth & Profile)
*   **Halaman Login & Register** (lib/features/auth/presentation/pages/login_screen.dart, lib/features/auth/presentation/pages/register_screen.dart): Menggunakan `FirebaseAuthService` untuk autentikasi aman. Setelah login sukses, sesi lokal disimpan di SharedPreferences via `AuthService.saveUserSession`.
*   **Halaman Profil** (lib/features/auth/presentation/pages/profile_screen.dart): Memakai `StreamBuilder` lewat `streamUserById` agar perubahan data diri pembeli atau pedagang langsung ter-update di antarmuka tanpa perlu memuat ulang halaman (reload).

### B. Halaman Pembeli (Buyer Mode)
*   **Beranda Pembeli** (lib/features/buyer/presentation/pages/buyer_home_screen.dart):
    *   "Pedagang Terdekat" mengalir secara realtime dari stream `streamAllPedagang()`.
    *   "Rekomendasi Produk" mengalir secara realtime dari stream `streamAllProducts()`.
*   **Detail Toko untuk Pembeli** (lib/features/buyer/presentation/pages/buyer_store_detail_screen.dart):
    *   Memantau status buka/tutup toko pedagang secara realtime melalui `streamUserById(id)`.
    *   Menampilkan menu jualan realtime melalui `streamProductsByPedagang(id)`. Jika pedagang menambah/mengurangi/mengubah produk dari aplikasi mereka, daftar menu pembeli akan langsung ter-update seketika.
*   **Explore (Peta Google Maps)** (lib/features/buyer/presentation/pages/explore_screen.dart): Menggunakan langganan stream `streamAllPedagang()` untuk memperbarui marker lokasi pedagang aktif dan status jualan mereka langsung di atas peta secara dinamis.
*   **Daftar Toko Pedagang** (lib/features/buyer/presentation/pages/order_screen.dart): Menampilkan daftar toko pedagang lengkap dengan kalkulasi jumlah stok jualan mereka secara realtime yang bersumber dari stream produk gabungan.

### C. Halaman Penjual/Pedagang (Seller Mode)
*   **Ringkasan Toko / Dashboard** (lib/features/seller/presentation/pages/seller_home_screen.dart): Menghitung jumlah total menu secara otomatis berdasarkan stream database produk dan menampilkan status aktif toko (Buka/Tutup) secara dinamis.
*   **Kelola Dagangan** (lib/features/seller/presentation/pages/seller_screen.dart):
    *   Menampilkan daftar produk jualan milik pedagang yang sedang login secara realtime.
    *   Aksi tambah, edit, dan hapus menu dilakukan langsung ke Firestore melalui form bottom sheet (lib/features/seller/presentation/widgets/product_form_bottom_sheet.dart). Firestore otomatis memicu pembaruan UI (reactive update) tanpa perlu memanggil `setState` manual setelah proses simpan.
*   **Pengaturan Detail Toko** (lib/features/seller/presentation/pages/store_detail_screen.dart): Mengizinkan pedagang mengubah nama toko, jam operasional, lokasi (bisa dideteksi via GPS Geolocator), dan foto toko. Hasil penyimpanan langsung dikirim ke dokumen pengguna di Firestore.

---

## 4. Perbaikan & Penyesuaian Kode yang Dilakukan

Saat memverifikasi kode menggunakan alat statis analisis (`flutter analyze`), kami mengidentifikasi dan memperbaiki masalah berikut:
1.  **Error Undefined Class/Method**: Pada file `lib/features/buyer/presentation/pages/buyer_store_detail_screen.dart` (baris 36), terdapat pemanggilan `FirebaseAuthService()` namun kelas tersebut belum diimpor ke dalam file.
    *   *Solusi*: Menambahkan baris impor `import 'package:asongan_app/features/auth/data/firebase_auth_service.dart';` pada bagian atas berkas.
2.  **Pemecahan Dependensi Baru**: Menjalankan `flutter pub get` untuk memastikan seluruh library pendukung (`cloud_firestore`, `firebase_auth`, `firebase_core`, `geolocator`, `geocoding`) terunduh dengan sempurna dan siap digunakan dalam proses kompilasi.

---

## 5. Ringkasan Arsitektur Aliran Data (Dataflow)

```mermaid
graph TD
    subgraph Klien (Aplikasi Flutter)
        UI[Antarmuka / Pages]
        AuthSvc[FirebaseAuthService]
        ProdSvc[FirebaseProductService]
        LocalSession[AuthService - SharedPrefs]
    end

    subgraph Server (Firebase Cloud)
        FA[Firebase Authentication]
        FS[(Cloud Firestore)]
    end

    UI -->|Picu Login/Register| AuthSvc
    AuthSvc -->|Autentikasi Kredensial| FA
    AuthSvc -->|Tulis/Baca Profil| FS
    AuthSvc -.->|Simpan Sesi| LocalSession
    
    UI -->|Streaming Data Realtime| FS
    UI -->|Picu Tambah/Edit/Hapus Produk| ProdSvc
    ProdSvc -->|Tulis/Hapus Dokumen| FS
```

Dengan integrasi ini, seluruh data pada aplikasi ASONGAN kini berjalan secara realtime dan tersinkronisasi langsung antar pengguna (Pembeli dan Pedagang) tanpa latensi pemuatan manual.
