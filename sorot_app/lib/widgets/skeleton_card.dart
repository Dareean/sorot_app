// lib/widgets/skeleton_card.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white70,
      highlightColor: Colors.grey.shade200,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(12),
        child: Row(children: [
          Container(width: 86, height: 86, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 18, width: 180, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 14, width: double.infinity, color: Colors.white),
            SizedBox(height: 8),
            Container(height: 14, width: 120, color: Colors.white),
          ]))
        ]),
      ),
    );
  }
}
