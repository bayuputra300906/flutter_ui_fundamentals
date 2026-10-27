import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class EditCoursePage extends StatefulWidget {
  final Course course;

  const EditCoursePage({
    super.key,
    required this.course,
  });

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  late String _status;

  @override
  void initState() {
    super.initState();

    // Mengisi form dengan data mata kuliah sebelumnya.
    _codeController = TextEditingController(
      text: widget.course.code,
    );

    _titleController = TextEditingController(
      text: widget.course.title,
    );

    _creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );

    _status = widget.course.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ID diperlukan untuk menentukan resource yang diperbarui.
    final int? courseId = widget.course.id;

    if (courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mata kuliah ini tidak memiliki ID untuk diperbarui.',
          ),
        ),
      );
      return;
    }

    final provider = context.read<CourseProvider>();

    if (provider.isSaving) {
      return;
    }

    final updatedCourse = Course(
      id: courseId,
      code: widget.course.code,
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );
    
    try {
      await provider.updateCourse(courseId, updatedCourse);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pembaruan berhasil dikirim.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui mata kuliah: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mata Kuliah'),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kode tidak dapat diubah karena menjadi kunci favorit.
                  TextFormField(
                    controller: _codeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Kode Mata Kuliah',
                      border: OutlineInputBorder(),
                      helperText: 'Kode mata kuliah tidak dapat diubah.',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Mata Kuliah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama mata kuliah wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _creditsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SKS',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'SKS wajib diisi';
                      }

                      final credits = int.tryParse(value.trim());

                      if (credits == null || credits <= 0) {
                        return 'SKS harus berupa angka positif';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'planned',
                        child: Text('Planned'),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: 'done',
                        child: Text('Done'),
                      ),
                    ],
                    onChanged: provider.isSaving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _status = value;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: provider.isSaving ? null : _saveChanges,
                    icon: provider.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      provider.isSaving
                          ? 'Menyimpan...'
                          : 'Simpan Perubahan',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}