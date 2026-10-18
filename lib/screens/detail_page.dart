import 'package:flutter/material.dart';
import 'feedback_page.dart';
import 'material_detail_page.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const DetailPage({
    super.key,
    required this.course,
  });

  static const Map<String, List<Map<String, dynamic>>> courseMaterials = {
    'Git & GitHub': [
      {
        'title': 'Pengenalan Git dan Version Control',
        'objective':
            'Memahami fungsi Git dan pentingnya version control dalam pengembangan aplikasi.',
        'sections': [
          'Pengertian Git',
          'Manfaat Version Control',
          'Instalasi dan Konfigurasi Git',
          'Perintah Dasar Git',
        ],
        'explanations': [
          'Git adalah sistem version control terdistribusi yang digunakan untuk mencatat perubahan pada file proyek. Git membantu pengembang mengetahui perubahan yang terjadi dan kembali ke versi sebelumnya jika diperlukan.',
          'Version control membantu menyimpan riwayat perubahan, membandingkan versi file, memperbaiki kesalahan, dan mengerjakan proyek bersama tanpa harus menyalin seluruh folder setiap kali ada perubahan.',
          'Setelah Git diinstal, identitas pengguna dapat diatur melalui terminal menggunakan git config. Nama dan email ini akan dicatat pada commit yang dibuat.',
          'Perintah dasar Git antara lain git init untuk membuat repository, git status untuk melihat kondisi file, git add untuk menyiapkan perubahan, dan git commit untuk menyimpan snapshot perubahan.',
        ],
        'example': r'''
git config --global user.name "Nama Mahasiswa"
git config --global user.email "email@example.com"

git init
git status
git add .
git commit -m "Commit pertama"
''',
        'summary':
            'Git mencatat perubahan proyek melalui commit. Perintah init, status, add, dan commit merupakan dasar penggunaan Git.',
      },
      {
        'title': 'Repository, Commit, dan Riwayat',
        'objective':
            'Memahami repository, proses commit, dan cara melihat riwayat perubahan.',
        'sections': [
          'Pengertian Repository',
          'Staging Area',
          'Membuat Commit',
          'Melihat Riwayat Perubahan',
        ],
        'explanations': [
          'Repository adalah tempat penyimpanan proyek beserta riwayat perubahannya. Repository Git dapat berada di komputer lokal maupun di layanan hosting seperti GitHub.',
          'Staging area merupakan tempat menyiapkan perubahan yang akan dimasukkan ke commit. Perintah git add digunakan untuk memasukkan file ke staging area.',
          'Commit adalah snapshot perubahan yang disimpan dalam riwayat repository. Pesan commit sebaiknya singkat tetapi menjelaskan perubahan yang dilakukan.',
          'Perintah git log menampilkan riwayat commit. Sementara itu, git diff dapat digunakan untuk melihat perbedaan perubahan pada file.',
        ],
        'example': r'''
git status
git add lib/main.dart
git commit -m "Menambahkan halaman utama"
git log --oneline
git diff
''',
        'summary':
            'Repository menyimpan proyek dan riwayatnya. Staging area menyiapkan perubahan, sedangkan commit menyimpan perubahan tersebut.',
      },
      {
        'title': 'Branch dan Kolaborasi GitHub',
        'objective':
            'Memahami penggunaan branch dan alur kerja kolaborasi melalui GitHub.',
        'sections': [
          'Pengertian Branch',
          'Membuat Branch',
          'Remote Repository',
          'Pull Request',
        ],
        'explanations': [
          'Branch adalah cabang pengembangan yang memungkinkan fitur dikerjakan secara terpisah dari branch utama. Dengan demikian, perubahan dapat diuji sebelum digabungkan.',
          'Branch dapat dibuat menggunakan git branch dan dipilih menggunakan git switch. Branch baru sebaiknya memiliki nama yang menggambarkan fitur atau perbaikan yang sedang dikerjakan.',
          'Remote repository adalah repository yang berada di server, misalnya GitHub. Perintah git push mengirim commit ke remote, sedangkan git pull mengambil dan menggabungkan perubahan dari remote.',
          'Pull request merupakan mekanisme untuk mengusulkan perubahan agar dapat ditinjau sebelum digabungkan ke branch tujuan. Tim dapat memberikan komentar dan meminta perbaikan.',
        ],
        'example': r'''
git switch -c fitur-halaman-profil
git add .
git commit -m "Menambahkan halaman profil"
git push -u origin fitur-halaman-profil
''',
        'summary':
            'Branch membantu memisahkan pekerjaan. GitHub mendukung penyimpanan remote dan proses peninjauan perubahan melalui pull request.',
      },
    ],

    'Dart Fundamentals': [
      {
        'title': 'Variabel dan Tipe Data Dart',
        'objective':
            'Mengenali variabel, tipe data, dan cara menyimpan informasi menggunakan Dart.',
        'sections': [
          'Pengertian Variabel',
          'Tipe Data Dasar',
          'Kata Kunci var, final, dan const',
          'Null Safety',
        ],
        'explanations': [
          'Variabel adalah nama yang digunakan untuk menyimpan atau merujuk suatu nilai. Nama variabel sebaiknya jelas agar kode lebih mudah dibaca.',
          'Dart memiliki tipe data seperti int untuk bilangan bulat, double untuk bilangan desimal, String untuk teks, bool untuk nilai benar atau salah, serta List untuk kumpulan data.',
          'Kata kunci var memungkinkan Dart menyimpulkan tipe data. final digunakan untuk nilai yang hanya ditetapkan sekali, sedangkan const digunakan untuk nilai konstan yang diketahui saat kompilasi.',
          'Null safety membantu mencegah penggunaan nilai null secara tidak sengaja. Tipe seperti String? dapat berisi teks atau null, sedangkan String biasa tidak menerima null.',
        ],
        'example': r'''
String nama = 'Mahasiswa';
int semester = 5;
double ipk = 3.75;
bool aktif = true;

final kampus = 'Universitas';
const jumlahMaksimal = 10;
String? namaPanggilan;
''',
        'summary':
            'Variabel menyimpan atau merujuk nilai. Pemilihan tipe data dan penggunaan null safety membantu menghasilkan kode yang lebih aman.',
      },
      {
        'title': 'Operator dan Percabangan',
        'objective':
            'Menggunakan operator dan percabangan untuk membuat keputusan dalam program Dart.',
        'sections': [
          'Operator Aritmetika',
          'Operator Perbandingan',
          'Operator Logika',
          'Percabangan if dan else',
        ],
        'explanations': [
          'Operator aritmetika digunakan untuk perhitungan, misalnya + untuk penjumlahan, - untuk pengurangan, * untuk perkalian, dan / untuk pembagian.',
          'Operator perbandingan seperti ==, !=, >, <, >=, dan <= membandingkan dua nilai dan menghasilkan nilai boolean.',
          'Operator logika && berarti kedua kondisi harus benar, || berarti minimal satu kondisi benar, sedangkan ! membalik nilai boolean.',
          'Percabangan if dan else menjalankan blok kode sesuai kondisi. else if dapat digunakan untuk memeriksa kondisi tambahan.',
        ],
        'example': r'''
int nilai = 85;

if (nilai >= 80) {
  print('Nilai sangat baik');
} else if (nilai >= 70) {
  print('Nilai baik');
} else {
  print('Perlu belajar lagi');
}
''',
        'summary':
            'Operator digunakan untuk perhitungan dan evaluasi kondisi. Percabangan menentukan instruksi yang dijalankan berdasarkan hasil kondisi.',
      },
      {
        'title': 'Perulangan, List, dan Fungsi',
        'objective':
            'Memahami perulangan, pengelolaan kumpulan data, dan penggunaan fungsi dalam Dart.',
        'sections': [
          'Perulangan for',
          'Perulangan while',
          'List dan Pengolahan Data',
          'Fungsi dan Parameter',
        ],
        'explanations': [
          'Perulangan for cocok digunakan ketika proses dilakukan berdasarkan jumlah iterasi atau indeks tertentu.',
          'Perulangan while menjalankan blok kode selama kondisi bernilai true. Pastikan kondisi dapat berubah agar tidak terjadi perulangan tanpa akhir.',
          'List menyimpan sekumpulan nilai secara berurutan. Elemen dapat diakses menggunakan indeks yang dimulai dari 0. Metode seperti add, where, dan map membantu mengolah data.',
          'Fungsi mengelompokkan instruksi agar dapat digunakan kembali. Fungsi dapat menerima parameter dan mengembalikan hasil melalui return.',
        ],
        'example': r'''
List<String> mataKuliah = [
  'Dart',
  'Flutter',
  'Git',
];

for (final mataKuliahItem in mataKuliah) {
  print(mataKuliahItem);
}

int tambah(int a, int b) {
  return a + b;
}

print(tambah(2, 3));
''',
        'summary':
            'Perulangan mengulang instruksi, List menyimpan kumpulan data, dan fungsi membuat kode lebih terstruktur serta dapat digunakan kembali.',
      },
    ],

    'Flutter UI': [
      {
        'title': 'Pengenalan Flutter dan Widget',
        'objective':
            'Memahami Flutter, struktur widget, dan cara menyusun antarmuka aplikasi.',
        'sections': [
          'Pengertian Flutter',
          'Widget dalam Flutter',
          'StatelessWidget',
          'StatefulWidget',
        ],
        'explanations': [
          'Flutter adalah framework untuk membangun aplikasi dengan satu basis kode. Flutter menggunakan bahasa Dart dan menyusun antarmuka dari widget.',
          'Widget adalah komponen penyusun antarmuka, seperti Text, Icon, Image, Container, Row, dan Column. Widget dapat disusun bertingkat membentuk widget tree.',
          'StatelessWidget digunakan untuk tampilan yang tidak mengelola state yang dapat berubah di dalam widget itu sendiri.',
          'StatefulWidget digunakan ketika tampilan perlu merespons perubahan state. Contohnya penghitung angka, formulir interaktif, atau tombol yang mengubah tampilan.',
        ],
        'example': r'''
import 'package:flutter/material.dart';

class SapaanPage extends StatelessWidget {
  const SapaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Halo, Flutter!'),
      ),
    );
  }
}
''',
        'summary':
            'Flutter membangun antarmuka dari widget. StatelessWidget cocok untuk tampilan tanpa state lokal yang berubah, sedangkan StatefulWidget mengelola state.',
      },
      {
        'title': 'Layout, Row, Column, dan Container',
        'objective':
            'Menyusun tata letak antarmuka dengan widget layout utama Flutter.',
        'sections': [
          'Container',
          'Row',
          'Column',
          'Padding dan SizedBox',
        ],
        'explanations': [
          'Container digunakan untuk membungkus widget dengan pengaturan ukuran, padding, margin, warna, dekorasi, dan alignment.',
          'Row menyusun widget secara horizontal. Properti mainAxisAlignment dan crossAxisAlignment mengatur posisi anak pada kedua sumbu.',
          'Column menyusun widget secara vertikal. Column sering digunakan untuk menyusun judul, deskripsi, tombol, dan komponen lain.',
          'Padding memberi jarak di dalam batas area widget, sedangkan SizedBox dapat memberikan jarak tetap atau ukuran tertentu.',
        ],
        'example': r'''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('Profil Mahasiswa'),
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Belajar Flutter'),
    ),
    Row(
      children: [
        const Icon(Icons.book),
        const SizedBox(width: 8),
        const Text('Materi UI'),
      ],
    ),
  ],
)
''',
        'summary':
            'Row menyusun widget secara horizontal, Column secara vertikal, Container mengatur tampilan, dan Padding serta SizedBox membantu mengatur jarak.',
      },
      {
        'title': 'Tema, Card, dan Layout Responsif',
        'objective':
            'Membuat tampilan konsisten dan menyesuaikan layout dengan ukuran layar.',
        'sections': [
          'ThemeData',
          'Card dan BoxDecoration',
          'MediaQuery',
          'LayoutBuilder',
        ],
        'explanations': [
          'ThemeData mengatur gaya global aplikasi seperti warna, tipografi, AppBar, dan tombol. Tema membantu menjaga konsistensi antarlayar.',
          'Card menampilkan konten di dalam permukaan berbentuk kartu. BoxDecoration dapat mengatur warna, sudut membulat, border, dan bayangan pada Container.',
          'MediaQuery menyediakan informasi layar, termasuk lebar dan tinggi. Informasi tersebut dapat digunakan untuk menentukan jumlah kolom atau ukuran komponen.',
          'LayoutBuilder memberikan batasan ruang dari widget induk. Dengan batasan tersebut, layout dapat diubah untuk layar sempit, sedang, dan lebar.',
        ],
        'example': r'''
LayoutBuilder(
  builder: (context, constraints) {
    final columns =
        constraints.maxWidth < 600 ? 1 :
        constraints.maxWidth < 840 ? 2 : 3;

    return GridView.count(
      crossAxisCount: columns,
      children: const [
        Card(child: Center(child: Text('Materi 1'))),
        Card(child: Center(child: Text('Materi 2'))),
        Card(child: Center(child: Text('Materi 3'))),
      ],
    );
  },
)
''',
        'summary':
            'Tema menjaga konsistensi desain, Card mengelompokkan konten, dan MediaQuery serta LayoutBuilder membantu membuat layout responsif.',
      },
    ],

    'Navigation': [
      {
        'title': 'Navigasi Antarhalaman',
        'objective':
            'Memahami cara berpindah dari satu halaman ke halaman lain dalam Flutter.',
        'sections': [
          'Navigator',
          'MaterialPageRoute',
          'Navigator.push',
          'Navigator.pop',
        ],
        'explanations': [
          'Navigasi adalah proses berpindah antarhalaman. Navigator mengelola tumpukan route yang digunakan oleh aplikasi.',
          'MaterialPageRoute membuat route halaman dengan transisi bergaya Material Design.',
          'Navigator.push menambahkan halaman baru ke atas tumpukan sehingga pengguna dapat membuka halaman tujuan.',
          'Navigator.pop menutup halaman aktif dan kembali ke halaman sebelumnya. Data juga dapat dikembalikan melalui nilai yang diberikan kepada pop.',
        ],
        'example': r'''
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HalamanKedua(),
  ),
);

// Kembali ke halaman sebelumnya:
Navigator.pop(context);
''',
        'summary':
            'Navigator.push membuka halaman baru, sedangkan Navigator.pop menutup halaman aktif dan kembali ke halaman sebelumnya.',
      },
      {
        'title': 'Passing Data Antarhalaman',
        'objective':
            'Mengirim informasi dari satu halaman ke halaman lain melalui parameter.',
        'sections': [
          'Constructor Halaman',
          'Parameter Wajib',
          'Mengirim Objek atau Map',
          'Menampilkan Data Tujuan',
        ],
        'explanations': [
          'Halaman tujuan dapat menerima informasi melalui constructor. Dengan cara ini, halaman tidak harus mengambil ulang data yang sudah tersedia.',
          'Parameter wajib dapat ditandai dengan required. Pemanggil harus memberikan nilai untuk parameter tersebut ketika membuat halaman.',
          'Data yang dikirim dapat berupa String, angka, objek model, atau Map. Pilih struktur yang sesuai dengan kebutuhan aplikasi.',
          'Halaman tujuan menggunakan data yang diterima untuk menampilkan judul, detail, atau informasi lainnya.',
        ],
        'example': r'''
class DetailPage extends StatelessWidget {
  final String judul;

  const DetailPage({
    super.key,
    required this.judul,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: Center(child: Text(judul)),
    );
  }
}

// Membuka halaman:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => const DetailPage(
//       judul: 'Materi Flutter',
//     ),
//   ),
// );
''',
        'summary':
            'Passing data memungkinkan halaman tujuan menerima informasi melalui constructor sehingga konten dapat disesuaikan dengan data yang dipilih.',
      },
      {
        'title': 'Mengembalikan Data dari Halaman',
        'objective':
            'Memahami cara mengembalikan nilai dari halaman tujuan ke halaman sebelumnya.',
        'sections': [
          'Nilai Kembalian Navigasi',
          'Navigator.pop dengan Data',
          'Menunggu Hasil Navigasi',
          'Menggunakan Hasil',
        ],
        'explanations': [
          'Pemanggilan Navigator.push dapat menghasilkan Future yang selesai ketika halaman tujuan ditutup.',
          'Navigator.pop(context, nilai) menutup halaman sekaligus mengirim nilai kembali kepada halaman sebelumnya.',
          'Kata kunci await digunakan di dalam fungsi async untuk menunggu hasil navigasi sebelum melanjutkan proses.',
          'Nilai yang diterima dapat digunakan untuk memperbarui state, menampilkan notifikasi, atau menandai item sebagai favorit.',
        ],
        'example': r'''
Future<void> bukaDetail() async {
  final hasil = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const DetailPage(),
    ),
  );

  if (!context.mounted) return;

  if (hasil == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil dipilih'),
      ),
    );
  }
}

// Di halaman detail:
// Navigator.pop(context, true);
''',
        'summary':
            'Halaman tujuan dapat mengembalikan nilai melalui Navigator.pop. Halaman sebelumnya menerima hasil melalui Future dari Navigator.push.',
      },
    ],

    'State Management': [
      {
        'title': 'Mengenal State dalam Flutter',
        'objective':
            'Memahami state dan pengaruhnya terhadap tampilan aplikasi.',
        'sections': [
          'Pengertian State',
          'State Lokal',
          'Perubahan State',
          'Kapan State Digunakan',
        ],
        'explanations': [
          'State adalah data yang dapat berubah selama aplikasi berjalan dan memengaruhi tampilan atau perilaku widget.',
          'State lokal adalah data yang dikelola oleh satu widget, misalnya nilai penghitung atau status sebuah formulir.',
          'Ketika state berubah, Flutter perlu diberi tahu agar dapat membangun ulang bagian tampilan yang terpengaruh.',
          'State digunakan untuk fitur interaktif seperti penghitung, pilihan favorit, status tombol, input formulir, dan data yang ditampilkan.',
        ],
        'example': r'''
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Nilai: $counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
''',
        'summary':
            'State menyimpan data yang dapat berubah. Perubahan state perlu diperbarui agar tampilan aplikasi mencerminkan data terbaru.',
      },
      {
        'title': 'setState dan Siklus Widget',
        'objective':
            'Memahami fungsi setState dan pengelolaan sumber daya pada StatefulWidget.',
        'sections': [
          'StatefulWidget',
          'Fungsi setState',
          'initState dan dispose',
          'Mencegah Pembaruan yang Tidak Diperlukan',
        ],
        'explanations': [
          'StatefulWidget terdiri dari konfigurasi widget dan objek State yang mengelola data yang berubah selama widget aktif.',
          'setState memberi tahu Flutter bahwa state berubah sehingga widget dapat dibangun ulang. Perubahan nilai yang memengaruhi UI biasanya dilakukan di dalam callback setState.',
          'initState dipanggil ketika objek State pertama kali diinisialisasi. dispose digunakan untuk membersihkan sumber daya seperti TextEditingController ketika tidak lagi diperlukan.',
          'Simpan hanya data yang diperlukan dan hindari pekerjaan berat di dalam build. Jangan memanggil setState setelah widget sudah tidak terpasang.',
        ],
        'example': r'''
class FormStateExample extends StatefulWidget {
  const FormStateExample({super.key});

  @override
  State<FormStateExample> createState() =>
      _FormStateExampleState();
}

class _FormStateExampleState extends State<FormStateExample> {
  final controller = TextEditingController();
  String nama = '';

  @override
  void initState() {
    super.initState();
    controller.addListener(perbaruiNama);
  }

  void perbaruiNama() {
    setState(() {
      nama = controller.text;
    });
  }

  @override
  void dispose() {
    controller.removeListener(perbaruiNama);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: controller),
        Text('Nama: $nama'),
      ],
    );
  }
}
''',
        'summary':
            'setState memperbarui tampilan berdasarkan perubahan state. initState digunakan untuk inisialisasi, sedangkan dispose membersihkan sumber daya.',
      },
      {
        'title': 'State Bersama dan Data Favorit',
        'objective':
            'Memahami cara berbagi state antarhalaman dan membuat fitur favorit sederhana.',
        'sections': [
          'State Bersama',
          'Set untuk Data Unik',
          'Callback Antarwidget',
          'Memperbarui Daftar Favorit',
        ],
        'explanations': [
          'State bersama adalah data yang digunakan oleh beberapa bagian aplikasi. Untuk aplikasi sederhana, state dapat dikelola oleh widget induk lalu diteruskan ke widget anak.',
          'Set cocok untuk data yang tidak boleh memiliki duplikat. Set<String> dapat digunakan untuk menyimpan kode atau nama item favorit.',
          'Callback seperti ValueChanged<String> memungkinkan widget anak meminta widget induk mengubah data tanpa mengelola salinan state yang terpisah.',
          'Ketika favorit ditambahkan atau dihapus, widget induk memperbarui Set di dalam setState. Halaman yang menerima data tersebut kemudian dapat menampilkan daftar favorit terbaru.',
        ],
        'example': r'''
Set<String> favorites = {};

void toggleFavorite(String course) {
  setState(() {
    if (favorites.contains(course)) {
      favorites.remove(course);
    } else {
      favorites.add(course);
    }
  });
}

// Contoh penghitung favorit:
final totalFavorites = favorites.length;
''',
        'summary':
            'State bersama menjaga data tetap konsisten antarhalaman. Widget induk dapat mengelola favorit dan meneruskan data serta callback kepada widget anak.',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final String title = course['title'] as String? ?? '';
    final List<Map<String, dynamic>> materials =
        courseMaterials[title] ?? [];

    final String code = course['code']?.toString() ?? '-';
    final String credits = course['credits']?.toString() ?? '-';
    final String status = course['status']?.toString() ?? '-';
    final String subtitle = course['subtitle']?.toString() ??
        course['description']?.toString() ??
        'Materi pembelajaran';

    final IconData courseIcon =
        course['icon'] is IconData
            ? course['icon'] as IconData
            : Icons.menu_book;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mata Kuliah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                  Icon(courseIcon, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Informasi Mata Kuliah',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(Icons.code, 'Kode', code),
                    const Divider(height: 24),
                    _infoRow(Icons.school, 'Jumlah SKS', credits),
                    const Divider(height: 24),
                    _infoRow(Icons.flag, 'Status', status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Materi Pembelajaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih materi untuk membaca tujuan pembelajaran, '
              'penjelasan, contoh kode, dan rangkumannya.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 12),

            if (materials.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Materi untuk mata kuliah ini belum tersedia.',
                  ),
                ),
              )
            else
              ...materials.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> material = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      material['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Buka penjelasan materi'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MaterialDetailPage(
                            courseTitle: title,
                            material: material,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

            const SizedBox(height: 24),
            const Text(
              'Informasi Mahasiswa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      Icons.person,
                      'Nama',
                      'Gede Bayu Putra Darmawan',
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      Icons.badge,
                      'NIM',
                      '2415051105',
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      Icons.calendar_month,
                      'Semester',
                      '5',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Pilih / Favorit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeedbackPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.feedback_outlined),
                label: const Text('Berikan Feedback'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Course Explorer • Pembelajaran Flutter',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
