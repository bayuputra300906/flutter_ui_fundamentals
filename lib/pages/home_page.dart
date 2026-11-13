import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/kos_service.dart';
import '../services/notification_service.dart';
import '../widgets/role_guard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserProfile> _profileFuture;
  late Future<List<Map<String, dynamic>>> _kosFuture;
  final KosService _kosService = KosService();

  static const Color skyBlue = Color(0xFF0284C7);
  static const Color skyBlueLight = Color(0xFFBAE6FD);
  static const Color skyBlueSurface = Color(0xFFF0F9FF);
  static const Color skyBlueDark = Color(0xFF0369A1);

  @override
  void initState() {
    super.initState();
    _refreshData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.instance.init();
      await NotificationService.instance.setupInteractedMessage();
    });
  }

  void _refreshData() {
    setState(() {
      _profileFuture = ProfileService().getMyProfile();
      _kosFuture = _kosService.fetchAll();
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _toggleRole(UserProfile p) async {
    final next = p.isOwner ? 'seeker' : 'owner';
    await ProfileService().updateRole(next);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Role diubah ke: ${next == "owner" ? "Pemilik Kos" : "Pencari Kos"}'),
      backgroundColor: skyBlue,
    ));
    _refreshData();
  }

  void _sendPromotionNotification(String name, int price) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        '🏠 KosFinder: Kos baru tersedia!\n$name • Rp $price/bulan',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: skyBlue,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(label: 'OK', textColor: Colors.amber, onPressed: () {}),
    ));
  }

  // =========================================================
  // Buka WhatsApp pemilik kos
  // =========================================================
  void _hubungiWhatsApp({
    required String noHp,
    required String kosName,
    required int price,
  }) {
    // Bersihkan nomor HP: hapus semua non-digit, pastikan diawali 62
    final clean = noHp.replaceAll(RegExp(r'[^0-9]'), '');
    final wa = clean.startsWith('0')
        ? '62${clean.substring(1)}'
        : clean.startsWith('62')
            ? clean
            : '62$clean';

    final pesan = Uri.encodeComponent(
      'Halo, saya tertarik dengan kos "$kosName" (Rp $price/bulan) '
      'yang saya lihat di aplikasi KosFinder. Apakah masih tersedia? 🏠',
    );
    final url = 'https://wa.me/$wa?text=$pesan';
    html.window.open(url, '_blank');
  }

  // Dialog pilihan kontak (WhatsApp + Salin nomor)
  void _showKontakDialog(Map<String, dynamic> kos) {
    final noHp = (kos['no_hp'] ?? '').toString();
    final namaPemilik = (kos['nama_pemilik'] ?? 'Pemilik Kos').toString();
    final kosName = (kos['name'] ?? 'Kos').toString();
    final price = kos['price'] ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.contact_phone, color: skyBlue),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Hubungi Pemilik Kos',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info pemilik
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: skyBlueSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: skyBlueLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.person, size: 16, color: skyBlue),
                    const SizedBox(width: 6),
                    Text(namaPemilik,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.home, size: 16, color: skyBlue),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(kosName,
                            style: const TextStyle(fontSize: 13))),
                  ]),
                  if (noHp.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.phone, size: 16, color: skyBlue),
                      const SizedBox(width: 6),
                      Text(noHp,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ],
              ),
            ),

            if (noHp.isEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '⚠️ Pemilik belum mengisi nomor HP.\nCoba hubungi melalui notifikasi.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          // Salin nomor
          if (noHp.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: noHp));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('📋 Nomor HP disalin!'),
                  backgroundColor: skyBlue,
                ));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Salin Nomor'),
              style: TextButton.styleFrom(foregroundColor: skyBlue),
            ),
          // Tutup
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          // WhatsApp
          if (noHp.isNotEmpty)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // warna WA
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _hubungiWhatsApp(
                    noHp: noHp, kosName: kosName, price: price);
              },
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('WhatsApp'),
            ),
        ],
      ),
    );
  }
  // =========================================================
  Widget _buildPhoto(String? url, {double height = 180, String label = 'Foto'}) {
    if (url == null || url.trim().isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 6),
              Text(
                'Belum ada $label',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            color: const Color(0xFFE0F2FE),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (ctx, _, __) => Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 6),
                Text('Gagal memuat $label',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Modal Detail Kos (Foto + Info Lengkap)
  // =========================================================
  void _showKosDetail(Map<String, dynamic> kos, UserProfile p) {
    final isPromoted = kos['is_promoted'] == true;
    final kmDalam = (kos['kamar_mandi'] ?? 'luar') == 'dalam';
    final price = kos['price'] ?? 0;
    final noHp = (kos['no_hp'] ?? '').toString();
    final namaPemilik = (kos['nama_pemilik'] ?? 'Pemilik Kos').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(0),
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---- Header nama & badge ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        kos['name'] ?? 'Kos',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isPromoted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFBBF24)),
                        ),
                        child: const Text('🔥 PROMO',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFFB45309))),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: skyBlue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        kos['address'] ?? '-',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- FOTO KOS (eksterior / tampak depan) ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('📷 Foto Kos (Tampak Luar)'),
                    const SizedBox(height: 8),
                    _buildPhoto(kos['foto_kos'], height: 200, label: 'Foto Kos'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- FOTO KAMAR ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('🛏 Foto Kamar'),
                    const SizedBox(height: 8),
                    _buildPhoto(kos['foto_kamar'], height: 200, label: 'Foto Kamar'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- INFO FASILITAS ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('🏷 Informasi Fasilitas'),
                    const SizedBox(height: 10),
                    // Grid fasilitas
                    Row(
                      children: [
                        _fasilitasChip(
                          icon: kmDalam ? Icons.bathroom : Icons.door_sliding_outlined,
                          label: 'KM ${kmDalam ? "Dalam" : "Luar"}',
                          color: kmDalam ? skyBlue : const Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 8),
                        _fasilitasChip(
                          icon: Icons.payments_outlined,
                          label: 'Rp $price/bln',
                          color: const Color(0xFF059669),
                        ),
                        const SizedBox(width: 8),
                        if (isPromoted)
                          _fasilitasChip(
                            icon: Icons.campaign,
                            label: 'Promo',
                            color: const Color(0xFFD97706),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ---- DESKRIPSI ----
              if ((kos['deskripsi'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('📝 Deskripsi'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: skyBlueSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: skyBlueLight),
                        ),
                        child: Text(
                          kos['deskripsi'],
                          style: TextStyle(
                              color: Colors.grey.shade800, fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ---- KONTAK PEMILIK ----
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('📞 Kontak Pemilik Kos'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: skyBlueLight, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: skyBlue.withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Nama pemilik
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person, color: skyBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nama Pemilik',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    Text(
                                      (kos['nama_pemilik'] ?? '').toString().isNotEmpty
                                          ? kos['nama_pemilik']
                                          : 'Pemilik Kos',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          // Nomor WhatsApp
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.phone, color: Color(0xFF16A34A), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nomor WhatsApp / HP',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    Text(
                                      (kos['no_hp'] ?? '').toString().isNotEmpty
                                          ? kos['no_hp']
                                          : 'Belum diisi pemilik',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: (kos['no_hp'] ?? '').toString().isNotEmpty
                                              ? Colors.black87
                                              : Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol salin nomor
                              if ((kos['no_hp'] ?? '').toString().isNotEmpty)
                                IconButton(
                                  tooltip: 'Salin Nomor',
                                  icon: const Icon(Icons.copy, size: 18, color: skyBlue),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: kos['no_hp']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('📋 Nomor HP disalin!'),
                                        backgroundColor: skyBlue,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          // Tombol WhatsApp
                          if ((kos['no_hp'] ?? '').toString().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  _hubungiWhatsApp(
                                    noHp: kos['no_hp'],
                                    kosName: kos['name'] ?? 'Kos',
                                    price: price,
                                  );
                                },
                                icon: const Icon(Icons.chat, size: 18),
                                label: const Text(
                                  'Chat via WhatsApp',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---- TOMBOL AKSI (Owner: Edit & Promosi) ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: p.isOwner
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: skyBlue,
                                side: const BorderSide(color: skyBlue),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showEditKosDialog(kos);
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Kos'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: skyBlue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _sendPromotionNotification(
                                    kos['name'] ?? 'Kos', price);
                              },
                              icon: const Icon(Icons.campaign, size: 18),
                              label: const Text('Promosikan'),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showKontakDialog(kos);
                          },
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('Hubungi Pemilik via WhatsApp',
                              style: TextStyle(fontSize: 15)),
                        ),
                      ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: skyBlueDark,
        ),
      );

  Widget _fasilitasChip({
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  // =========================================================
  // Dialog Tambah Kos (dengan foto & kamar mandi)
  // =========================================================
  void _showAddKosDialog(UserProfile profile) {
    final nameC = TextEditingController();
    final addressC = TextEditingController();
    final priceC = TextEditingController();
    final fotoKosC = TextEditingController();
    final fotoKamarC = TextEditingController();
    final deskripsiC = TextEditingController();
    final noHpC = TextEditingController();
    final namaPemilikC = TextEditingController();
    String kamarMandi = 'dalam';
    bool sendPromo = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => StatefulBuilder(
          builder: (context, setModalState) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                const Row(
                  children: [
                    Icon(Icons.add_home, color: skyBlue, size: 26),
                    SizedBox(width: 10),
                    Text('Tambah & Promosikan Kos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),

                // Nama
                _buildFormField(
                  controller: nameC,
                  label: 'Nama Kos',
                  hint: 'Contoh: Kos Melati Kampus Undiksha',
                  icon: Icons.business,
                ),
                const SizedBox(height: 12),

                // Alamat
                _buildFormField(
                  controller: addressC,
                  label: 'Alamat Lengkap',
                  hint: 'Contoh: Jl. Udayana No. 12, Singaraja',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 12),

                // Harga
                _buildFormField(
                  controller: priceC,
                  label: 'Harga Sewa / Bulan (Rp)',
                  hint: 'Contoh: 750000',
                  icon: Icons.payments,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Deskripsi
                _buildFormField(
                  controller: deskripsiC,
                  label: 'Deskripsi Kos',
                  hint:
                      'Fasilitas, kondisi, keunggulan kos Anda...',
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Kontak Pemilik
                const Text('📞 Kontak Pemilik (untuk Pencari Kos)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _buildFormField(
                  controller: namaPemilikC,
                  label: 'Nama Pemilik Kos',
                  hint: 'Contoh: Pak Wayan Sudarsana',
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),
                _buildFormField(
                  controller: noHpC,
                  label: 'Nomor WhatsApp / HP',
                  hint: 'Contoh: 08123456789 atau 6281234567890',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Kamar Mandi
                const Text('🚿 Kamar Mandi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _kmOption(
                        label: 'Dalam Kamar',
                        icon: Icons.bathroom,
                        selected: kamarMandi == 'dalam',
                        onTap: () =>
                            setModalState(() => kamarMandi = 'dalam'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kmOption(
                        label: 'Di Luar (Shared)',
                        icon: Icons.door_sliding_outlined,
                        selected: kamarMandi == 'luar',
                        onTap: () =>
                            setModalState(() => kamarMandi = 'luar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Foto Kos URL
                const Text('📷 Foto Kos (URL Gambar)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Paste link foto dari Google Drive, Imgur, dll.\nContoh: https://i.imgur.com/xxx.jpg',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                _buildFormField(
                  controller: fotoKosC,
                  label: 'URL Foto Tampak Luar Kos',
                  hint: 'https://i.imgur.com/foto-kos.jpg',
                  icon: Icons.add_photo_alternate,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),

                // Preview foto kos
                StatefulBuilder(
                  builder: (_, setPreview) => Column(
                    children: [
                      if (fotoKosC.text.isNotEmpty)
                        _buildPhoto(fotoKosC.text, height: 140, label: 'Foto Kos'),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setPreview(() {}),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Preview', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: skyBlue),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Foto Kamar URL
                const Text('🛏 Foto Kamar (URL Gambar)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _buildFormField(
                  controller: fotoKamarC,
                  label: 'URL Foto Bagian Dalam Kamar',
                  hint: 'https://i.imgur.com/foto-kamar.jpg',
                  icon: Icons.bed,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),

                // Preview foto kamar
                StatefulBuilder(
                  builder: (_, setPreview) => Column(
                    children: [
                      if (fotoKamarC.text.isNotEmpty)
                        _buildPhoto(fotoKamarC.text,
                            height: 140, label: 'Foto Kamar'),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setPreview(() {}),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Preview', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: skyBlue),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Switch Promosi
                Container(
                  decoration: BoxDecoration(
                    color: skyBlueSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: skyBlueLight),
                  ),
                  child: SwitchListTile(
                    title: const Text('Kirim Push Notification Promosi 📢'),
                    subtitle: const Text(
                      'Pencari kos menerima notifikasi kos baru tersedia',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: sendPromo,
                    activeTrackColor: skyBlue,
                    onChanged: (val) =>
                        setModalState(() => sendPromo = val),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol Simpan
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: skyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final name = nameC.text.trim();
                    final addr = addressC.text.trim();
                    final price = int.tryParse(priceC.text.trim()) ?? 0;

                    if (name.isEmpty || addr.isEmpty || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Nama, alamat, dan harga wajib diisi!')));
                      return;
                    }

                    Navigator.pop(ctx);
                    await _kosService.add(
                      name: name,
                      address: addr,
                      price: price,
                      isPromoted: sendPromo,
                      kamarMandi: kamarMandi,
                      fotoKos: fotoKosC.text.trim(),
                      fotoKamar: fotoKamarC.text.trim(),
                      deskripsi: deskripsiC.text.trim(),
                      noHp: noHpC.text.trim(),
                      namaPemilik: namaPemilikC.text.trim(),
                    );
                    if (sendPromo) _sendPromotionNotification(name, price);
                    _refreshData();
                  },
                  icon: const Icon(Icons.publish),
                  label: const Text('Simpan & Promosikan Kos',
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Dialog Edit Kos (dengan foto & kamar mandi)
  // =========================================================
  void _showEditKosDialog(Map<String, dynamic> kos) {
    final nameC = TextEditingController(text: kos['name'] ?? '');
    final addressC = TextEditingController(text: kos['address'] ?? '');
    final priceC = TextEditingController(text: (kos['price'] ?? 0).toString());
    final fotoKosC = TextEditingController(text: kos['foto_kos'] ?? '');
    final fotoKamarC = TextEditingController(text: kos['foto_kamar'] ?? '');
    final deskripsiC = TextEditingController(text: kos['deskripsi'] ?? '');
    final noHpC = TextEditingController(text: kos['no_hp'] ?? '');
    final namaPemilikC = TextEditingController(text: kos['nama_pemilik'] ?? '');
    String kamarMandi = kos['kamar_mandi'] ?? 'luar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => StatefulBuilder(
          builder: (context, setModalState) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.edit, color: skyBlue, size: 24),
                    SizedBox(width: 10),
                    Text('Edit Informasi Kos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFormField(
                    controller: nameC, label: 'Nama Kos', icon: Icons.business),
                const SizedBox(height: 12),
                _buildFormField(
                    controller: addressC,
                    label: 'Alamat',
                    icon: Icons.location_on),
                const SizedBox(height: 12),
                _buildFormField(
                    controller: priceC,
                    label: 'Harga (Rp)',
                    icon: Icons.payments,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildFormField(
                    controller: deskripsiC,
                    label: 'Deskripsi',
                    icon: Icons.notes,
                    maxLines: 3),
                const SizedBox(height: 16),
                const Text('📞 Kontak Pemilik',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _buildFormField(
                    controller: namaPemilikC,
                    label: 'Nama Pemilik',
                    icon: Icons.person),
                const SizedBox(height: 10),
                _buildFormField(
                    controller: noHpC,
                    label: 'Nomor WhatsApp / HP',
                    hint: 'Contoh: 08123456789',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                const Text('🚿 Kamar Mandi',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _kmOption(
                        label: 'Dalam Kamar',
                        icon: Icons.bathroom,
                        selected: kamarMandi == 'dalam',
                        onTap: () =>
                            setModalState(() => kamarMandi = 'dalam'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _kmOption(
                        label: 'Di Luar (Shared)',
                        icon: Icons.door_sliding_outlined,
                        selected: kamarMandi == 'luar',
                        onTap: () =>
                            setModalState(() => kamarMandi = 'luar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('📷 URL Foto Kos',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _buildFormField(
                    controller: fotoKosC,
                    label: 'URL Foto Tampak Luar',
                    icon: Icons.add_photo_alternate,
                    keyboardType: TextInputType.url),
                const SizedBox(height: 4),
                if (fotoKosC.text.isNotEmpty)
                  _buildPhoto(fotoKosC.text, height: 130),
                const SizedBox(height: 14),
                const Text('🛏 URL Foto Kamar',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _buildFormField(
                    controller: fotoKamarC,
                    label: 'URL Foto Bagian Dalam Kamar',
                    icon: Icons.bed,
                    keyboardType: TextInputType.url),
                const SizedBox(height: 4),
                if (fotoKamarC.text.isNotEmpty)
                  _buildPhoto(fotoKamarC.text, height: 130),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: skyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _kosService.update(kos['id'].toString(), {
                      'name': nameC.text.trim(),
                      'address': addressC.text.trim(),
                      'price': int.tryParse(priceC.text.trim()) ?? kos['price'],
                      'kamar_mandi': kamarMandi,
                      'foto_kos': fotoKosC.text.trim(),
                      'foto_kamar': fotoKamarC.text.trim(),
                      'deskripsi': deskripsiC.text.trim(),
                      'no_hp': noHpC.text.trim(),
                      'nama_pemilik': namaPemilikC.text.trim(),
                    });
                    _refreshData();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Perubahan',
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: TextField seragam
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: skyBlue, width: 2),
          ),
          prefixIcon: Icon(icon, color: skyBlue),
          filled: true,
          fillColor: Colors.white,
        ),
      );

  // Helper: opsi kamar mandi
  Widget _kmOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? skyBlue : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? skyBlue : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey.shade600, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // =========================================================
  // BUILD UTAMA
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final p = snap.data ??
            const UserProfile(
              id: 'owner-default',
              email: 'bayuputra.owner@gmail.com',
              name: 'Gede Bayu Putra Darmawan',
              role: 'owner',
            );

        final myUid = AuthService.instance.currentUser?.id ?? '';

        return Scaffold(
          backgroundColor: skyBlueSurface,
          appBar: AppBar(
            backgroundColor: skyBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Row(
              children: [
                Icon(Icons.apartment, size: 22),
                SizedBox(width: 8),
                Text('KosFinder',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: p.isOwner ? 'Ubah ke Seeker' : 'Ubah ke Owner',
                icon: const Icon(Icons.swap_horiz, size: 26),
                onPressed: () => _toggleRole(p),
              ),
              IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout),
                  onPressed: _logout),
            ],
          ),
          body: RefreshIndicator(
            color: skyBlue,
            onRefresh: () async => _refreshData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ---- Kartu Profil ----
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: skyBlueLight, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: skyBlue,
                          child: Icon(
                            p.isOwner ? Icons.home_work : Icons.person_search,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name.isNotEmpty
                                    ? p.name
                                    : p.email.split('@').first,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${p.email} • ${p.role}',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: skyBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p.isOwner ? 'Pemilik Kos' : 'Pencari Kos',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ---- Banner Promosi (Owner) ----
                if (p.isOwner || p.isAdmin) ...[
                  Card(
                    color: const Color(0xFFE0F2FE),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: skyBlueLight),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.campaign,
                          color: skyBlue, size: 32),
                      title: const Text('Promosikan Kos Anda! 📢',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: skyBlue)),
                      subtitle: const Text(
                          'Kirim notifikasi ke semua pencari kos.',
                          style: TextStyle(fontSize: 12)),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: skyBlue),
                        onPressed: () => _sendPromotionNotification(
                            'Kos Pondok Mahasiswa', 700000),
                        child: const Text('Tes Promo'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ---- Header Daftar Kos ----
                Row(
                  children: [
                    const Icon(Icons.apartment, color: skyBlue, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Daftar Kos Sekitar Kampus',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: skyBlueDark,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Muat ulang',
                      icon: const Icon(Icons.refresh, color: skyBlue),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ---- FutureBuilder Kos ----
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _kosFuture,
                  builder: (context, kosSnap) {
                    if (kosSnap.connectionState != ConnectionState.done) {
                      return const Center(
                          child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator()));
                    }

                    final items = kosSnap.data ?? [];
                    if (items.isEmpty) {
                      return Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.home_work_outlined,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  p.isOwner
                                      ? 'Belum ada kos. Tambahkan kos Anda!'
                                      : 'Belum ada kos terdaftar.',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final kos = items[i];
                        final isMine = p.isOwner ||
                            (kos['owner_id'] != null &&
                                kos['owner_id'] == myUid);
                        final isPromoted = kos['is_promoted'] == true;
                        final price = kos['price'] ?? 0;
                        final kmDalam =
                            (kos['kamar_mandi'] ?? 'luar') == 'dalam';
                        final fotoKos = kos['foto_kos'] as String? ?? '';

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                                color: skyBlueLight, width: 1.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showKosDetail(kos, p),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ---- Foto Thumbnail ----
                                Stack(
                                  children: [
                                    _buildPhoto(
                                      fotoKos.isNotEmpty ? fotoKos : null,
                                      height: 170,
                                      label: 'Foto Kos',
                                    ),
                                    // Badge PROMO
                                    if (isPromoted)
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFFBBF24)),
                                          ),
                                          child: const Text('🔥 PROMO',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                  color: Color(0xFFB45309))),
                                        ),
                                      ),
                                    // Badge KM
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kmDalam
                                              ? skyBlue
                                              : const Color(0xFF7C3AED),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              kmDalam
                                                  ? Icons.bathroom
                                                  : Icons.door_sliding_outlined,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'KM ${kmDalam ? "Dalam" : "Luar"}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Overlay "Tap untuk detail"
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withAlpha(140),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        alignment: Alignment.bottomCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 6),
                                        child: const Text(
                                          'Tap untuk lihat foto & detail lengkap',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // ---- Info Kos ----
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        kos['name'] ?? 'Kos',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 13,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              kos['address'] ?? '-',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.payments_outlined,
                                              size: 15, color: skyBlue),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rp $price',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: skyBlue),
                                          ),
                                          const Text(' / bulan',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                          const Spacer(),
                                          if (isMine) ...[
                                            IconButton(
                                              tooltip: 'Promosikan',
                                              icon: const Icon(Icons.campaign,
                                                  color: skyBlue, size: 20),
                                              onPressed: () =>
                                                  _sendPromotionNotification(
                                                      kos['name'] ?? 'Kos',
                                                      price),
                                            ),
                                            IconButton(
                                              tooltip: 'Edit',
                                              icon: const Icon(Icons.edit,
                                                  color: skyBlue, size: 20),
                                              onPressed: () =>
                                                  _showEditKosDialog(kos),
                                            ),
                                            IconButton(
                                              tooltip: 'Hapus',
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 20),
                                              onPressed: () async {
                                                await _kosService.delete(
                                                    kos['id'].toString());
                                                _refreshData();
                                              },
                                            ),
                                          ] else
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                  backgroundColor: skyBlue),
                                              onPressed: () =>
                                                  _showKosDetail(kos, p),
                                              child:
                                                  const Text('Lihat Detail'),
                                            ),                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              backgroundColor: skyBlue,
              foregroundColor: Colors.white,
              onPressed: () => _showAddKosDialog(p),
              icon: const Icon(Icons.add_home),
              label: const Text('Tambah Kos'),
            ),
          ),
        );
      },
    );
  }
}
