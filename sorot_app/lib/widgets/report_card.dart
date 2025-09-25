// lib/widgets/report_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/report.dart';

class ReportCard extends StatefulWidget {
  final Report report;
  final VoidCallback? onTap;
  const ReportCard({required this.report, this.onTap});

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: Duration(milliseconds: 120),
        scale: pressed ? 0.995 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFDEF2C8).withOpacity(0.95),
                Color(0xFFC5DAC1).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 8),
                blurRadius: 18,
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          padding: EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // thumbnail placeholder
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo, size: 40, color: Colors.white24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(r.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                      SizedBox(width: 8),
                      StatusChip(status: r.status),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    r.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87.withOpacity(0.8)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.place, size: 14, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('${r.lat.toStringAsFixed(3)}, ${r.lng.toStringAsFixed(3)}',
                          style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Spacer(),
                      Text(
                        timeAgo(r.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      )
                    ],
                  )
                ]),
              )
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.02),
      ),
    );
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({required this.status});
  @override
  Widget build(BuildContext context) {
    Color bg;
    if (status.toLowerCase() == 'open') bg = Colors.redAccent.withOpacity(0.12);
    else if (status.toLowerCase() == 'in progress') bg = Colors.orangeAccent.withOpacity(0.10);
    else bg = Colors.green.withOpacity(0.10);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }
}
