import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sorot - Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selamat datang di Sorot App 👋",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/laporan'),
              child: Text("Buat Laporan"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/status'),
              child: Text("Cek Status Laporan"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              child: Text("Admin Panel"),
            ),
          ],
        ),
      ),
    );
  }
}
