# Dokumen Spesifikasi Perangkat Lunak – JadiMasak

## 1. PRD (Product Requirement Document)
**Judul Produk:** JadiMasak – Aplikasi Resep Masakan Sederhana

**Tujuan Produk:**
- Membantu user (mahasiswa, anak kos, ibu rumah tangga muda) menemukan resep masakan sederhana, cepat, dan praktis.
- Menyediakan fitur favorit & pencarian resep agar pengalaman memasak lebih mudah.

**Fitur Utama MVP:**
1. List Resep (data dari Firestore).
2. Detail Resep (bahan, langkah, gambar).
3. Search & Filter.
4. Favorit (local storage).
5. Tampilan UI sederhana & mudah digunakan.

**User Persona:**
- Mahasiswa/Anak Kos: butuh masak murah & cepat.
- Ibu Rumah Tangga Baru: butuh inspirasi resep praktis.

**Monetisasi:**
- Awal: iklan (AdMob).
- Lanjutan: premium (tanpa iklan + simpan offline).

---

## 2. ERD (Entity Relationship Diagram)
Untuk versi simple, entitas utama hanya **Recipes**. Nanti kalau user bisa upload resep, kita tambahkan **Users** dan **Comments**.

**Entities:**
- **Recipe**
  - recipe_id (PK)
  - title
  - category
  - ingredients (array)
  - steps (array)
  - imageURL

---

## 3. SRS (Software Requirement Specification)

### a. Functional Requirements
1. User dapat melihat daftar resep.
2. User dapat melihat detail resep (bahan + langkah + foto).
3. User dapat mencari resep berdasarkan nama/kategori.
4. User dapat menandai resep favorit.

### b. Non-Functional Requirements
1. **Usability**: aplikasi mudah digunakan dengan UI sederhana.
2. **Performance**: load resep < 2 detik pada jaringan normal.
3. **Compatibility**: berjalan di Android min SDK 21+.
4. **Reliability**: data resep tersimpan di Firebase Firestore.

---

## 4. SDD (Software Design Document)

### a. Arsitektur Sistem
- **Frontend**: Flutter/React Native (pilih salah satu).
- **Backend**: Firebase (Firestore, Storage, Auth).
- **Local Storage**: SharedPreferences / SQLite (untuk favorit).

### b. Flow Aplikasi (MVP)
1. Splash Screen → Home (list resep).
2. Klik item → Detail Resep.
3. Search → tampilkan hasil.
4. Tandai favorit → simpan lokal → tampilkan di halaman Favorit.

### c. Komponen Utama
- **RecipeListScreen** → menampilkan daftar resep.
- **RecipeDetailScreen** → menampilkan detail resep.
- **SearchBar** → filter/search resep.
- **FavoritesScreen** → menampilkan resep favorit.

---

## 5. Checklist Timeline Sprint MVP (4 Minggu)

### Sprint 1 (Minggu 1)
- Setup project (Flutter/React Native).
- Integrasi Firebase.
- Buat struktur data Firestore + upload data dummy resep.

### Sprint 2 (Minggu 2)
- Implementasi tampilan Home (list resep).
- Implementasi halaman Detail Resep.

### Sprint 3 (Minggu 3)
- Tambah fitur Search & Filter.
- Tambah fitur Favorit (local storage).

### Sprint 4 (Minggu 4)
- Finalisasi UI/UX.
- Tambah iklan (AdMob).
- Testing + Bug fixing.
