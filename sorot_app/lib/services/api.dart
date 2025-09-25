import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sorot_app/main.dart'; // Import Report model dari main.dart

class ApiService {
  static final Logger _logger = Logger();
  static const String BASE_URL = 'http://192.168.0.109:5000'; // Ganti ke 'http://10.0.2.2:5000' untuk emulator

  static Future<List<Report>> fetchReports() async {
    final resp = await http.get(Uri.parse('$BASE_URL/api/reports'));
    if (resp.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(resp.body);
      final List<dynamic> arr = json['data'];
      return arr.map((j) => Report.fromJson(j)).toList();
    } else {
      _logger.e('Failed to load reports: ${resp.statusCode}');
      throw Exception('Failed to load reports: ${resp.statusCode}');
    }
  }

  static Future<Report> createReport({
    required String title,
    required String description,
    required String category,
    required double lat,
    required double lng,
    String? imagePath,
  }) async {
    return compute(_createReportIsolate, {
      'title': title,
      'description': description,
      'category': category,
      'lat': lat,
      'lng': lng,
      'imagePath': imagePath,
    });
  }

  static Future<Report> _createReportIsolate(Map<String, dynamic> params) async {
    final String title = params['title'];
    final String description = params['description'];
    final String category = params['category'];
    final double lat = params['lat'];
    final double lng = params['lng'];
    final String? imagePath = params['imagePath'];

    final uri = Uri.parse('$BASE_URL/api/reports');
    _logger.i("➡️ Akan kirim POST ke $uri");
    _logger.i("Judul   : $title");
    _logger.i("Deskripsi: $description");
    _logger.i("Kategori : $category");
    _logger.i("Latitude : $lat, Longitude: $lng");

    if (imagePath == null) {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "description": description,
          "category": category,
          "latitude": lat,
          "longitude": lng,
          "reporterName": "Anonymous",
        }),
      );

      _logger.i("⬅️ Response [${resp.statusCode}]: ${resp.body}");

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return Report.fromJson(jsonDecode(resp.body)['data']);
      } else {
        _logger.e('Failed to create report: ${resp.body}');
        throw Exception('Failed to create report: ${resp.body}');
      }
    } else {
      final request = http.MultipartRequest('POST', uri)
        ..fields['title'] = title
        ..fields['description'] = description
        ..fields['category'] = category
        ..fields['latitude'] = lat.toString()
        ..fields['longitude'] = lng.toString()
        ..fields['reporterName'] = "Anonymous"
        ..files.add(await http.MultipartFile.fromPath(
          'photo',
          imagePath,
          contentType: MediaType.parse(lookupMimeType(imagePath) ?? 'application/octet-stream'),
        ));

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      _logger.i("➡️ POST /api/reports | ${resp.statusCode} | ${resp.body}");

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return Report.fromJson(jsonDecode(resp.body)['data']);
      } else {
        _logger.e('Failed to create (multipart): ${resp.body}');
        throw Exception('Failed to create (multipart): ${resp.body}');
      }
    }
  }
}