import 'package:flutter/material.dart';


// ============================================================
// PROFILE PAGE
// Scrollable Content & Keyboard
// ============================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}


// ============================================================
// PROFILE PAGE STATE
// ============================================================

class _ProfilePageState extends State<ProfilePage> {

  // Controller untuk TextField
  final TextEditingController nameController =
      TextEditingController();

  // Menyimpan nama yang ditampilkan
  String displayedName =
      'Gede Bayu Putra Darmawan';


  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }


  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Profile',
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
            // HEADER PROFILE
            // ==================================================

            Center(
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 55,

                    backgroundColor:
                        Theme.of(context)
                            .colorScheme
                            .primaryContainer,

                    child: Icon(
                      Icons.person,
                      size: 60,

                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Profil Mahasiswa',

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  children: [

                    // NAMA
                    Row(
                      children: [

                        const Icon(
                          Icons.person,
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Text(
                            'Nama',
                          ),
                        ),

                        Expanded(
                          child: Text(
                            displayedName,

                            textAlign:
                                TextAlign.end,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 24,
                    ),

                    // NIM
                    const Row(
                      children: [

                        Icon(
                          Icons.badge,
                        ),

                        SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            'NIM',
                          ),
                        ),

                        Text(
                          '2415051105',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 24,
                    ),

                    // SEMESTER
                    const Row(
                      children: [

                        Icon(
                          Icons.school,
                        ),

                        SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            'Semester',
                          ),
                        ),

                        Text(
                          '5',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 24,
                    ),

                    // PROGRAM STUDI
                    const Row(
                      children: [

                        Icon(
                          Icons.account_balance,
                        ),

                        SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Text(
                            'Program Studi',
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'Pendidikan Teknik Informatika',

                            textAlign:
                                TextAlign.end,

                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
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
            // FORM EDIT NAMA
            // ==================================================

            const Text(
              'Edit Nama',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,

              decoration:
                  const InputDecoration(
                labelText: 'Nama Mahasiswa',
                hintText:
                    'Masukkan nama mahasiswa',
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),


            // ==================================================
            // TOMBOL SIMPAN
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed: () {

                  // Mengubah state
                  setState(() {

                    if (nameController
                        .text
                        .trim()
                        .isNotEmpty) {

                      displayedName =
                          nameController
                              .text
                              .trim();
                    }
                  });
                },

                icon: const Icon(
                  Icons.save,
                ),

                label: const Text(
                  'Simpan Nama',
                ),
              ),
            ),

            const SizedBox(height: 30),


            // ==================================================
            // CONTOH CONTENT PANJANG
            // Untuk menguji SingleChildScrollView
            // ==================================================

            const Text(
              'Catatan Pembelajaran',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: const Text(
                'Halaman profile ini menggunakan '
                'SingleChildScrollView agar seluruh '
                'konten tetap dapat diakses ketika '
                'tinggi layar terbatas. Saat keyboard '
                'muncul ketika TextField digunakan, '
                'pengguna masih dapat melakukan scroll '
                'untuk melihat bagian halaman lainnya.\n\n'
                'Pada aplikasi dengan data yang sangat '
                'panjang, ListView atau GridView lebih '
                'sesuai karena widget tersebut dirancang '
                'untuk menampilkan daftar data yang '
                'dapat di-scroll.',
                
                style: TextStyle(
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),


            // ==================================================
            // IDENTITAS UNTUK BUKTI PRAKTIKUM
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

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Tahap 6 • Scrollable Content & Keyboard',

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