class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? photoPath;
  final String reporterName;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.photoPath,
    required this.reporterName,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      photoPath: json['photoPath'],
      reporterName: json['reporterName'] ?? 'Anonymous',
    );
  }
}
