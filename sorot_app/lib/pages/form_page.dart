import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  String _category = 'Sampah';
  File? _photo;

  final _cats = const ['Sampah', 'Banjir', 'Pohon Tumbang', 'Drainase', 'Lainnya'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x != null) setState(() => _photo = File(x.path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final lat = _lat.text.isEmpty ? null : double.tryParse(_lat.text);
    final lng = _lng.text.isEmpty ? null : double.tryParse(_lng.text);

    context.read<ReportProvider>().addReport(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      lat: lat,
      lng: lng,
      photo: _photo,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan dikirim!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Laporan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _desc,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lat,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Latitude (opsional)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lng,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Longitude (opsional)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.black12),
                ),
                child: _photo == null
                    ? const Center(child: Text('Upload Photo (ketuk untuk pilih)'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
