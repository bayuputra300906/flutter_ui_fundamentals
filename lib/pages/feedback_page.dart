import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // ==========================================================
  // IDENTITAS
  // ==========================================================

  static const String studentName = 'Gede Bayu Putra Darmawan';
  static const String studentNim = '2415051105';

  // ==========================================================
  // FORM KEY
  // ==========================================================

  final formKey = GlobalKey<FormState>();

  // ==========================================================
  // CONTROLLER
  // ==========================================================

  final nameController = TextEditingController(
    text: studentName,
  );

  final nimController = TextEditingController(
    text: studentNim,
  );

  final commentController = TextEditingController();

  // ==========================================================
  // LOADING
  // Tahap 14
  // ==========================================================

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    commentController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SUBMIT FORM
  // Tahap 13 & 14
  // ==========================================================

  Future<void> submitForm() async {
    // ========================================================
    // VALIDASI FORM
    // ========================================================

    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    // ========================================================
    // DIALOG KONFIRMASI
    // Tahap 14
    // ========================================================

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi',
          ),
          content: const Text(
            'Apakah Anda yakin ingin mengirim feedback?',
          ),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Batal',
              ),
            ),

            // Tombol Kirim
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Kirim',
              ),
            ),
          ],
        );
      },
    );

    // Jika pengguna memilih Batal
    if (confirmed != true) {
      return;
    }

    // ========================================================
    // LOADING
    // Tahap 14
    // ========================================================

    setState(() {
      isLoading = true;
    });

    // Simulasi proses penyimpanan selama 2 detik
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    // Selesai loading
    setState(() {
      isLoading = false;
    });

    // ========================================================
    // SNACKBAR
    // Tahap 14
    // ========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Data feedback berhasil disimpan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedback',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // JUDUL
              // ==================================================

              const Text(
                'Form Feedback',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Silakan berikan feedback terhadap pembelajaran.',
              ),

              const SizedBox(height: 24),

              // ==================================================
              // NAMA
              // ==================================================

              TextFormField(
                controller: nameController,

                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama',
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // NIM
              // ==================================================

              TextFormField(
                controller: nimController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: 'NIM',
                  hintText: 'Masukkan NIM',
                  prefixIcon: Icon(
                    Icons.badge,
                  ),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ==================================================
              // KOMENTAR
              // ==================================================

              TextFormField(
                controller: commentController,

                maxLines: 5,

                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText:
                      'Tuliskan komentar minimal 5 karakter',
                  prefixIcon: Icon(
                    Icons.comment,
                  ),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Komentar wajib diisi';
                  }

                  if (value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // TOMBOL KIRIM
              // Tahap 14
              // ==================================================

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  // Tombol tidak bisa ditekan
                  // ketika sedang loading
                  onPressed:
                      isLoading ? null : submitForm,

                  // Tampilkan loading atau icon send
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send,
                        ),

                  // Tampilkan teks sesuai kondisi
                  label: Text(
                    isLoading
                        ? 'Menyimpan...'
                        : 'Kirim Feedback',
                  ),

                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // IDENTITAS
              // ==================================================

              const Center(
                child: Text(
                  'Nama: Gede Bayu Putra Darmawan\n'
                  'NIM: 2415051105',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // KETERANGAN TAHAP
              // ==================================================

              const Center(
                child: Text(
                  'Form, Validasi, Dialog, '
                  'Loading & SnackBar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}