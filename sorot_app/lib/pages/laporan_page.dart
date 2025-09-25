import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _formKey = GlobalKey<FormState>();
  String? judul, deskripsi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buat Laporan")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Judul Laporan"),
                onSaved: (val) => judul = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Deskripsi"),
                onSaved: (val) => deskripsi = val,
                maxLines: 4,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Laporan dikirim: $judul")),
                  );
                  Navigator.pop(context);
                },
                child: Text("Kirim"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
