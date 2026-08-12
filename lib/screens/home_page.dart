import 'package:flutter/material.dart';

import '../widgets/book_card.dart';
import '../widgets/notebook_page.dart';

class HomePage extends StatelessWidget {
  final int todayPages;
  final List<Map<String, dynamic>> books;

  final VoidCallback onAddBook;
  final VoidCallback onAddReading;
  final VoidCallback onOpenBooks;

  final Future<void> Function(int index) onDeleteBook;

  const HomePage({
    super.key,
    required this.todayPages,
    required this.books,
    required this.onAddBook,
    required this.onAddReading,
    required this.onOpenBooks,
    required this.onDeleteBook,
  });

  @override
  Widget build(BuildContext context) {
    return NotebookPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'leaf',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'okuma defterim',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: onAddBook,
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                  tooltip: 'Yeni kitap ekle',
                ),
              ],
            ),

            const SizedBox(height: 42),

            const Text(
              'Bugün kaç sayfa okudun?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 26,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F0E4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4DCCB),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E9D9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 32,
                      color: Color(0xFF647656),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bugün',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '$todayPages',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Text(
                          'sayfa okudun',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddReading,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C7F5B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Bugünkü Okumayı Ekle',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 44),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kitaplarım',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                TextButton.icon(
                  onPressed: onOpenBooks,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 17,
                  ),
                  label: const Text('Tümü'),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (books.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDDF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Henüz bir kitap eklemedin.',
                ),
              ),

            ...books.asMap().entries.map(
              (entry) {
                return BookCard(
                  book: entry.value,
                  onDelete: () {
                    onDeleteBook(entry.key);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}