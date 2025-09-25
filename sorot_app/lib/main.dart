// Sorot App – main.dart (versi stabil, disederhanakan & diseragamkan skema Firestore)
// Alur: pilih foto → upload ke server lokal → dapat URL → simpan dokumen ke Firestore
// Skema dokumen diseragamkan dengan dashboard: title, desc, lat, lng, photoUrl, status (lowercase)
// Catatan Android: pastikan INTERNET + cleartext HTTP diizinkan (lihat komentar di bawah).

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

/// GANTI IP berikut dengan IP LAN PC Anda (bukan localhost)
/// Contoh format: http://192.168.0.112:5001
const String kUploadBase = 'http://192.168.0.106:5001';

Future<String> uploadImageToLocalServer(XFile file) async {
  final uri = Uri.parse('$kUploadBase/upload');

  final mime = lookupMimeType(file.path) ?? 'image/jpeg';
  final mediaType = MediaType.parse(mime);

  final req = http.MultipartRequest('POST', uri)
    ..fields['source'] = 'sorot-app'
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mediaType, 
      ),
    );

  final streamed = await req.send().timeout(const Duration(seconds: 30));
  final resp = await http.Response.fromStream(streamed);

  if (resp.statusCode != 200) {
    throw Exception('Upload gagal: HTTP ${resp.statusCode} — ${resp.body}');
  }

  final data = jsonDecode(resp.body) as Map<String, dynamic>;
  final url = (data['url'] ?? '').toString();
  if (url.isEmpty) throw Exception('Server tidak mengembalikan url');
  return url;
}

Future<void> _initFirebase() async {
  try {
    // Hanya init jika belum ada app yang ter-initialize
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    // Abaikan duplicate-app saat hot restart/hot reload
    if (e.code != 'duplicate-app') rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();

  // Opsional: login anonim agar rules yang butuh auth tetap jalan
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (_) {}

  runApp(const SorotApp());
}


/* ========================= THEME & ROOT ========================= */
class SorotApp extends StatelessWidget {
  const SorotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C6E49),
        primary: const Color(0xFF2C6E49),
        surface: const Color(0xFFBCD0C7),
        background: const Color(0xFFDEF2C8),
        secondary: const Color(0xFFA9B2AC),
      ),
      scaffoldBackgroundColor: const Color(0xFFDEF2C8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C6E49),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C6E49),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFDEF2C8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC5DAC1), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC5DAC1), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2C6E49), width: 2),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sorot',
      theme: theme,
      home: const HomePage(),
    );
  }
}

