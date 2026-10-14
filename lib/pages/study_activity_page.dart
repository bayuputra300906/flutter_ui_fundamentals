import 'package:flutter/material.dart';

class StudyActivityPage extends StatefulWidget {
  const StudyActivityPage({super.key});

  @override
  State<StudyActivityPage> createState() =>
      _StudyActivityPageState();
}

class _StudyActivityPageState extends State<StudyActivityPage> {
  final List<String> materials = [
    'Pengenalan Flutter',
    'Widget dan Widget Tree',
    'Layout Row dan Column',
    'Responsive Layout',
    'State Management',
  ];

  // ValueNotifier menyimpan daftar status materi.
  late final ValueNotifier<List<bool>> completedMaterials;

  @override
  void initState() {
    super.initState();

    completedMaterials = ValueNotifier<List<bool>>(
      List<bool>.filled(materials.length, false),
    );
  }

  // Mengubah status materi ketika checkbox ditekan.
  void toggleMaterial(int index, bool? checked) {
    final updated = List<bool>.from(completedMaterials.value);
    updated[index] = checked ?? false;
    completedMaterials.value = updated;
  }

  @override
  void dispose() {
    completedMaterials.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas Belajar'),
      ),
      body: ValueListenableBuilder<List<bool>>(
        valueListenable: completedMaterials,
        builder: (context, completed, child) {
          final totalCompleted =
              completed.where((item) => item).length;

          final progress = totalCompleted / materials.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progres Belajar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$totalCompleted dari ${materials.length} materi selesai',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).round()}% selesai',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Daftar Materi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(materials.length, (index) {
                return Card(
                  child: CheckboxListTile(
                    value: completed[index],
                    onChanged: (checked) {
                      toggleMaterial(index, checked);
                    },
                    title: Text(materials[index]),
                    secondary: Icon(
                      completed[index]
                          ? Icons.check_circle
                          : Icons.menu_book,
                    ),
                    controlAffinity:
                        ListTileControlAffinity.leading,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
