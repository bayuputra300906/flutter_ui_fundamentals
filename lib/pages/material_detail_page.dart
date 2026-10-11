import 'package:flutter/material.dart';

class MaterialDetailPage extends StatelessWidget {
  final String courseTitle;
  final Map<String, dynamic> material;

  const MaterialDetailPage({
    super.key,
    required this.courseTitle,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> sections =
        List<String>.from(material['sections'] as List);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Isi Materi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    courseTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material['title'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tujuan Pembelajaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              material['objective'] as String,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
            const SizedBox(height: 24),

            const Text(
              'Penjelasan Materi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...sections.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ${entry.value}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (material['explanations']
                                  as List<String>)[entry.key],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if ((material['example'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Contoh',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF263238)
                      : const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  material['example'] as String,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Rangkuman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              material['summary'] as String,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Selesai Membaca'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
