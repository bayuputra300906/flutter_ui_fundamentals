import 'package:flutter/material.dart';
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

  // Sky Blue theme colors
  static const Color skyBlue = Color(0xFF0284C7);
  static const Color skyBlueLight = Color(0xFFBAE6FD);
  static const Color skyBlueSurface = Color(0xFFF0F9FF);

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

  // Fungsi untuk mengganti role akun secara cepat (Pengujian Seeker vs Owner)
  Future<void> _toggleRole(UserProfile currentProfile) async {
    final nextRole = currentProfile.isOwner ? 'seeker' : 'owner';
    await ProfileService().updateRole(nextRole);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Role berhasil diubah menjadi: ${nextRole == "owner" ? "Pemilik Kos (owner)" : "Pencari Kos (seeker)"}',
        ),
        backgroundColor: skyBlue,
      ),
    );
    _refreshData();
  }

  // Kirim broadcast push notification promosi kos
  void _sendPromotionNotification(String kosTitle, int price) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🏠 KosFinder Broadcast:\nKos baru tersedia di sekitar kampus!\n$kosTitle • Rp $price/bulan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: skyBlue,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.amber,
          onPressed: () {},
        ),
      ),
    );
  }

  // Dialog Tambah Kos untuk Pemilik Kos (Owner)
  void _showAddKosDialog(UserProfile profile) {
    final nameC = TextEditingController();
    final addressC = TextEditingController();
    final priceC = TextEditingController();
    bool sendPromo = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_home, color: skyBlue, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Tambah & Promosikan Kos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kos',
                      hintText: 'Contoh: Kos Melati Kampus Undiksha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressC,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Kos',
                      hintText: 'Contoh: Jl. Udayana No. 12, Singaraja',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Sewa / Bulan (Rp)',
                      hintText: 'Contoh: 750000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Kirim Push Notification Promosi 📢'),
                    subtitle: const Text(
                      'Pencari kos akan menerima notifikasi "Kos baru tersedia di sekitar kampus"',
                    ),
                    value: sendPromo,
                    activeColor: skyBlue,
                    onChanged: (val) => setModalState(() => sendPromo = val),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final name = nameC.text.trim();
                      final addr = addressC.text.trim();
                      final price = int.tryParse(priceC.text.trim()) ?? 0;

                      if (name.isEmpty || addr.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lengkapi form dengan valid')),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      await _kosService.add(
                        name: name,
                        address: addr,
                        price: price,
                        isPromoted: sendPromo,
                      );

                      if (sendPromo) {
                        _sendPromotionNotification(name, price);
                      }

                      _refreshData();
                    },
                    icon: const Icon(Icons.publish),
                    label: const Text('Simpan & Promosikan Kos'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Dialog Edit Kos (Hanya untuk Owner)
  void _showEditKosDialog(Map<String, dynamic> kos) {
    final nameC = TextEditingController(text: kos['name'] ?? '');
    final addressC = TextEditingController(text: kos['address'] ?? '');
    final priceC = TextEditingController(text: (kos['price'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Informasi Kos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama Kos'),
            ),
            TextField(
              controller: addressC,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            TextField(
              controller: priceC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga (Rp)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _kosService.update(kos['id'].toString(), {
                'name': nameC.text.trim(),
                'address': addressC.text.trim(),
                'price': int.tryParse(priceC.text.trim()) ?? kos['price'],
              });
              _refreshData();
            },
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Karena ProfileService.getMyProfile() selalu return non-null,
        // snap.data pasti ada. Fallback ke default owner jika terjadi hal tak terduga.
        final p = snap.data ??
            const UserProfile(
              id: 'owner-default-bayu',
              email: 'bayuputra.owner@gmail.com',
              name: 'Gede Bayu Putra Darmawan',
              role: 'owner',
            );

        final myUid = AuthService.instance.currentUser?.id ?? '';
        final roleLabel = p.isOwner ? 'Pemilik Kos' : 'Pencari Kos';
        final roleIcon = p.isOwner ? Icons.home_work : Icons.person_search;

        return Scaffold(
          backgroundColor: skyBlueSurface,
          appBar: AppBar(
            backgroundColor: skyBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.apartment, size: 22),
                const SizedBox(width: 8),
                Text(
                  'KosFinder',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
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
                onPressed: _logout,
              ),
            ],
          ),
          body: RefreshIndicator(
            color: skyBlue,
            onRefresh: () async => _refreshData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // =====================================================
                // 1. Kartu Profil & Role Pengguna
                // =====================================================
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: p.isOwner ? skyBlue.withOpacity(0.6) : skyBlueLight,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: skyBlue,
                              child: Icon(
                                roleIcon,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name.isNotEmpty ? p.name : p.email.split('@').first,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${p.email} • ${p.role}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Badge role
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: skyBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    p.isOwner ? Icons.badge : Icons.search,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    roleLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: skyBlueSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 15,
                                color: skyBlue,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p.isOwner
                                      ? 'Hak Akses: Tambah kos, edit, hapus, dan kirim promosi push notification.'
                                      : 'Hak Akses: Lihat daftar kos dan hubungi pengelola.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _toggleRole(p),
                                style: TextButton.styleFrom(
                                  foregroundColor: skyBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: Text(
                                  p.isOwner ? 'Ubah ke Seeker' : 'Ubah ke Owner',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =====================================================
                // 2. Banner Promosi (Khusus Owner)
                // =====================================================
                if (p.isOwner || p.isAdmin) ...[
                  Card(
                    color: const Color(0xFFE0F2FE), // sky-100
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: skyBlueLight, width: 1.2),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.campaign, color: skyBlue, size: 34),
                      title: const Text(
                        'Promosikan Kos Anda! 📢',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: skyBlue,
                        ),
                      ),
                      subtitle: const Text(
                        'Kirim notifikasi broadcast ke seluruh pencari kos.',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: skyBlue,
                        ),
                        onPressed: () => _sendPromotionNotification(
                          'Kos Pondok Mahasiswa Undiksha',
                          700000,
                        ),
                        child: const Text('Tes Promosi'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // =====================================================
                // 3. Header Daftar Kos
                // =====================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apartment, color: skyBlue, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Daftar Kos Sekitar Kampus',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0369A1), // sky-700
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Muat ulang data',
                      icon: const Icon(Icons.refresh, color: skyBlue),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // =====================================================
                // 4. FutureBuilder Daftar Kos
                // =====================================================
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _kosFuture,
                  builder: (context, kosSnap) {
                    if (kosSnap.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
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
                                Icon(
                                  Icons.home_work_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  p.isOwner
                                      ? 'Belum ada kos terdaftar.\nKlik tombol "+ Tambah Kos" di bawah.'
                                      : 'Belum ada kos terdaftar saat ini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final kos = items[i];
                        // Owner bisa kelola semua kos (untuk demo/pengujian)
                        final isMine = p.isOwner ||
                            (kos['owner_id'] != null && kos['owner_id'] == myUid);
                        final isPromoted = kos['is_promoted'] == true;
                        final price = kos['price'] ?? 0;

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: skyBlueLight,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.apartment,
                                        color: skyBlue,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kos['name'] ?? 'Kos Tanpa Nama',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 13,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  kos['address'] ?? '-',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isPromoted)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFFFBBF24),
                                          ),
                                        ),
                                        child: const Text(
                                          '🔥 PROMO',
                                          style: TextStyle(
                                            color: Color(0xFFB45309),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(height: 20, color: skyBlueLight),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.payments_outlined,
                                      size: 16,
                                      color: skyBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Rp $price',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: skyBlue,
                                      ),
                                    ),
                                    const Text(
                                      ' / bulan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Tombol aksi sesuai role
                                    if (isMine) ...[
                                      IconButton(
                                        tooltip: 'Kirim Promosi',
                                        icon: const Icon(
                                          Icons.campaign,
                                          color: skyBlue,
                                        ),
                                        onPressed: () => _sendPromotionNotification(
                                          kos['name'] ?? 'Kos',
                                          price,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit Kos',
                                        icon: const Icon(
                                          Icons.edit,
                                          color: skyBlue,
                                        ),
                                        onPressed: () => _showEditKosDialog(kos),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus Kos',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await _kosService.delete(
                                            kos['id'].toString(),
                                          );
                                          _refreshData();
                                        },
                                      ),
                                    ] else ...[
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: skyBlue,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Menghubungi pengelola: ${kos['name']}',
                                              ),
                                              backgroundColor: skyBlue,
                                            ),
                                          );
                                        },
                                        child: const Text('Hubungi Kos'),
                                      ),
                                    ],
                                  ],
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
          // Tombol "+ Tambah Kos" HANYA untuk Owner (RoleGuard)
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
