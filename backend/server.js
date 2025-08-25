const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static folder untuk file upload
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Konfigurasi multer (simpan ke folder uploads/)
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

let laporanList = [];

// Endpoint buat kirim laporan
app.post('/api/laporan', upload.single('photo'), (req, res) => {
  try {
    const { title, description, category, latitude, longitude } = req.body;

    const laporanData = {
      id: `RPT-${Date.now()}`,
      title,
      description,
      category,
      location: { latitude, longitude },
      status: "Diterima",
      catatan: null,
      imageUrl: req.file ? `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}` : null,
      timestamp: new Date().toISOString()
    };

    laporanList.push(laporanData);

    res.status(200).json({
      status: 'sukses',
      message: 'Laporan berhasil diterima',
      data: laporanData
    });

  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
});

// GET semua laporan
app.get('/api/laporan', (req, res) => {
  res.json(laporanList);
});

// Update status laporan
app.put('/api/laporan/:id', (req, res) => {
  const { id } = req.params;
  const { status, catatan } = req.body;

  const laporan = laporanList.find(l => l.id === id);
  if (!laporan) {
    return res.status(404).json({ status: 'error', message: 'Laporan tidak ditemukan' });
  }

  laporan.status = status || laporan.status;
  laporan.catatan = catatan || laporan.catatan;

  res.json({
    status: 'sukses',
    message: 'Status laporan diperbarui',
    data: laporan
  });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// Jalankan server
app.listen(PORT, () => {
  console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
});
