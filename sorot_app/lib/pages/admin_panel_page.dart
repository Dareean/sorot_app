import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  final List<Map<String, String>> laporanMasuk = [
    {"judul": "Sampah menumpuk", "status": "Menunggu"},
    {"judul": "Jalan rusak", "status": "Menunggu"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: ListView.builder(
        itemCount: laporanMasuk.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(laporanMasuk[index]["judul"]!),
              subtitle: Text("Status: ${laporanMasuk[index]["status"]}"),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Laporan '${laporanMasuk[index]["judul"]}' diproses")),
                  );
                },
                child: Text("Proses"),
              ),
            ),
          );
        },
      ),
    );
  }
}
