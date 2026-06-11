# 🛒 Asongan

> Connecting street food vendors with nearby buyers.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?logo=sqlite&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📖 About

**Asongan** is a Flutter-based mobile application designed to empower street food vendors (*pedagang kaki lima*) in Indonesia. The app bridges the gap between vendors and nearby buyers, helping small businesses gain visibility and connect with customers in their local area.

Built with a social-impact mission at its core, Asongan aims to modernize the way street vendors operate — giving them a digital presence without the complexity of large e-commerce platforms.

---

## ✨ Features

### For Buyers
- 🔍 Discover vendors and menus nearby
- 📋 Browse full menu listings with prices
- 💬 Contact vendors directly via WhatsApp
- 👤 Manage personal account profile

### For Sellers (Vendors)
- 🏪 Manage store profile (name, description, location)
- 🍜 Full menu management (add, edit, delete)
- 📸 Upload menu photos from gallery or camera
- 📊 Seller dashboard overview

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Main UI framework |
| Dart | Programming language |
| sqflite | Local database (SQLite) |
| image_picker | Photo selection from gallery/camera |
| shared_preferences | User preference storage |
| path_provider | Local file path management |

---

## 📁 Project Structure

```
lib/
├── main.dart               # App entry point
├── models/
│   ├── pedagang_model.dart # Vendor data model
│   └── menu_model.dart     # Menu data model
├── database/
│   └── db_helper.dart      # SQLite helper (sqflite)
├── screens/
│   ├── buyer/              # Buyer-side screens
│   └── seller/             # Seller-side screens
├── widgets/
│   ├── app_drawer.dart     # Navigation drawer & role switching
│   └── main_wrapper.dart   # Main navigation wrapper (IndexedStack)
└── utils/
    └── constants.dart      # App-wide constants
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio or VS Code
- Android Emulator or physical device (Android 6.0+)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/username/asongan.git
   cd asongan
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

### Build APK

```bash
# Debug build (for testing)
flutter build apk --debug

# Release build (for distribution)
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/`

---

## 🎨 Design & Branding

| Element | Value |
|---|---|
| Primary Color | `#F5A623` (Orange) |
| Secondary Color | `#1C1C1E` (Near Black) |
| Font | Plus Jakarta Sans |

---

## 🗄️ Database Schema

### Table `pedagang` (vendors)
| Column | Type | Description |
|---|---|---|
| id | INTEGER | Primary key (autoincrement) |
| nama | TEXT | Vendor name |
| deskripsi | TEXT | Store description |
| lokasi | TEXT | Selling location |
| foto | TEXT | Profile photo path |

### Table `menu`
| Column | Type | Description |
|---|---|---|
| id | INTEGER | Primary key (autoincrement) |
| pedagang_id | INTEGER | Foreign key to vendors table |
| nama | TEXT | Menu item name |
| harga | INTEGER | Price |
| deskripsi | TEXT | Item description |
| foto | TEXT | Menu photo path |

---

## 👥 Contributors

| Name | Role |
|---|---|
| [Hamim Abdillah] | Developer |


---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

This app was built with a genuine passion for supporting Indonesia's street vendor community. Thank you to every *pedagang kaki lima* who inspired this project.

---

<p>Made with ❤️ for Indonesia's street vendors</p>
