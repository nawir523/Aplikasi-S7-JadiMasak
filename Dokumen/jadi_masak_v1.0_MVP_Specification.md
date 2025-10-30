# Spesifikasi Perangkat Lunak: 'jadi masak' v1.0 (MVP)

 **Nama Produk** | JADI MASAK (v1.0) |
 **Versi** | 1.0 (MVP - Minimum Viable Product) |
 **Pemilik Proyek** | Munawir Ihsan-221240001234 / Umi Nurul Latifah - 221240001226 |

## 1. PRD (Product Requirements Document)


**1. Pendahuluan**  
"jadi masak" adalah aplikasi resep masakan *mobile* yang dirancang untuk mengatasi masalah umum: "mau masak apa dengan bahan yang ada di rumah?".

**2. Masalah (The Problem)**  
Banyak orang (pelajar, profesional muda, ibu rumah tangga) seringkali bingung harus memasak apa. Mereka memiliki bahan-bahan sisa di kulkas namun tidak tahu cara mengolahnya, yang seringkali berujung pada bahan makanan terbuang (mubazir) dan pembelian makanan yang tidak perlu.

**3. Solusi (The Solution)**  
Aplikasi v1.0 akan fokus pada satu fitur inti: **"Kulkasku" (Virtual Pantry)**. Pengguna dapat memasukkan bahan-bahan yang mereka miliki secara manual, dan aplikasi akan merekomendasikan resep yang bisa dibuat *hanya* dengan bahan-bahan tersebut (atau dengan tambahan 1-2 bahan saja).

**4. Target Pengguna (User Persona)**  
* **Mahasiswa/Pelajar Kost:** Budget terbatas, ingin memasak sendiri, sering punya bahan sisa seadanya.  
* **Profesional Muda:** Sibuk, tidak punya waktu merencanakan masakan, ingin cepat menghabiskan bahan sebelum busuk.  
* **Ibu Rumah Tangga:** Ingin variasi menu harian dan mengelola stok bahan di kulkas secara efisien.

**5. Fitur Utama (v1.0)**  
* **F-01: Autentikasi Pengguna:** Pengguna dapat mendaftar, login, dan logout (via Email/Google).  
* **F-02: Penjelajahan Resep Standar:** Pengguna dapat mencari resep berdasarkan nama atau kategori.  
* **F-03: Manajemen "Kulkasku":** Pengguna dapat menambah dan menghapus bahan yang mereka miliki (input manual).  
* **F-04: Pencarian "Anti-Mubazir":** Tombol aksi untuk mencari resep berdasarkan bahan di "Kulkasku".  
* **F-05: Hasil Pencarian Terprioritas:** Menampilkan hasil dalam 2 kategori: "Paling Cocok" (bahan 100% ada) dan "Kurang 1-2 Bahan".  
* **F-06: Highlight Bahan:** Di halaman detail resep, bahan yang dimiliki pengguna ditandai (✓), yang tidak dimiliki ditandai (🛒).

**6. Kriteria Sukses (Success Metrics MVP)**  
* **Aktivasi:** % pengguna yang menambahkan minimal 5 bahan ke "Kulkasku" di minggu pertama.  
* **Engangement:** Jumlah klik pada tombol "Cari Resep dari Bahan Ini!" per pengguna aktif.  
* **Retensi:** % pengguna yang kembali menggunakan fitur "Kulkasku" setelah 7 hari.

---

## 2. ERD (Entity-Relationship Diagram) / Model Data

Berikut adalah **Model Data** konseptual untuk Firestore (NoSQL):

1. **Koleksi `users`**
    * Dokumen: `[user_id]` (dari Firebase Auth)
    * Fields: `email`, `displayName`
    * **Sub-Koleksi `pantry_items`**
        * Dokumen: `[ingredient_id]` (ID dari `ingredients_master`)
        * Fields: `added_at` (timestamp)

2. **Koleksi `ingredients_master`**
    * Dokumen: `[ingredient_id_unik]`
    * Fields: `name` (e.g. "bawang putih"), `search_keywords` (e.g. ["bawang", "putih"])

