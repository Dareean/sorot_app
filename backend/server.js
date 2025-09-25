// server.js — Kode Final dan Terverifikasi
const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const os = require('os');
const admin = require('firebase-admin');

// Pastikan nama file ini sama persis dengan file kunci Anda
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const app = express();
app.use(cors());
app.use(express.json());

const UPLOAD_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, UPLOAD_DIR),
  filename: (_, file, cb) => {
    const ext = (path.extname(file.originalname || '') || '.jpg').toLowerCase();
    const name = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, name);
  }
});

const ALLOWED = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'image/gif', 'application/octet-stream']);

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (_, file, cb) => {
    const ok = ALLOWED.has((file.mimetype || '').toLowerCase());
    if (!ok) return cb(new Error('Only image files are allowed'), false);
    cb(null, true);
  }
}).single('file');

app.use('/uploads', express.static(UPLOAD_DIR));

app.post('/upload', (req, res) => {
  upload(req, res, (err) => {
    if (err) {
      console.error('Upload error:', err.message);
      return res.status(400).json({ error: err.message || 'Upload failed' });
    }
    if (!req.file) return res.status(400).json({ error: 'No file' });

    console.log('Uploaded:', {
      original: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size
    });
    
    const localIp = getLocalIp();
    const port = process.env.PORT || 5001;
    const url = `http://${localIp}:${port}/uploads/${req.file.filename}`;
    res.json({ url });
  });
});

app.get("/reports.geojson", async (req, res) => {
  try {
    const snapshot = await db.collection("reports").get();
    
    const features = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      
      if (typeof data.lat === 'number' && typeof data.lng === 'number') {
        features.push({
          type: "Feature",
          geometry: {
            type: "Point",
            coordinates: [data.lng, data.lat],
          },
          properties: {
            id: doc.id,
            title: data.title || "Tanpa Judul",
            desc: data.desc || "-",
            photoUrl: data.photoUrl || null,
            status: data.status || "pending",
            category: data.category || "-",
          },
        });
      }
    });

    res.json({
      type: "FeatureCollection",
      features: features,
    });
  } catch (error) {
    console.error("Gagal mengambil data untuk GeoJSON:", error);
    res.status(500).json({ error: "Tidak dapat memproses permintaan." });
  }
});

const PORT = process.env.PORT || 5001;

function getLocalIp() {
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return 'localhost';
}

app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server berjalan di http://${getLocalIp()}:${PORT}`);
});