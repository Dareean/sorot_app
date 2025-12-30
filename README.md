# Sorot - Platform Pelaporan Lingkungan Berbasis Geospasial

[![Flutter](https://img.shields.io/badge/Flutter-3.19.5-blue?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud_Platform-orange?logo=firebase)](https://firebase.google.com/)
[![Node.js](https://img.shields.io/badge/Node.js-20.11.1-green?logo=node.js)](https://nodejs.org/)
[![QGIS](https://img.shields.io/badge/QGIS-3.34-green?logo=qgis)](https://qgis.org/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/dareean-ahmad-raffi-mardin-72247a229/)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-green?style=flat)](-)

**Sorot** adalah sistem terintegrasi yang menghubungkan masyarakat dengan instansi pemerintah untuk pelaporan dan pemantauan masalah lingkungan secara real-time berbasis peta digital.

## Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Arsitektur Sistem](#-arsitektur-sistem)
- [Teknologi](#-teknologi)
- [Prerequisites](#-prerequisites)
- [Instalasi & Setup](#-instalasi--setup)
- [Konfigurasi](#-konfigurasi)
- [Cara Menjalankan](#-cara-menjalankan)
- [Struktur Project](#-struktur-project)
- [API Documentation](#-api-documentation)

## Fitur Utama

### Untuk Masyarakat (Aplikasi Mobile)
- **Autentikasi Aman** - Login/register dengan Firebase Auth
- **Formulir Pelaporan Intuitif** - Lengkap dengan kategori, deskripsi, dan foto
- **Deteksi Lokasi Otomatis** - GPS terintegrasi untuk akurasi koordinat
- **Notifikasi Real-time** - Update status laporan langsung ke smartphone
- **Dashboard Pelapor** - Lacak status laporan (Pending, Diproses, Selesai)

### Untuk Admin (Dashboard Web & QGIS)
- **Dashboard Web Responsif** - Kelola laporan dalam bentuk tabel
- **Integrasi QGIS Real-time** - Monitor laporan di peta digital
- **Sistem Validasi** - Verifikasi dan update status laporan
- **Catatan Admin** - Tambahkan instruksi untuk tim lapangan
- **Analisis Geospasial** - Identifikasi pola dan hotspot masalah

## Teknologi Yang Di Pakai
### Frontend Mobile:
    1. Flutter 3.19.5
    2. Dart 3.3.3
    3. Provider (State Management)
    4. Google Maps Flutter
    5. Image Picker
### Backend & Database:
    1. Node.js 20.11.1
    2. Express.js
    3. Firebase Firestore
    4. Firebase Cloud Storage
    5. Firebase Cloud Messaging

### Admin & GIS:
    1. React.js (Dashboard Web)
    2. QGIS 3.34+
    3. GeoJSON API

## Prerequisites
Sebelum instalasi, pastikan software berikut terinstal:

    1. Flutter SDK (versi 3.19.5 atau lebih baru)
    2. Node.js (versi 20.11.1 atau lebih baru)
    3. Java JDK 11 atau lebih baru
    4. Android Studio (untuk emulator Android)
    5. QGIS (hanya untuk admin GIS)
    6. Akun Firebase

## Instalasi & Setup
### Clone Repository
    1. git clone https://github.com/your-organization/sorot.git
    2. cd sorot
### Setup Firebase Project:
    1. Buka Firebase Console
    2. Buat project baru sorot-app
### Aktifkan layanan berikut:
    - Authentication (Email/Password)
    - Firestore Database
    - Cloud Storage
    - Cloud Messaging
    - Download file konfigurasi google-services.json (Android) dan GoogleService-Info.plist (iOS)
### Setup Aplikasi Flutter
    - bash
    - cd mobile-app

### Install dependencies
    flutter pub get

### Place Firebase config files
    cp path/to/google-services.json android/app/
    cp path/to/GoogleService-Info.plist ios/Runner/
### Setup Backend Server
    bash
    cd backend-server

### Install dependencies
    npm install
    
### Environment setup
    cp .env.example .env
### Setup Admin Dashboard: 
    bash
    cd admin-dashboard

### Install dependencies
    npm install

### Environment setup
    cp .env.example .env
### Konfigurasi:
Environment Variables

### Backend Server (.env):
    env
    FIREBASE_SERVICE_ACCOUNT=path/to/serviceAccountKey.json
    FIREBASE_STORAGE_BUCKET=sorot-app.appspot.com
    PORT=3000
    NODE_ENV=development
    Admin Dashboard (.env):

    env
    REACT_APP_API_URL=http://localhost:3000
    REACT_APP_FIREBASE_CONFIG={"apiKey": "...", ...}
    Konfigurasi QGIS
    Buka QGIS

Tambahkan layer baru: Layer > Add Layer > Add GeoJSON Layer

Masukkan URL endpoint: http://localhost:3000/api/reports/geojson

Set refresh interval: Layer Properties > Temporal > Enable Temporal

## Cara Menjalankan
Development Mode
### Jalankan Backend Server:
    cd backend-server
    npm run dev
### Jalankan Aplikasi Flutter:
    cd mobile-app
    flutter run
### Jalankan Admin Dashboard:
    cd admin-dashboard
    npm start
    Production Build
### Build Aplikasi Flutter:
    cd mobile-app
    flutter build apk --release
    flutter build ios --release

### Build Backend untuk Production:
    cd backend-server
    npm run build
    npm start