3. **Koleksi `recipes`**
    * Dokumen: `[recipe_id_unik]`
    * Fields: `title`, `instructions` (teks panjang), `image_url` (link ke Cloud Storage)
    * Field **`ingredients_list` (Tipe: Array of Maps):**
        * `[ { "id": "ref_ke_ing_master_1", "name": "Bawang Putih", "qty": "2 siung" }, { "id": "ref_ke_ing_master_2", "name": "Ayam", "qty": "100 gr" } ]`

---

## 3. SRS (Software Requirements Specification)

**Spesifikasi Kebutuhan Perangkat Lunak: 'jadi masak' v1.0**

### 1. Kebutuhan Fungsional (Functional Requirements)

* **RF-AUTH (Autentikasi)**
    * RF-AUTH-01: Sistem harus menyediakan pendaftaran pengguna baru menggunakan Email dan Password.
    * RF-AUTH-02: Sistem harus menyediakan login pengguna menggunakan Email dan Password.
    * RF-AUTH-03: (Opsional MVP) Sistem harus menyediakan login pengguna menggunakan akun Google.
    * RF-AUTH-04: Sistem harus menyediakan fungsionalitas Logout.

* **RF-RECIPE (Manajemen Resep - Sisi Pengguna)**
    * RF-RECIPE-01: Pengguna dapat melihat daftar resep populer/rekomendasi di Halaman Utama.
    * RF-RECIPE-02: Pengguna dapat mencari resep berdasarkan nama resep.
    * RF-RECIPE-03: Pengguna dapat melihat halaman detail resep (gambar, bahan, langkah-langkah).

* **RF-PANTRY (Fitur "Kulkasku")**
    * RF-PANTRY-01: Pengguna dapat mengakses halaman "Kulkasku".
    * RF-PANTRY-02: Pengguna dapat menambahkan bahan ke "Kulkasku" melalui input teks manual dengan *autocomplete*.
    * RF-PANTRY-03: Pengguna dapat melihat daftar bahan yang ada di "Kulkasku".
    * RF-PANTRY-04: Pengguna dapat menghapus bahan dari "Kulkasku".

* **RF-SEARCH (Fitur Pencarian "Anti-Mubazir")**
    * RF-SEARCH-01: Sistem harus menyediakan tombol aksi ("Cari Resep") di halaman "Kulkasku".
    * RF-SEARCH-02: Saat tombol ditekan, sistem harus memproses pencarian resep berdasarkan bahan yang ada di `pantry_items` pengguna.
    * RF-SEARCH-03: Sistem harus menampilkan halaman hasil pencarian khusus.
    * RF-SEARCH-04: Halaman hasil harus memiliki 2 tab: "Paling Cocok" (resep yang 100% bahannya ada) dan "Kurang 1-2 Bahan".
    * RF-SEARCH-05: Di halaman Detail Resep, sistem harus memberikan tanda visual (centang ✓) pada bahan yang dimiliki pengguna di "Kulkasku".

### 2. Kebutuhan Non-Fungsional (Non-Functional Requirements)

* **RNF-PERF-01:** Waktu respons untuk pencarian "Anti-Mubazir" (RF-SEARCH-02) tidak boleh lebih dari 5 detik.
* **RNF-PLAT-01:** Aplikasi harus dapat berjalan di platform Android (minimal versi 8.0) dan iOS (minimal versi 13.0).
* **RNF-SEC-01:** Data pengguna dan "Kulkasku" harus disimpan dengan aman dan tidak dapat diakses oleh pengguna lain (diterapkan melalui Firestore Security Rules).
* **RNF-USAB-01:** Antarmuka aplikasi harus *responsive* dan dapat digunakan dengan nyaman di berbagai ukuran layar ponsel standar.
* **RNF-LANG-01:** Aplikasi menggunakan Bahasa Indonesia.

---

## 4. SDD (Software Design Document)

**Dokumen Desain Perangkat Lunak: 'jadi masak' v1.0**

### 1. Arsitektur Sistem (High-Level)
Aplikasi ini menggunakan arsitektur **Client-Server** dengan model **BaaS (Backend-as-a-Service)**.
* **Client (Frontend):** Aplikasi *mobile cross-platform* yang dibuat dengan **Flutter**.
* **Backend (Server):** **Firebase** (Google).

