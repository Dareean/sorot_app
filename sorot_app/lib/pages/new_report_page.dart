// lib/pages/new_report_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api.dart';
import 'map_picker_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class NewReportPage extends StatefulWidget {
  @override
  State<NewReportPage> createState() => _NewReportPageState();
}

class _NewReportPageState extends State<NewReportPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String category = 'Sampah';
  LatLng? pickedLocation;
  XFile? pickedImage;
  bool uploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1200);
    if (x != null) setState(() => pickedImage = x);
  }

  Future<void> takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 1200);
    if (x != null) setState(() => pickedImage = x);
  }

  Future<void> openMapPicker() async {
    final reports = context.read<ReportProvider>().reports;
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapPickerPage(reports: reports)));
    if (res is LatLng) {
      setState(() => pickedLocation = res);
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih lokasi di peta terlebih dahulu')));
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() => uploading = true);
      final created = await ApiService.createReport(
        title: title,
        description: description,
        category: category,
        lat: pickedLocation!.latitude,
        lng: pickedLocation!.longitude,
        imagePath: pickedImage?.path,
      );
      setState(() => uploading = false);
      // success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Laporan berhasil dibuat')));
      Navigator.pop(context, created);
    } catch (e) {
      setState(() => uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Laporan'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Judul', filled: true),
                onSaved: (v) => title = v ?? '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan judul' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi', filled: true),
                maxLines: 4,
                onSaved: (v) => description = v ?? '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan deskripsi' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Sampah','Banjir','Tanaman','Polusi','Lainnya']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v ?? category),
                decoration: InputDecoration(labelText: 'Kategori', filled: true),
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(pickedLocation == null ? 'Pilih lokasi' : 'Lokasi: ${pickedLocation!.latitude.toStringAsFixed(5)}, ${pickedLocation!.longitude.toStringAsFixed(5)}'),
                leading: Icon(Icons.place),
                trailing: ElevatedButton(onPressed: openMapPicker, child: Text('Pilih di Peta')),
              ),
              SizedBox(height: 12),
              if (pickedImage != null)
                Column(children: [
                  Image.file(File(pickedImage!.path), height: 180, fit: BoxFit.cover),
                  SizedBox(height: 8),
                ]),
              Row(children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Galeri'),
                  onPressed: pickImageFromGallery,
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Kamera'),
                  onPressed: takePhoto,
                ),
                Spacer(),
                if (pickedImage != null)
                  TextButton(
                    onPressed: () => setState(() => pickedImage = null),
                    child: Text('Hapus'),
                  )
              ]),
              SizedBox(height: 20),
              uploading
                  ? Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Mengunggah...')])
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submit,
                        child: Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Kirim Laporan')),
                      ),
                    )
            ]),
          ),
        ),
      ),
    );
  }
}
