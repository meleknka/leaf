import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = book['name'].toString();

    final totalPages =
        (book['totalPages'] ?? 0) as int;

    final readPages =
        (book['readPages'] ?? 0) as int;

    double progress = 0;

    if (totalPages > 0) {
      progress = readPages / totalPages;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3DBCA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: Color(0xFF647656),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            '$readPages / $totalPages sayfa',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFDDE2D4),
            color: const Color(0xFF7A8E69),
          ),

          const SizedBox(height: 6),

          Text(
            '${(progress * 100).round()}% tamamlandı',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}