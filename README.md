# NexusLab – Inventaris Alat Lab (Flutter + Firebase)

Tahap 1–3 (UI) milik Jane + Tahap 4–5 (Firebase Auth, Firestore, CRUD real-time).

## Langkah menjalankan
1. Firebase Console → buat proyek → **Authentication** aktifkan Email/Password → **Firestore Database** → Create.
2. Tab Rules Firestore → tempel isi `firestore.rules` → Publish.
3. Di folder proyek:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure      # menimpa lib/firebase_options.dart + memasang google-services
   flutter pub get
   flutter run
   ```
4. Register akun → menu **Inventaris** → tombol **Isi data dummy** (atau tombol +).

## Struktur Firestore
- users/{uid}: user_id, name, email, kelas, created_at, foto
- items/{itemId}: item_id, item_name, category, code, status, image, spesification, created_at
- users/{uid}/borrowings/{borrowId}: borrow_id, item_id, item_name, borrow_date

## Palet warna (Color Hunt)
navy #0F3040 · slate #464858 · clay #A56F63 · peach #D99B7F (terpusat di `lib/theme/app_colors.dart`, tema light & dark di `lib/main.dart`).

## Jika muncul layar "Firebase belum dikonfigurasi"
Jalankan `flutterfire configure` di folder proyek, lalu `flutter run` ulang.
