import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/report.dart';

class ReportProvider extends ChangeNotifier {
  final List<Report> _reports = [];

  List<Report> get reports => List.unmodifiable(_reports);

  void addReport({
    required String title,
    required String description,
    required String category,
    double? lat,
    double? lng,
    File? photo,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _reports.insert(0, Report(
      id: id,
      title: title,
      description: description,
      category: category,
      latitude: lat,
      longitude: lng,
      photo: photo,
    ));
    notifyListeners();
  }

  void updateStatus(String id, ReportStatus status) {
    final r = _reports.firstWhere((e) => e.id == id);
    r.status = status;
    notifyListeners();
  }

  void addAdminNote(String id, String note) {
    final r = _reports.firstWhere((e) => e.id == id);
    r.adminNote = note;
    notifyListeners();
  }
}
