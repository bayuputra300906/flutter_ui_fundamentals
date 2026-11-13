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
  late Future<UserProfile?> _profileFuture;
  late Future<List<Map<String, dynamic>>> _kosFuture;
  final KosService _kosService = KosService();

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
        backgroundColor: nextRole == 'owner' ? Colors.deepOrange : Colors.indigo,
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
        backgroundColor: Colors.indigo,
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
                      const Icon(Icons.add_home, color: Colors.indigo, size: 28),
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
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final p = snap.data;
        if (snap.hasError || p == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat profil pengguna'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Kembali ke Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final myUid = AuthService.instance.currentUser?.id ?? '';
        final roleLabel = p.isOwner ? 'Pemilik Kos (owner)' : 'Pencari Kos (seeker)';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Text(
              'KosFinder (${p.role})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Ganti Role Cepat (${p.isOwner ? "Ubah ke Seeker" : "Ubah ke Owner"})',
                icon: const Icon(Icons.swap_horiz, size: 28),
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
            onRefresh: () async => _refreshData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Kartu Informasi Akun & Hak Akses Role
                Card(
                  elevation: 2,
                  color: p.isOwner ? Colors.orange.shade50 : Colors.indigo.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: p.isOwner ? Colors.orange.shade200 : Colors.indigo.shade200,
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
                              radius: 24,
                              backgroundColor: p.isOwner ? Colors.deepOrange : Colors.indigo,
                              child: Icon(
                                p.isOwner ? Icons.home_work : Icons.person_search,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name.isEmpty ? p.email : p.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    p.email,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Chip(
                              avatar: Icon(
                                p.isOwner ? Icons.badge : Icons.search,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                roleLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor:
                                  p.isOwner ? Colors.deepOrange : Colors.indigo,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _toggleRole(p),
                              icon: const Icon(Icons.switch_account, size: 18),
                              label: Text(
                                p.isOwner ? 'Ubah ke Seeker' : 'Ubah ke Owner',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          p.isOwner
                              ? 'Hak Akses Owner: Anda dapat menambah properti kos, mengedit kos Anda, dan membuat push notification promosi.'
                              : 'Hak Akses Seeker: Anda dapat melihat daftar kos dan fitur pencarian. Tombol kelola/tambah kos disembunyikan untuk Anda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Banner Promosi Khusus Owner
                if (p.isOwner || p.isAdmin) ...[
                  Card(
                    color: Colors.amber.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.campaign, color: Colors.deepOrange, size: 34),
                      title: const Text(
                        'Pasarkan Kos Anda Sekarang! 📢',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Kirim notifikasi broadcast ke seluruh calon pencari kos.',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () => _sendPromotionNotification(
                          'Kos Pondok Mahasiswa Undiksha',
                          700000,
                        ),
                        child: const Text('Tes Promosi'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Header Daftar Kos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Kos Sekitar Kampus 🏠',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      tooltip: 'Muat ulang data',
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 4. List of Kos Cards
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
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Belum ada kos terdaftar.\nJika Anda Owner, klik tombol "+ Tambah Kos" di bawah.',
                              textAlign: TextAlign.center,
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
                        final isMine = (kos['owner_id'] == myUid) || (p.isOwner && i == 0);
                        final isPromoted = kos['is_promoted'] == true;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                                        color: Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.apartment, color: Colors.indigo),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kos['name'] ?? 'Kos Tanpa Nama',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            kos['address'] ?? '-',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
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
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '🔥 PROMOSI',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    Text(
                                      'Rp ${kos['price'] ?? 0}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const Text(' / bulan', style: TextStyle(fontSize: 12)),
                                    const Spacer(),
                                    // Aksi sesuai role & ownership
                                    if (isMine && p.isOwner) ...[
                                      IconButton(
                                        tooltip: 'Promosikan Kos',
                                        icon: const Icon(Icons.campaign, color: Colors.deepOrange),
                                        onPressed: () => _sendPromotionNotification(
                                          kos['name'] ?? 'Kos',
                                          kos['price'] ?? 0,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit Kos',
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditKosDialog(kos),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus Kos',
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          await _kosService.delete(kos['id'].toString());
                                          _refreshData();
                                        },
                                      ),
                                    ] else ...[
                                      FilledButton.tonal(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Menghubungi pengelola: ${kos['name']}',
                                              ),
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
