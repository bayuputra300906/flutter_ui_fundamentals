import 'package:flutter/material.dart';

class KosDetailPage extends StatelessWidget {
  const KosDetailPage({super.key, required this.kosId});

  final String kosId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kos')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                'Kos ID: $kosId',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Halaman dibuka melalui Push Notification TAP'),
            ],
          ),
        ),
      ),
    );
  }
}
