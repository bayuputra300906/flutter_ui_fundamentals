import 'package:flutter/material.dart';

class CourseMenuItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String credits;
  final String status;
  final VoidCallback onTap;

  const CourseMenuItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.credits,
    required this.status,
    required this.onTap,
  });

  @override
  State<CourseMenuItem> createState() => _CourseMenuItemState();
}

class _CourseMenuItemState extends State<CourseMenuItem> {
  // State untuk menentukan apakah mata kuliah favorite
  bool isFavorite = false;

  // ==========================================================
  // LONG PRESS
  // ==========================================================

  void showCourseInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.title),
          content: Text(
            '${widget.subtitle}\n\n'
            'SKS: ${widget.credits}\n'
            'Status: ${widget.status}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ======================================================
      // GESTURE: LONG PRESS
      // ======================================================
      onLongPress: showCourseInfo,

      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          // ==================================================
          // INKWELL: TAP CARD
          // ==================================================
          onTap: widget.onTap,

          borderRadius: BorderRadius.circular(18),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Row(
              children: [
                // ==================================================
                // ICON MATA KULIAH
                // ==================================================

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                // ==================================================
                // INFORMASI MATA KULIAH
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Row(
                        children: [
                          // SKS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.iconColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.credits,
                              style: TextStyle(
                                color: widget.iconColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // STATUS
                          Text(
                            widget.status,
                            style: TextStyle(
                              color: widget.status == 'Selesai'
                                  ? Colors.green
                                  : widget.status == 'Aktif'
                                      ? Colors.orange
                                      : Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // FAVORITE BUTTON
                // ==================================================

                IconButton(
                  tooltip: isFavorite
                      ? 'Hapus dari favorite'
                      : 'Tambah ke favorite',

                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        duration:
                            const Duration(seconds: 1),
                        content: Text(
                          isFavorite
                              ? '${widget.title} ditambahkan ke favorite.'
                              : '${widget.title} dihapus dari favorite.',
                        ),
                      ),
                    );
                  },

                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),

                // ==================================================
                // ARROW
                // ==================================================

                const Icon(
                  Icons.chevron_right,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}