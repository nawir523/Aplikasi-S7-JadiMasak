---
title: "Spesifikasi Perangkat Lunak - Jadi Masak v1.0 (MVP)"
version: "1.0"
authors: ["Munawir Ihsan", "Umi Nurul Latifah"]
---

# 📘 Spesifikasi Perangkat Lunak

## Table of Contents
1. [Pendahuluan](#1-pendahuluan)
2. [Product Requirements Document (PRD)](#2-product-requirements-document-prd)
3. [Model Data (ERD Firestore)](#3-model-data-erd-firestore)
4. [Software Requirements Specification (SRS)](#4-software-requirements-specification-srs)
5. [Software Design Document (SDD)](#5-software-design-document-sdd)
6. [Pengisian Data Awal (Sprint 0)](#6-pengisian-data-awal-sprint-0)
7. [Timeline Sprint](#7-timeline-sprint)
8. [Integrasi Layanan Eksternal](#8-integrasi-layanan-eksternal)
9. [Keamanan](#9-keamanan)
10. [Rencana Pengembangan Selanjutnya (v15)](#10-rencana-pengembangan-selanjutnya-v15)

---

## 1. Pendahuluan
**Jadi Masak** adalah aplikasi resep masakan berbasis *mobile* yang membantu pengguna menentukan resep berdasarkan bahan yang tersedia di rumah. Fitur utama aplikasi adalah **“Kulkasku” (Virtual Pantry)**, yang memungkinkan pengguna menambahkan bahan yang dimiliki dan menemukan resep yang bisa dimasak tanpa harus membeli bahan baru.

---

## 2. Product Requirements Document (PRD)

### 2.1 Masalah
Banyak orang sering kebingungan harus memasak apa dengan bahan yang tersisa di kulkas. Hal ini menyebabkan bahan makanan terbuang dan pembelian makanan yang tidak perlu.

### 2.2 Solusi
Fitur **Kulkasku** memungkinkan pengguna mencatat bahan yang mereka punya dan menemukan resep berdasarkan bahan-bahan tersebut, dengan dua kategori hasil:
- **Paling Cocok:** Semua bahan tersedia.
- **Kurang 1–2 bahan:** Masih bisa dimasak dengan sedikit tambahan.

### 2.3 Target Pengguna
- Mahasiswa/pelajar kost
- Profesional muda
- Ibu rumah tangga

### 2.4 Fitur Utama (v1.0)
| Kode | Fitur | Deskripsi |
|------|--------|------------|
| F-01 | Autentikasi | Daftar, login, logout via Email/Google. |
| F-02 | Penjelajahan Resep | Cari resep berdasarkan nama/kategori. |
| F-03 | Kulkasku | Tambah dan hapus bahan secara manual. |
| F-04 | Pencarian “Anti-Mubazir” | Cari resep berdasarkan bahan di Kulkasku. |
| F-05 | Hasil Terprioritas | Tampilkan “Paling Cocok” dan “Kurang 1–2 Bahan”. |
| F-06 | Highlight Bahan | Tandai bahan yang dimiliki pengguna di detail resep. |

### 2.5 Model Monetisasi
- **Gratis (v1.0):** Semua fitur dasar + banner iklan.
- **Pro (v1.5+):** Langganan berbayar dengan fitur “Koki AI” & bebas iklan.

---

## 3. Model Data (ERD Firestore)

### Koleksi & Struktur
1. **users**
   - `email`, `displayName`, `subscription_status`
   - Subkoleksi `pantry_items`: daftar bahan pengguna

2. **ingredients_master**
   - `name`, `search_keywords`

3. **recipes**
   - `title`
   - `instructions`
   - `ingredients_list` (array of maps)
   - `image_url` (Cloudinary link)
   - `ingredients_text` (gabungan kata kunci bahan, untuk pencarian)

### Contoh Data `recipes`
```json
{
  "title": "Telur Dadar Sederhana",
  "instructions": "Kocok telur, tambahkan garam, goreng hingga matang.",
  "ingredients_list": [
    {"id": "telur", "name": "Telur", "qty": "2 butir"},
    {"id": "garam", "name": "Garam", "qty": "secukupnya"}
  ],
  "image_url": "https://res.cloudinary.com/jadimasak/image/upload/v1/telur_dadar.jpg",
  "ingredients_text": "telur garam minyak"
}
```

---

## 4. Software Requirements Specification (SRS)

### 4.1 Kebutuhan Fungsional
**Autentikasi**
- RF-AUTH-01: Daftar via Email/Password  
- RF-AUTH-02: Login via Email/Password  
- RF-AUTH-03: Login via Google (opsional)  
- RF-AUTH-04: Logout  

**Manajemen Resep**
- RF-RECIPE-01: Lihat daftar resep populer  
- RF-RECIPE-02: Cari resep berdasarkan nama  
- RF-RECIPE-03: Lihat detail resep  

**Fitur Kulkasku**
- RF-PANTRY-01: Akses halaman “Kulkasku”  
- RF-PANTRY-02: Tambah bahan dengan input teks/autocomplete  
- RF-PANTRY-03: Hapus bahan dari daftar  

**Pencarian Anti-Mubazir**
- RF-SEARCH-01: Tombol “Cari Resep dari Bahan Ini!”  
- RF-SEARCH-02: Kirim data bahan ke Cloud Function `findMatchingRecipes`  
- RF-SEARCH-03: Kategorikan hasil menjadi “Paling Cocok” dan “Kurang 1–2 Bahan”  
- RF-SEARCH-04: Tampilkan hasil di dua tab  
- RF-SEARCH-05: Tandai bahan yang dimiliki di halaman detail resep  

**Monetisasi**
- RF-MONETIZE-01: Tampilkan iklan banner (AdMob)  
- RF-MONETIZE-02: (v1.5) Halaman Upgrade Pro  
- RF-MONETIZE-03: (v1.5) Proses langganan berbayar  
- RF-MONETIZE-04: Validasi status Pro  
- RF-MONETIZE-05: Sembunyikan iklan jika Pro  

### 4.2 Kebutuhan Non-Fungsional
- RNF-PERF-01: Pencarian maksimal 5 detik  
- RNF-SEC-01: Data aman via Firestore Rules  
- RNF-USAB-01: Antarmuka *responsive*  
- RNF-LANG-01: Bahasa Indonesia  
- RNF-PLAT-01: Android 8.0+ dan iOS 13.0+  

---

## 5. Software Design Document (SDD)

### 5.1 Arsitektur Sistem
**Client–Server dengan BaaS (Firebase)**

- **Frontend (Flutter)**  
  - SDK v3.x  
  - State management: Riverpod  
  - Navigasi: GoRouter  
  - Integrasi: `firebase_auth`, `cloud_firestore`, `cloud_functions`, `google_mobile_ads`, `in_app_purchase`, `cloudinary_public`

- **Backend (Firebase + Cloudinary)**  
  - Firebase Auth → login/daftar  
  - Firestore → simpan data resep, kulkasku, user  
  - Cloud Functions → logika pencarian resep  
  - Cloudinary → penyimpanan dan CDN gambar resep  

### 5.2 Fungsi Backend Utama
**Function: `findMatchingRecipes()`**
- Input: `pantryItems` (array bahan pengguna)
- Proses:
  1. Ambil semua resep dari Firestore
  2. Bandingkan bahan resep dengan `pantryItems`
  3. Klasifikasikan hasil: 100% cocok → “Paling Cocok”, kurang ≤2 bahan → “Kurang 1–2 Bahan”
  4. Kembalikan hasil ke Flutter
- Output:
```json
{
  "perfectMatches": [...],
  "almostMatches": [...]
}
```

### 5.3 Struktur Folder Flutter (Feature-first + Layered)
```
lib/
 ├── core/
 │   ├── widgets/
 │   ├── utils/
 │   └── services/
 │       ├── firebase_service.dart
 │       └── cloudinary_service.dart
 ├── features/
 │   ├── auth/
 │   │   ├── ui/
 │   │   ├── logic/
 │   │   └── data/
 │   ├── pantry/
 │   ├── recipes/
 │   └── search/
 └── main.dart
```

---

## 6. Pengisian Data Awal (Sprint 0)
- File: `recipes_seed.json`  
- Diisi ±100 resep dengan `title`, `instructions`, `ingredients_list`, `image_url`  
- Upload ke Firestore via script (Node.js atau Firebase CLI)  

---

## 7. Timeline Sprint (6 Minggu)
| Sprint | Durasi | Fokus |
|--------|---------|--------|
| 0 | 1 Minggu | Setup proyek, Firebase, Cloudinary, seed data |
| 1 | 2 Minggu | Autentikasi & Home |
| 2 | 2 Minggu | Fitur Kulkasku & Detail Resep |
| 3 | 1 Minggu | Pencarian “Anti-Mubazir” + Pengujian + Build |

---

## 8. Integrasi Layanan Eksternal
| Layanan | Tujuan |
|----------|---------|
| Firebase Auth | Autentikasi pengguna |
| Cloud Firestore | Penyimpanan data utama |
| Firebase Functions | Logika pencarian resep |
| Cloudinary | Upload dan CDN gambar |
| AdMob | Iklan banner |
| Google In-App Purchase | Langganan Pro (v1.5) |

---

## 9. Keamanan
- Akses Firestore dibatasi per pengguna (rules per user ID).  
- Upload Cloudinary via preset terbatas (hanya dari aplikasi resmi).  
- Tidak ada data sensitif disimpan lokal tanpa enkripsi.  

---

## 10. Rencana Pengembangan Selanjutnya (v1.5)
- Fitur “Koki AI” (generative recipe)  
- Bebas iklan untuk pengguna Pro  
- Upload resep oleh pengguna  
- Meal Planner dan Smart Shopping List  

---
