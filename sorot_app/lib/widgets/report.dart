class Report {
  final String id;
  final String title;
  final String description;
  final String status;
  final double lat;
  final double lng;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.lat,
    required this.lng,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'status': status,
      'lat': lat,
      'lng': lng,
    };
  }
}