/* ========================= HOME ========================= */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Catatan: untuk realtime sederhana kita pakai snapshots().length.
  // Untuk dashboard web/adm: gunakan aggregation getCountFromServer di Web SDK.
  Stream<int> _totalReports() => FirebaseFirestore.instance
      .collection('reports')
      .snapshots()
      .map((s) => s.docs.length);

  Stream<int> _todayReports() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return FirebaseFirestore.instance
        .collection('reports')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .snapshots()
        .map((s) => s.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // di build() -> Scaffold(
      appBar: AppBar(
        title: const Text('Sorot — Laporan Lingkungan'),
        actions: [
          IconButton(
            tooltip: 'Semua Laporan',
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllReportsPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportFormPage()),
        ),
        label: const Text('Buat Laporan'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: _statCard('Total Laporan', _totalReports(), Icons.assignment)),
              const SizedBox(width: 14),
              Expanded(child: _statCard('Hari Ini', _todayReports(), Icons.today)),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            color: const Color(0xFFC5DAC1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Laporan Terbaru',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C6E49))),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reports')
                        .orderBy('createdAt', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) return const Text('Belum ada laporan.');

                      return Column(
                        children: docs.map((d) {
                          final r = d.data() as Map<String, dynamic>;
                          final title = (r['title'] ?? '-') as String;
                          final category = (r['category'] ?? '-') as String;
                          final status = (r['status'] ?? 'pending') as String;
                          final photo = r['photoUrl'] as String?;
                          final lat = r['lat'];
                          final lng = r['lng'];

                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: photo != null && photo.isNotEmpty
                                  ? Image.network(
                                      photo,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      color: const Color(0xFFBCD0C7),
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                            ),
                            title: Text(title,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              ['$category • $status${(lat != null && lng != null) ? " • $lat, $lng" : ""}',               
                                if ((r['adminNote'] as String?)?.trim().isNotEmpty ?? false)
                                  'Catatan: ${(r['adminNote'] as String).trim()}',
                              ].join('\n'),
                              softWrap: true,
                              maxLines: 3,
                            ),
                             isThreeLine: true,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, Stream<int> stream, IconData icon) {
    return Card(
      elevation: 4,
      color: const Color(0xFFC5DAC1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2C6E49).withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2C6E49)),
            ),
            const SizedBox(width: 14),
            // ⬇️ Tambah Expanded supaya konten fleksibel & tidak overflow
            Expanded(
              child: StreamBuilder<int>(
                stream: stream,
                builder: (context, snap) {
                  final val = snap.data ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$val',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C6E49),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFA9B2AC)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================= REPORT FORM ========================= */
class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _cTitle = TextEditingController();
  final _cDesc = TextEditingController();
  final _cLat = TextEditingController(text: '-5.1477');
  final _cLng = TextEditingController(text: '119.4327');

  final ImagePicker _picker = ImagePicker();
  String? _uploadedPhotoUrl; // URL hasil upload (wajib untuk submit)

  String _category = 'Sampah Ilegal';
  bool _submitting = false;

  @override
  void dispose() {
    _cTitle.dispose();
    _cDesc.dispose();
    _cLat.dispose();
    _cLng.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    try {
      final url = await uploadImageToLocalServer(x);
      if (!mounted) return;
      setState(() => _uploadedPhotoUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload berhasil')),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koneksi upload timeout. Pastikan IP server bisa diakses.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_cLat.text.trim());
    final lng = double.tryParse(_cLng.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude/Longitude tidak valid')),
      );
      return;
    }

    // Wajib ada foto agar photoUrl tidak null (sesuai requirement Anda)
    if (_uploadedPhotoUrl == null || _uploadedPhotoUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap upload foto terlebih dahulu')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final db = FirebaseFirestore.instance;
      await db.collection('reports').add({
        'title'    : _cTitle.text.trim(),
        'desc'     : _cDesc.text.trim(),
        'category' : _category,
        'status'   : 'pending', // diseragamkan lowercase
        'lat'      : lat,
        'lng'      : lng,
        'photoUrl' : _uploadedPhotoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'authorUid': FirebaseAuth.instance.currentUser?.uid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan terkirim!')),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: code=${e.code}, message=${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal kirim: ${e.code}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal kirim laporan: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detail Laporan',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C6E49))),
            const SizedBox(height: 12),

            TextFormField(
              controller: _cTitle,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _cDesc,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: const [
                DropdownMenuItem(value: 'Sampah Ilegal', child: Text('Sampah Ilegal')),
                DropdownMenuItem(value: 'Polusi Air', child: Text('Polusi Air')),
                DropdownMenuItem(value: 'Polusi Udara', child: Text('Polusi Udara')),
                DropdownMenuItem(value: 'Kerusakan Fasilitas', child: Text('Kerusakan Fasilitas')),
                DropdownMenuItem(value: 'Illegal Dumping', child: Text('Illegal Dumping')),
                DropdownMenuItem(value: 'Kerusuhan/Tawuran', child: Text('Kerusuhan/Tawuran')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),

            const SizedBox(height: 20),
            const Text('Lokasi (Manual)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cLat,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'Tidak valid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cLng,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    validator: (v) => double.tryParse(v?.trim() ?? '') == null ? 'Tidak valid' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAndUpload,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Upload Foto'),
                ),
                const SizedBox(width: 12),
                if (_uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            if (_uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _uploadedPhotoUrl!,
                  height: 120,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_submitting ? 'Mengirim...' : 'Kirim Laporan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

class AllReportsPage extends StatelessWidget {
  const AllReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Semua Laporan')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada laporan.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = docs[i].data() as Map<String, dynamic>;
              final title = (r['title'] ?? '-') as String;
              final category = (r['category'] ?? '-') as String;
              final status = (r['status'] ?? 'Menunggu') as String;

              // dukung lokasi di field datar (lat/lng) maupun nested {location:{lat,lng}}
              final loc = (r['location'] as Map<String, dynamic>?) ?? {};
              final lat = (r['lat'] ?? loc['lat'])?.toString();
              final lng = (r['lng'] ?? loc['lng'])?.toString();

              final photo = r['photoUrl'] as String?;
              final adminNote = (r['adminNote'] as String?)?.trim();

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: photo != null && photo.isNotEmpty
                      ? Image.network(photo, width: 64, height: 64, fit: BoxFit.cover)
                      : Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFBCD0C7),
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  [
                    '$category • $status${(lat != null && lng != null) ? " • $lat, $lng" : ""}',
                    if (adminNote?.isNotEmpty ?? false) 'Catatan: $adminNote',
                  ].join('\n'),
                  softWrap: true,
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}


/* ========================= ANDROID: INTERNET & CLEARTEXT HTTP ========================= */
// AndroidManifest.xml (android/app/src/main/AndroidManifest.xml)
// <manifest ...>
//   <uses-permission android:name="android.permission.INTERNET" />
//   <application
//       android:label="sorot_app"
//       android:icon="@mipmap/ic_launcher"
//       android:usesCleartextTraffic="true"
//       android:networkSecurityConfig="@xml/network_security_config">
//       ...
//   </application>
// </manifest>
//
// Buat file: android/app/src/main/res/xml/network_security_config.xml
// <?xml version="1.0" encoding="utf-8"?>
// <network-security-config>
//   <domain-config cleartextTrafficPermitted="true">
//     <domain includeSubdomains="true">192.168.0.112</domain>
//   </domain-config>
// </network-security-config>
