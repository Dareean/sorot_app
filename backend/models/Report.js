import mongoose from 'mongoose';

const ReportSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  category: { type: String, enum: ['Sampah','Air','Udara','Fasilitas'], required: true },
  photos: [String], // path relatif, mis. "/uploads/abc.jpg"
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], required: true } // [lng, lat]
  },
  status: { type: String, enum: ['Menunggu','Diterima','Diproses','Selesai','Ditolak'], default: 'Menunggu' },
  history: [{ status: String, note: String, at: Date, by: String }]
}, { timestamps: true });

ReportSchema.index({ location: '2dsphere' });

export default mongoose.model('Report', ReportSchema);
