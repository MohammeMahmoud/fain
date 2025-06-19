import 'package:flutter/material.dart';

Widget sliderItem({required String image, required String title, required String subtitle}) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Image.network(
        image,
        fit: BoxFit.cover,
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
      Positioned(
        left: 16,
        bottom: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
