import 'package:flutter/material.dart';
import '../models/report.dart';
import '../theme/colors.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const StatusBadge({super.key, required this.status});

  Color _bg(ReportStatus s, BuildContext ctx) {
    switch (s) {
      case ReportStatus.inProgress: return AppColors.inProgress.withOpacity(.2);
      case ReportStatus.rejected:   return AppColors.rejected.withOpacity(.2);
      case ReportStatus.accepted:   return const Color(0xFF90BE6D).withOpacity(.25);
      case ReportStatus.completed:  return AppColors.darkGreen.withOpacity(.18);
      case ReportStatus.submitted:  return Colors.grey.withOpacity(.2);
    }
  }

  Color _fg(ReportStatus s) {
    switch (s) {
      case ReportStatus.inProgress: return AppColors.inProgress;
      case ReportStatus.rejected:   return AppColors.rejected;
      case ReportStatus.accepted:   return const Color(0xFF40916C);
      case ReportStatus.completed:  return AppColors.darkGreen;
      case ReportStatus.submitted:  return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(status, context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: _fg(status),
        ),
      ),
    );
  }
}
