# 🎯 Sorot - Platform Pelaporan Lingkungan Berbasis Geospasial

[![Flutter](https://img.shields.io/badge/Flutter-3.19.5-blue?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud_Platform-orange?logo=firebase)](https://firebase.google.com/)
[![Node.js](https://img.shields.io/badge/Node.js-20.11.1-green?logo=node.js)](https://nodejs.org/)
[![QGIS](https://img.shields.io/badge/QGIS-3.34-green?logo=qgis)](https://qgis.org/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/dareean-ahmad-raffi-mardin-72247a229/)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-green?style=flat)](-)

**Sorot** adalah sistem terintegrasi yang menghubungkan masyarakat dengan instansi pemerintah untuk pelaporan dan pemantauan masalah lingkungan secara real-time berbasis peta digital.

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Arsitektur Sistem](#-arsitektur-sistem)
- [Teknologi](#-teknologi)
- [Prerequisites](#-prerequisites)
- [Instalasi & Setup](#-instalasi--setup)
- [Konfigurasi](#-konfigurasi)
- [Cara Menjalankan](#-cara-menjalankan)
- [Struktur Project](#-struktur-project)
- [API Documentation](#-api-documentation)

## 🚀 Fitur Utama

### 📱 Untuk Masyarakat (Aplikasi Mobile)
- ✅ **Autentikasi Aman** - Login/register dengan Firebase Auth
- 📝 **Formulir Pelaporan Intuitif** - Lengkap dengan kategori, deskripsi, dan foto
- 📍 **Deteksi Lokasi Otomatis** - GPS terintegrasi untuk akurasi koordinat
- 🔔 **Notifikasi Real-time** - Update status laporan langsung ke smartphone
- 📊 **Dashboard Pelapor** - Lacak status laporan (Pending, Diproses, Selesai)

### 🖥️ Untuk Admin (Dashboard Web & QGIS)
- 🌐 **Dashboard Web Responsif** - Kelola laporan dalam bentuk tabel
- 🗺️ **Integrasi QGIS Real-time** - Monitor laporan di peta digital
- ✅ **Sistem Validasi** - Verifikasi dan update status laporan
- 💬 **Catatan Admin** - Tambahkan instruksi untuk tim lapangan
- 📈 **Analisis Geospasial** - Identifikasi pola dan hotspot masalah

## 🏗️ Arsitektur Sistem

mermaid
graph TB
    A [Aplikasi Flutter] --> B [Firebase Firestore]
    C [Dashboard Web Admin] --> B
    D [Server Node.js] --> B
    D --> E [Cloud Storage]
    F [QGIS Client] --> D
    B --> G [Firebase Cloud Messaging]
    G --> A
    
    style A fill:#02569B,color:#fff
    style C fill:#FFA000,color:#fff
    style D fill:#339933,color:#fff
    style F fill:#589632,color:#fff
## 💻 Teknologi
Frontend Mobile:

Flutter 3.19.5

Dart 3.3.3

Provider (State Management)

Google Maps Flutter

Image Picker

Backend & Database:

Node.js 20.11.1

Express.js

Firebase Firestore

Firebase Cloud Storage

Firebase Cloud Messaging

Admin & GIS:

React.js (Dashboard Web)

QGIS 3.34+

GeoJSON API

##📋 Prerequisites
Sebelum instalasi, pastikan software berikut terinstal:

Flutter SDK (versi 3.19.5 atau lebih baru)

Node.js (versi 20.11.1 atau lebih baru)

Java JDK 11 atau lebih baru

Android Studio (untuk emulator Android)

QGIS (hanya untuk admin GIS)

Akun Firebase

## ⚙️ Instalasi & Setup
1. Clone Repository
git clone https://github.com/your-organization/sorot.git
cd sorot
2. Setup Firebase Project:
Buka Firebase Console

Buat project baru sorot-app

Aktifkan layanan berikut:

Authentication (Email/Password)

Firestore Database

Cloud Storage

Cloud Messaging

Download file konfigurasi google-services.json (Android) dan GoogleService-Info.plist (iOS)

3. Setup Aplikasi Flutter
bash
cd mobile-app

# Install dependencies
flutter pub get

# Place Firebase config files
cp path/to/google-services.json android/app/
cp path/to/GoogleService-Info.plist ios/Runner/
4. Setup Backend Server
bash
cd backend-server

# Install dependencies
npm install

# Environment setup
cp .env.example .env
5. Setup Admin Dashboard
bash
cd admin-dashboard

# Install dependencies
npm install

# Environment setup
cp .env.example .env
🔧 Konfigurasi
Environment Variables
Backend Server (.env):

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

## 🎯 Cara Menjalankan
Development Mode
1. Jalankan Backend Server:
cd backend-server
npm run dev

2. Jalankan Aplikasi Flutter:
cd mobile-app
flutter run

3. Jalankan Admin Dashboard:
cd admin-dashboard
npm start
Production Build

4. Build Aplikasi Flutter:
cd mobile-app
flutter build apk --release
flutter build ios --release

5. Build Backend untuk Production:
cd backend-server
npm run build
npm start

## 📁 Struktur Project
text
sorot/
├── 📱 mobile-app/                 # Aplikasi Flutter
│   ├── lib/
│   │   ├── models/               # Data models
│   │   ├── providers/            # State management
│   │   ├── screens/              # UI screens
│   │   ├── services/             # API services
│   │   └── widgets/              # Reusable widgets
│   ├── android/ & ios/           # Platform-specific code
│   └── pubspec.yaml             # Dependencies
├── 🖥️ backend-server/             # Node.js API Server
│   ├── src/
│   │   ├── controllers/          # Route controllers
│   │   ├── models/               # Database models
│   │   ├── routes/               # API routes
│   │   └── middleware/           # Custom middleware
│   ├── uploads/                  # File upload directory
│   └── package.json
├── 🌐 admin-dashboard/            # React Admin Dashboard
│   ├── src/
│   │   ├── components/           # React components
│   │   ├── pages/                # Page components
│   │   └── services/             # API calls
│   └── package.json
└── 📚 documentation/             # Dokumentasi tambahan

## 📡 API Documentation
Endpoints Utama
Method	Endpoint	Deskripsi
GET	/api/reports	Ambil semua laporan
GET	/api/reports/geojson	Data laporan format GeoJSON
POST	/api/reports	Buat laporan baru
PUT	/api/reports/:id	Update status laporan
POST	/api/upload	Upload gambar

Contoh Request GeoJSON:
curl -X GET "http://localhost:3000/api/reports/geojson"

Response:
json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [106.8272, -6.1754]
      },
      "properties": {
        "id": "report_001",
        "title": "Sampah Menumpuk",
        "status": "pending",
        "photoUrl": "https://..."
      }
    }
  ]
}