### 2. Desain Frontend (Flutter)
* **Framework:** Flutter (SDK v3.x.x)
* **Bahasa:** Dart
* **Manajemen State (State Management):** Riverpod (disarankan) atau Provider.
* **Integrasi Backend (FlutterFire):**
    * `firebase_core`
    * `firebase_auth` (untuk RF-AUTH)
    * `cloud_firestore` (untuk RF-PANTRY, RF-RECIPE)
    * `cloud_functions` (untuk RF-SEARCH)
    * `firebase_storage` (untuk mengambil gambar resep)

### 3. Desain Backend (Firebase)
* **`Firebase Authentication`:** Menangani semua kebutuhan RF-AUTH. Menggunakan *provider* Email/Password dan Google Sign-In.
* **`Cloud Firestore`:** Database NoSQL untuk semua data. (Lihat Model Data di atas).
* **`Cloud Functions`:** "Otak" dari pencarian anti-mubazir (RF-SEARCH).
    * **Fungsi:** `findMatchingRecipes`
    * **Trigger:** `onCall` (Dipanggil langsung dari aplikasi Flutter).
    * **Logika:** Memfilter resep berdasarkan `pantry_items` pengguna.
* **`Cloud Storage`:** Menyimpan aset statis (gambar-gambar resep).

---

## 5. Checklist Timeline Sprint MVP (Estimasi 6 Minggu)

*Asumsi: Tim terdiri dari 1-2 developer, menggunakan 2-minggu per Sprint.*

### Sprint 0: Persiapan (Durasi: 1 Minggu - *Pekerjaan Paralel*)
* [ ] Finalisasi Desain UI/UX (Figma) untuk halaman-halaman utama.
* [ ] Setup *repository* Git (GitHub/GitLab).
* [ ] Setup proyek Firebase (Auth, Firestore, Functions, Storage).
* [ ] Setup proyek Flutter dan *library* dasar (FlutterFire, Riverpod, Navigasi).
* [ ] **Migrasi Data Awal:** Mengisi `recipes` (minimal 100 resep) dan `ingredients_master` ke Firestore.

### Sprint 1: Fondasi & Autentikasi (Durasi: 2 Minggu)
* [ ] Implementasi struktur navigasi aplikasi (Tab Bar Bawah).
* [ ] Implementasi Halaman Login (UI + Logic) - RF-AUTH-02.
* [ ] Implementasi Halaman Daftar (UI + Logic) - RF-AUTH-01.
* [ ] Implementasi Halaman Profil (UI + Logic Logout) - RF-AUTH-04.
* [ ] Implementasi Halaman Utama (Home) (UI + Logic baca resep) - RF-RECIPE-01.
* [ ] Implementasi Halaman Pencarian Standar (UI + Logic) - RF-RECIPE-02.

### Sprint 2: Fitur Inti "Kulkasku" (Durasi: 2 Minggu)
* [ ] Implementasi Halaman "Kulkasku" (UI) - RF-PANTRY-01.
* [ ] Implementasi fungsi Tambah Bahan (Logic + *Autocomplete*) - RF-PANTRY-02.
* [ ] Implementasi fungsi Lihat/Hapus Bahan (Logic) - RF-PANTRY-03, 04.
* [ ] Implementasi Halaman Detail Resep (UI) - RF-RECIPE-03.
* [ ] Implementasi *Highlight* Bahan (✓/🛒) di Detail Resep (UI + Logic) - RF-SEARCH-05.
* [ ] **Backend:** *Development* Cloud Function `findMatchingRecipes` (Logika V1).

### Sprint 3: Integrasi & Pengujian (Durasi: 2 Minggu)
* [ ] Implementasi tombol "Cari Resep" (menghubungkan Flutter ke Cloud Function) - RF-SEARCH-01, 02.
* [ ] Implementasi Halaman Hasil Pencarian Khusus (UI + Menampilkan 2 Tab) - RF-SEARCH-03, 04.
* [ ] Pengujian menyeluruh (End-to-End Testing) untuk semua alur.
* [ ] *Bug Fixing* dari hasil pengujian.
* [ ] *Code Freeze* & Persiapan Rilis.
* [ ] Build APK (Android) dan Archive (iOS) untuk rilis internal/TestFlight.
