# Lab-Inventory

Aplikasi mobile **Inventaris Alat Lab** berbasis **Flutter**, terhubung ke **Firebase Authentication** dan **Cloud Firestore** secara real-time. Dibuat untuk Uji Unit Kompetensi (UUK) Mobile, Kelas XI RPL.

> **Nama:** Janeeta Samahat Nowa  
> **Kelas:** XI RPL  
> **Mata uji:** UUK Mobile, Hari ke-1 dan ke-2

---

## Video Demo Aplikasi Inventori Alat lab
📺 **[Tonton video demo disini](file:///C:/Users/Lenovo/Videos/Screen%20Recordings/Screen%20Recording%202026-11-17%20143731.mp4)**

## Daftar Isi

1. [Fitur](#fitur)
2. [Teknologi](#teknologi)
3. [Struktur Proyek](#struktur-proyek)
4. [Skema Database Firestore](#skema-database-firestore)
5. [Alur Aplikasi](#alur-aplikasi)
6. [Cara Menjalankan](#cara-menjalankan)
7. [Pemetaan ke Kisi-kisi UUK](#pemetaan-ke-kisi-kisi-uuk)
8. [Kendala dan Revisi](#kendala-dan-revisi)
9. [Batasan yang Diketahui](#batasan-yang-diketahui)

---

## Fitur

Aplikasi punya dua peran: **Siswa** dan **Admin**. Peran ditentukan oleh field `role` di `users/{uid}`.

**Untuk semua pengguna**
- Splash screen 3 detik dengan logo yang memantul, lalu diarahkan otomatis berdasarkan sesi login Firebase Auth. Pengguna yang belum logout langsung masuk ke Beranda.
- Login dan Register dengan validasi form: kolom wajib, format email, panjang dan isi password, serta pesan error Firebase dalam bahasa Indonesia.
- Beranda dengan search bar (nama atau kode), carousel banner geser otomatis dengan banner samping yang mengintip, dan tiga baris horizontal: **Semua Data**, **Kategori Peralatan** (dengan filter status), dan **Status Ketersediaan**.
- Menu bawah melayang dengan tiga tab: Beranda, Inventaris, Profil.
- Edit nama dan foto profil.
- Logout dengan dialog konfirmasi.

**Siswa**
- Register mandiri (Nama, Kelas, Email, Password). Peran selalu `siswa`.
- Meminjam alat dari detail alat di Beranda. Peminjaman memakai *transaction*, jadi dua orang tidak bisa meminjam alat yang sama bersamaan.
- Mengembalikan alat, baik dari detail alat (jika dia yang meminjam) maupun dari tab **Sedang Dipinjam** di Profil.
- Riwayat peminjaman pribadi: *Sedang Dipinjam* dan *Sudah Dikembalikan*.
- Tab Inventaris hanya menampilkan daftar alat dan statistik.

**Admin**
- Login lewat pilihan **Admin**. Login ditolak jika akun tidak punya `role: admin`.
- CRUD inventaris real-time di tab Inventaris: tambah, edit, dan hapus (hapus dengan dialog konfirmasi).
- Alat yang sedang dipinjam dikunci (tombol edit dan hapus abu-abu dengan ikon gembok), dan admin bisa melihat **siapa peminjamnya** (nama dan kelas).
- Profil admin menampilkan daftar **Alat Sedang Dipinjam** beserta peminjamnya.

Halaman Inventaris dan Profil tetap memuat teks `inventaris` dan `profil` seperti yang diminta soal.

---

## Teknologi

| Teknologi | Kegunaan |
|---|---|
| Flutter dan Dart (Material 3) | Antarmuka |
| `firebase_core` | Inisialisasi Firebase |
| `firebase_auth` | Login, register, dan sesi |
| `cloud_firestore` | Database real-time dan transaksi |
| `google_fonts` | Plus Jakarta Sans (font utama), Space Grotesk (judul), JetBrains Mono (label dan kode) |
| `intl` | Format tanggal di riwayat peminjaman |

Versi tiap package mengikuti `pubspec.yaml`. Carousel dibuat sendiri dengan `PageView` dan `Timer`, tanpa package tambahan.

---

## Struktur Proyek

```
lib/
├── main.dart
├── firebase_options.dart          (dibuat otomatis oleh flutterfire configure)
├── core/
│   └── app_colors.dart            palet warna
├── models/
│   ├── user_model.dart            termasuk role dan isAdmin
│   ├── item_model.dart            termasuk data peminjam (borrowed_by_*)
│   └── borrow_model.dart
├── services/
│   ├── auth_service.dart          login, loginAdmin, register, logout
│   └── firestore_service.dart     CRUD items, profil, pinjam dan kembali, seed data
├── screens/
│   ├── splash_screen.dart
│   ├── auth_screen.dart           pilihan Siswa/Admin, login dan register
│   ├── main_navigation_screen.dart  menu bawah 3 tab
│   ├── beranda_screen.dart
│   ├── inventaris_screen.dart     tampilan siswa dan admin
│   └── profil_screen.dart         riwayat (siswa) atau daftar peminjam (admin)
└── widgets/
    ├── item_cards.dart            3 jenis kartu alat
    ├── item_detail_sheet.dart     detail, pinjam, kembalikan
    ├── crud_item_sheet.dart       form tambah dan edit alat
    └── edit_profile_sheet.dart    form edit profil
```

Pembagian tugasnya: **screens** untuk tampilan, **services** untuk bicara ke Firebase, **models** untuk mengubah dokumen Firestore menjadi objek Dart (dan sebaliknya), **widgets** untuk potongan tampilan yang dipakai berulang.

---

## Skema Database Firestore

**`users/{uid}`**

| Field | Tipe | Keterangan |
|---|---|---|
| `user_id` | string | Sama dengan uid Auth |
| `name` | string | Nama lengkap |
| `email` | string | Email akun |
| `kelas` | string | Misalnya XI RPL 1 |
| `foto` | string | Link URL foto profil |
| `created_at` | timestamp | Waktu mendaftar |
| `role` | string | `siswa` (bawaan) atau `admin` (tambahan) |

**`items/{itemId}`**

| Field | Tipe | Keterangan |
|---|---|---|
| `item_id` | string | Sama dengan ID dokumen |
| `item_name` | string | Nama alat |
| `category` | string | Jaringan, Hardware, IoT, atau Multimedia |
| `code` | string | Kode seri unik |
| `status` | string | `Available` atau `Borrowed` |
| `image` | string | Link URL gambar |
| `spesification` | string | Spesifikasi (ejaan mengikuti soal) |
| `created_at` | timestamp | Dipakai untuk mengurutkan daftar |
| `borrowed_by_uid` | string | Hanya ada saat `Borrowed` (tambahan) |
| `borrowed_by_name` | string | Hanya ada saat `Borrowed` (tambahan) |
| `borrowed_by_kelas` | string | Hanya ada saat `Borrowed` (tambahan) |
| `borrow_date` | timestamp | Hanya ada saat `Borrowed` (tambahan) |

Field `borrowed_by_*` dihapus otomatis saat alat dikembalikan.

**`users/{uid}/borrowings/{borrowId}`**

| Field | Tipe | Keterangan |
|---|---|---|
| `borrow_id` | string | ID peminjaman |
| `item_id` | string | Alat yang dipinjam |
| `item_name` | string | Nama alat |
| `borrow_date` | timestamp | Waktu pinjam |
| `return_date` | timestamp / null | Waktu kembali (tambahan) |
| `status` | string | `Borrowed` atau `Returned` (tambahan) |

Data dummy sebanyak **18 alat** diisi otomatis saat splash oleh `seedDummyItemsIfEmpty()`. Fungsi ini memeriksa kode alat satu per satu, jadi tidak membuat data ganda walau aplikasi dibuka berkali-kali.

---

## Alur Aplikasi

```
Splash (3 detik)
   ├── belum login ──> Auth (pilih Siswa atau Admin) ──┐
   └── sudah login ────────────────────────────────────┴──> Navigasi Utama
                                                             ├── Beranda
                                                             ├── Inventaris  (CRUD hanya untuk admin)
                                                             └── Profil ──> Logout ──> Auth
```

**Pinjam** (`borrowItem`) memakai `runTransaction`:
1. Membaca status terbaru alat. Jika sudah bukan `Available`, proses dibatalkan dengan pesan "Alat sudah dipinjam orang lain".
2. Mengubah alat menjadi `Borrowed` dan mengisi data peminjam (`borrowed_by_*`).
3. Membuat catatan di `users/{uid}/borrowings`.

**Kembali** (`returnItem` dari detail, `returnBorrowedItem` dari Profil) memakai batch write: alat menjadi `Available` dengan data peminjam dihapus, dan catatan peminjaman menjadi `Returned` dengan `return_date`.

Data peminjam disimpan juga di dokumen alat supaya admin bisa melihat peminjamnya tanpa harus membaca sub-koleksi milik setiap pengguna.

---

## Cara Menjalankan

**Prasyarat:** Flutter SDK, Android Studio atau VS Code, emulator Android atau HP asli, akun Google.

1. **Ambil dependency**
   ```bash
   flutter pub get
   ```

2. **Siapkan Firebase** (di console.firebase.google.com)
   - Buat proyek baru.
   - **Authentication**, lalu aktifkan metode **Email/Password**.
   - **Firestore Database**, lalu buat database.

3. **Hubungkan Flutter ke Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Perintah ini membuat `lib/firebase_options.dart`.

4. **Android:** pastikan `minSdk` bernilai **23** atau lebih di `android/app/build.gradle`.

5. **Rules Firestore**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{db}/documents {
       match /users/{uid}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
       match /items/{id} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
   Seed data berjalan di splash sebelum login. Jika rules mewajibkan login, seed pertama kali bisa ditolak (`permission-denied`). Selama pengembangan, pakai rules yang lebih longgar untuk pengisian pertama (lihat bagian kendala).

6. **Jalankan**
   ```bash
   flutter run
   ```
   Gunakan **hot restart** (`Shift+R`) untuk perubahan di `initState`, `PageController`, atau animasi splash. Hot reload tidak cukup untuk itu.

7. **Membuat akun admin**
   - Daftar dulu sebagai siswa lewat aplikasi.
   - Di Firebase Console, buka `users`, pilih dokumen akun tersebut, lalu ubah field `role` dari `siswa` menjadi `admin` (tipe string).
   - Login lewat pilihan **Admin**.

---

## Pemetaan ke Kisi-kisi UUK

| Kisi-kisi | Letak di kode |
|---|---|
| Splashscreen dan Carousel Slider | `splash_screen.dart`, `_buildCarouselBanner` di `beranda_screen.dart` |
| Navigation | `Navigator.pushReplacement` (splash, auth, logout), `main_navigation_screen.dart` (menu bawah), `showModalBottomSheet` dan `showDialog` |
| Stateful dan Stateless widget | Stateful: splash, auth, navigasi, beranda, profil, tiga sheet. Stateless: inventaris dan tiga kartu |
| Firebase Auth | `auth_service.dart` (login, loginAdmin, register), `auth_screen.dart`, pengecekan sesi di splash |
| Firestore CRUD | `firestore_service.dart`, `inventaris_screen.dart`, `crud_item_sheet.dart` |

---

## Kendala dan Revisi

Bagian ini mencatat masalah yang dihadapi dan revisi yang dilakukan selama pengerjaan.

### 1. Alur pengerjaan diubah: Firebase dikerjakan terakhir
Awalnya semua fitur ditulis sekaligus. Karena sulit mencari penyebab error, urutannya diubah mengikuti kisi-kisi: tampilan (splash, carousel, navigasi, widget) dengan data dummy di kode dulu, baru Firebase Auth, terakhir Firestore. Dengan urutan ini, error yang muncul belakangan hampir pasti berasal dari Firebase.

### 2. "Merah semua" di editor
- **Penyebab:** `pubspec.yaml` memiliki **dua blok `dependencies:`**, dan blok kedua (berisi package tambahan) berada di bawah `flutter:`. Hanya satu blok yang terbaca, jadi package tidak pernah terpasang.
- **Penyebab lain:** satu file halaman belum dibuat padahal diimpor oleh file navigasi, dan satu `import` tertinggal bertanda komentar `//`.
- **Solusi:** satukan menjadi satu blok `dependencies:`, jalankan `flutter pub get`, buat file yang hilang, dan hapus tanda komentar.

### 3. Keyboard tidak muncul di emulator
Kolom password tidak bisa diketik padahal kode `TextField` benar. Penyebabnya masalah emulator, bukan kode. Yang dicoba: mengaktifkan **Use on-screen keyboard** di pengaturan emulator, mengaktifkan *Enable keyboard input* di konfigurasi AVD, dan **Cold Boot** emulator.

### 4. Desain dan palet warna berubah beberapa kali
Desain berawal dari palet teal dan amber, lalu berganti mengikuti palet referensi (navy dan amber, mode terang dan gelap), kemudian indigo, dan akhirnya **biru laut (`0369A1`) dengan aksen cyan**, slate sebagai warna netral, serta emerald, amber, dan rose untuk status. Warna dipusatkan di `core/app_colors.dart` agar bisa diganti dari satu tempat, termasuk warna banner. Nama konstanta `techIndigo` masih dipakai walau warnanya kini biru. Ide memakai file tema terpisah (`app_theme.dart`) dibatalkan karena membuat kode lebih sulit dipahami, dan menu bawah standar diganti menu melayang buatan sendiri.

### 5. Carousel banner dibuat ulang beberapa kali
- Desain diubah agar kartu tengah besar, kartu samping mengintip, dan ada titik indikator.
- **Kartu samping tidak terlihat:** efek mengecil (`Transform.scale`) menggeser tepi kartu samping keluar layar. Solusi akhirnya menghapus efek skala dan memakai `viewportFraction: 0.85` dengan semua kartu berukuran sama.
- **Perubahan tidak berpengaruh:** `PageController` dibuat sekali saat halaman dimulai, jadi hot reload tidak membaca nilai barunya. Harus **hot restart**.
- **Slide sesekali berpindah sendiri setelah digeser:** `_currentBanner` diubah di dua tempat (timer dan `onPageChanged`). Diperbaiki dengan menjadikan `onPageChanged` satu-satunya sumber nilai tersebut.
- Carousel loop tanpa batas sempat dicoba (halaman besar dan sisa bagi), lalu dibatalkan demi tampilan yang lebih sederhana.

### 6. RenderFlex overflow
- **7 piksel di kartu status:** tinggi `SizedBox` untuk `StatusTicketCard` hanya 74, sedangkan isinya butuh lebih. Dinaikkan menjadi **88**. Nama file dan baris penyebabnya terbaca dari pesan error `relevant error-causing widget`.
- **Overflow ratusan piksel saat dijalankan di Chrome:** muncul bersama error gambar di Chrome. Diduga karena jendela browser terlalu sempit untuk tampilan yang dirancang untuk layar HP. Cara yang lebih aman adalah menjalankan di emulator atau HP asli.

### 7. Data dummy tidak bertambah, lalu bertambah ganda
- **Tidak bertambah:** fungsi seed awalnya berhenti jika koleksi `items` sudah berisi data (`if (isNotEmpty) return`), sehingga daftar baru tidak masuk. Selain itu seed berjalan di `initState` splash, jadi hot reload tidak menjalankannya, dan `catch (_) {}` menyembunyikan semua error.
- **Bertambah ganda:** setelah pengaman dihapus sebagian, setiap aplikasi dibuka alat ditambahkan lagi.
- **Solusi akhir:** seed mengambil semua kode alat yang sudah ada, lalu hanya menambahkan alat berkode baru. Aman dijalankan berulang. `catch` diganti agar mencetak error ke Debug Console. Data lama yang sudah ganda dibersihkan lewat Firebase Console.
- **Kemungkinan lain:** seed berjalan sebelum login, sehingga rules yang mewajibkan login bisa menolaknya (`permission-denied`).

### 8. URL gambar rusak
Dua URL gambar di Firestore gagal dimuat: satu diawali huruf `a` sebelum `https`, satu berakhir `%0A` (karakter baris baru ikut tersalin). Selain itu, gambar dari situs toko sering diblokir di Chrome (CORS), jadi gambar Kamera Sony A6400 diganti dengan foto dari Wikimedia Commons yang stabil. Semua `Image.network` di daftar Inventaris dan detail alat diberi `errorBuilder` supaya URL rusak tidak membanjiri log, dan form memakai `.trim()` untuk mencegah masalah serupa.

### 9. Validasi login dan register
Validasi awal hanya mengecek `@` dan panjang password lewat snackbar. Diganti dengan `Form` dan `TextFormField` agar pesan error merah muncul di bawah tiap kolom. Aturan tambahan: nama minimal 3 huruf, format email dengan regex, dan password harus berisi huruf serta angka saat register. Fitur konfirmasi password sempat ditambahkan lalu dihapus karena bukan syarat soal.

### 10. Pesan error login
Email yang tidak terdaftar dan password salah sama-sama menghasilkan kode `invalid-credential` dari Firebase. Ini bukan bug: Firebase mengaktifkan **Email Enumeration Protection** secara bawaan agar aplikasi tidak membocorkan email mana yang sudah terdaftar. Pesannya dibuat informatif tanpa membocorkan itu: *"Email atau password salah, atau belum terdaftar"*, dengan varian khusus untuk login admin.

### 11. Penambahan peran Admin dan Siswa
Revisi terbesar. Awalnya semua pengguna bisa menambah, mengedit, dan menghapus alat. Setelah revisi:
- `UserModel` mendapat field `role` dan getter `isAdmin`.
- `AuthService.loginAdmin` memeriksa `role` di Firestore setelah login. Jika bukan admin, sesi langsung di-`signOut` dan muncul pesan khusus.
- Tombol Tambah, Edit, dan Hapus di Inventaris hanya tampil untuk admin. Register tetap hanya untuk siswa, jadi tidak ada cara membuat admin dari aplikasi (dibuat lewat Console).
- Tombol Pinjam dan Kembalikan di detail alat hanya untuk siswa.

### 12. Peminjaman dibuat aman dari tabrakan
Peminjaman awalnya memakai batch write sehingga dua orang yang menekan Pinjam hampir bersamaan bisa sama-sama berhasil. Diganti dengan `runTransaction` yang membaca status terbaru lebih dulu. Data peminjam juga disimpan di dokumen alat (`borrowed_by_*`) supaya admin bisa melihat peminjamnya tanpa membaca sub-koleksi milik pengguna lain.

### 13. Status tidak lagi diubah lewat form edit
Dropdown status di form edit bisa membuat status alat tidak sinkron dengan riwayat peminjaman. `updateItem` sekarang sengaja tidak menulis field `status`, karena status hanya boleh berubah lewat proses pinjam dan kembali. Alat yang sedang dipinjam tetap dikunci di daftar Inventaris admin.

### 14. Konfirmasi sebelum aksi berbahaya
Hapus alat dan logout sekarang memakai dialog konfirmasi. Proses hapus juga dibungkus `try/catch` agar kegagalan tampil sebagai pesan, bukan crash diam-diam.

### 15. Detail kecil lain
- Label "Firestore Live Sync" ternyata hiasan tanpa fungsi (tidak mengecek koneksi), jadi diganti dengan email pengguna.
- Di Firebase Console, pesan *Field ID already in use* muncul ketika nama field yang sudah ada diketik lagi lewat **Add field**. Alat baru harus dibuat lewat **Add document**.
- Data yang dibuat manual di Console harus memiliki `created_at` bertipe **timestamp**, karena query memakai `orderBy('created_at')` dan dokumen tanpa field itu tidak muncul.
- Animasi splash ditambah logo memantul (`Curves.elasticOut`), lalu ukuran splash dan halaman auth diperbesar.
- Lama tampil snackbar diatur dengan `duration` supaya tidak menumpuk.

---

## Batasan yang Diketahui

- **Pembatasan admin hanya di sisi tampilan.** Rules Firestore saat ini mengizinkan pengguna yang login menulis ke `items`, karena siswa perlu mengubah status saat pinjam dan kembali. Akun siswa yang menembak Firestore langsung secara teknis masih bisa mengubah data. Untuk perlindungan penuh, rules perlu membedakan peran admin dan siswa.
- **Form tambah alat masih punya dropdown Status.** Saat mengedit, nilainya diabaikan. Saat menambah, admin bisa membuat alat langsung berstatus `Borrowed` tanpa peminjam, sehingga muncul tulisan "Data peminjam belum tercatat".
- **Alat dummy berstatus `Borrowed` dari awal** (Cisco Catalyst dan Fluke) tidak punya data peminjam dan tidak punya catatan peminjaman. Tidak ada tombol di aplikasi untuk membebaskannya; ubah field `status` langsung di Firebase Console.
- Seed data berjalan sebelum login, jadi pengisian pertama bergantung pada rules yang memperbolehkannya.
- Gambar bergantung pada koneksi internet dan ketersediaan URL pihak ketiga.
- Tampilan dirancang untuk layar HP dan belum disesuaikan untuk layar lebar atau web.

---

## Penutup

Aplikasi ini memenuhi seluruh poin soal: splash dengan pengecekan sesi, login dan register terintegrasi Firebase Auth, beranda dengan search, carousel, dan tiga baris horizontal, menu bawah tiga tab, serta CRUD inventaris yang real-time di Firestore. Sebagai tambahan, aplikasi punya peran admin dan siswa, serta peminjaman yang tercatat di sub-koleksi `borrowings`.
