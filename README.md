# manunitedapk

Project Flutter untuk e‑commerce sederhana (struktur project disesuaikan dengan kode Anda).

**Isi utama repository**
- `lib/` — kode aplikasi:
	- `data/`: data statis (mis. `products.dart`)
	- `models/`: model data (mis. `shippingaddressmodel.dart`)
	- `pages/`: UI dan route utama (contoh: `dashboard_page.dart`, `login_page.dart`, `register_page.dart`, `productdetail.dart`, `cart.dart`, `checkout.dart`, `orderhistory.dart`, `profile.dart`, `editprofile.dart`, `shipping_address.dart`, `addeditaddres.dart`, `wishlist.dart`, `splashscreen.dart`, `welcome.dart`)
	- `services/`: layanan aplikasi (API, auth, cart, profile, address, dll.)
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` — folder platform
- `assets/images/` — gambar dan aset lainnya

README ini berisi langkah untuk menjalankan project, membangun APK/AAB Android, menandatangani (sign) release, dan beberapa tips troubleshooting.

**Prasyarat**
- Flutter SDK (https://docs.flutter.dev/get-started/install). Pastikan `flutter` tersedia di PATH.
- Android SDK (Android Studio) dan set up device/emulator.
- Java JDK (untuk `keytool`) dan ADB (Android Platform Tools).

Quick start — clone & jalankan

```powershell
git clone <your-repo-url>
cd manunitedapk
flutter pub get
flutter run
```

Pilih device eksplisit (opsional):

```powershell
flutter devices
flutter run -d <device-id>
```

Menjelaskan struktur kode singkat
- `lib/pages`: setiap file halaman biasanya mengandung widget dan logic tampilan.
- `lib/services`: tempat komunikasi ke backend (`apiservice.dart`, `authservice.dart`, dll.). Jika aplikasi membutuhkan URL base/API key, cari file `apiservice.dart` untuk menyesuaikan konfigurasi.
- `lib/models` dan `lib/data`: model dan data statis.

Build APK / AAB

- Build debug APK (cepat, tidak dioptimalkan):

```powershell
flutter build apk --debug
```

- Build release APK (optimasi, unsigned jika belum dikonfigurasi signing):

```powershell
flutter build apk --release
```

- Build App Bundle (AAB) untuk Play Store:

```powershell
flutter build appbundle --release
```

Untuk membangun beberapa APK per ABI (lebih kecil per arsitektur):

```powershell
flutter build apk --split-per-abi
```

Menandatangani (Signing) untuk rilis

Langkah singkat:

1) Buat keystore (PowerShell / CMD):

```powershell
keytool -genkey -v -keystore release-key.jks -alias <key_alias> -keyalg RSA -keysize 2048 -validity 10000
```

2) Buat `key.properties` di root project (tidak di-commit):

```
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=<key_alias>
storeFile=release-key.jks
```

Saya tambahkan `key.properties.template` di repo untuk contoh — salin file itu menjadi `key.properties` dan isi nilai Anda.

3) Konfigurasikan signing pada `android/app/build.gradle` atau `android/app/build.gradle.kts`.
	 - Jika menggunakan template Flutter standar, tambahkan block untuk membaca `key.properties` dan mengisi `signingConfigs` untuk `release`.
	 - Jika Anda mau, saya bisa menambahkan snippet Kotlin DSL (`build.gradle.kts`) untuk memuat `key.properties`.

4) Build release dan APK akan ditandatangani jika signing dikonfigurasi:

```powershell
flutter build apk --release
```

Lokasi keluaran APK/AAB
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Split APKs (per ABI): `build/app/outputs/flutter-apk/` (per-ABI files)
- AAB: `build/app/outputs/bundle/release/app-release.aab`

Install APK ke device

```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Catatan penting & troubleshooting
- Jalankan `flutter doctor -v` jika ada masalah lingkungan.
- Jika mengubah Gradle/Android files, jalankan `flutter clean` lalu `flutter pub get` sebelum build ulang.
- Pastikan API base/url ada dan diatur jika `lib/services/apiservice.dart` membutuhkan konfigurasi environment.
- Jangan commit `key.properties` atau `release-key.jks` ke repo — simpan di lokasi aman.

Tips developer
- Jalankan `flutter run --hot` (default `flutter run`) untuk hot reload selama pengembangan.
- Gunakan `flutter analyze` untuk memeriksa masalah statis.

Files yang mungkin ingin Anda cek cepat
- `lib/services/apiservice.dart` — konfigurasi endpoint
- `lib/services/authservice.dart` — login / token handling
- `lib/pages/*` — lihat routing / navigation

Next recommended steps (bisa saya bantu)
- Tambahkan `key.properties.template` (sudah saya sertakan) dan update `.gitignore` (saya akan menambahkan entri untuk `key.properties` dan `release-key.jks`).
- Tambahkan snippet `android/app/build.gradle.kts` untuk memuat `key.properties` (Kotlin DSL).
- Buat GitHub Actions workflow untuk build AAB saat push ke `main`.

Jika Anda ingin, saya bisa langsung menambahkan snippet `build.gradle.kts` dan workflow CI next.
