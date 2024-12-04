import 'package:flutter/material.dart';

Widget buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  TextStyle? valueStyle,
}) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey),
      SizedBox(width: 8),
      Text(
        "$label: ",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
