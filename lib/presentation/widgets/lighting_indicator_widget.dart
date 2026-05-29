import 'package:flutter/material.dart';

class LightingIndicatorWidget extends StatelessWidget {
  final bool isGood;

  const LightingIndicatorWidget({super.key, required this.isGood});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGood ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
            color: isGood ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isGood ? 'Pencahayaan OK' : 'Terlalu Gelap',
            style: TextStyle(
              color: isGood ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
