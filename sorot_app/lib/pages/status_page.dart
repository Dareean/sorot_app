import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  final List<Map<String, String>> laporanDummy = [
    {"judul": "Sampah menumpuk", "status": "Diproses"},
    {"judul": "Lampu jalan mati", "status": "Selesai"},
    {"judul": "Banjir di gang", "status": "Menunggu"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status Laporan")),
      body: ListView.builder(
        itemCount: laporanDummy.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(laporanDummy[index]["judul"]!),
            subtitle: Text("Status: ${laporanDummy[index]["status"]}"),
          );
        },
      ),
    );
  }
}
