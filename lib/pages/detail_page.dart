import 'package:flutter/material.dart';
import 'feedback_page.dart';

// ============================================================
// DETAIL PAGE
// Tahap 8 - Passing Data
// Tahap 9 - Returning Data
// ============================================================

class DetailPage extends StatelessWidget {
  // Data course yang dikirim dari HomePage
  final Map<String, dynamic> course;

  const DetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Detail Mata Kuliah',
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ICON COURSE
            // ==================================================

            Center(
              child: Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,

                  borderRadius:
                      BorderRadius.circular(24),
                ),

                child: Icon(
                  course['icon'] ?? Icons.menu_book,
                  size: 48,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // JUDUL COURSE
            // ==================================================

            Center(
              child: Text(
                course['title'] ?? '-',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                course['subtitle'] ?? '-',

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // INFORMASI MATA KULIAH
            // ==================================================

            const Text(
              'Informasi Mata Kuliah',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  children: [
                    // KODE
                    Row(
                      children: [
                        const Icon(
                          Icons.code,
                          size: 24,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'Kode Mata Kuliah',
                          ),
                        ),

                        Text(
                          course['code'] ?? '-',

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // SKS
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 24,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'Jumlah SKS',
                          ),
                        ),

                        Text(
                          '${course['credits'] ?? '-'} SKS',

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // STATUS
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 24,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'Status',
                          ),
                        ),

                        Text(
                          course['status'] ?? '-',

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            color:
                                course['status'] ==
                                        'Selesai'
                                    ? Colors.green
                                    : course['status'] ==
                                            'Aktif'
                                        ? Colors.orange
                                        : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // INFORMASI MAHASISWA
            // ==================================================

            const Text(
              'Informasi Mahasiswa',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  children: [
                    // NAMA
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Icon(
                          Icons.person,
                          size: 24,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'Nama Mahasiswa',
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            'Gede Bayu Putra Darmawan',

                            textAlign:
                                TextAlign.end,

                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // NIM
                    Row(
                      children: [
                        const Icon(
                          Icons.badge,
                          size: 24,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'NIM',
                          ),
                        ),

                        const Text(
                          '2415051105',

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 28,
                    ),

                    // SEMESTER
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 24,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            'Semester',
                          ),
                        ),

                        const Text(
                          '5',

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // TOMBOL PILIH / FAVORITE DAN KEMBALI
            // Tahap 9
            // ==================================================

            Row(
              children: [
                // ==================================================
                // TOMBOL FAVORITE
                // ==================================================

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mengembalikan nilai true
                      // ke HomePage
                      Navigator.pop(
                        context,
                        true,
                      );
                    },

                    icon: const Icon(
                      Icons.favorite,
                    ),

                    label: const Text(
                      'Pilih / Favorite',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ==================================================
                // TOMBOL KEMBALI
                // ==================================================

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(
                      Icons.arrow_back,
                    ),

                    label: const Text(
                      'Kembali',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
// TOMBOL FEEDBACK
// Tahap 13
// ==================================================

const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FeedbackPage(),
        ),
      );
    },
    icon: const Icon(
      Icons.feedback,
    ),
    label: const Text(
      'Beri Feedback',
    ),
  ),
),

const SizedBox(height: 20),

            // ==================================================
            // KETERANGAN TAHAP
            // ==================================================

            const Center(
              child: Text(
                'Passing Data & Returning Data',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // NAMA DAN NIM UNTUK BUKTI PRAKTIKUM
            // ==================================================

            const Center(
              child: Text(
                'Nama: Gede Bayu Putra Darmawan\n'
                'NIM: 2415051105',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}