import 'package:flutter/material.dart';

import '../widgets/book_card.dart';
import '../widgets/notebook_page.dart';

class BooksPage extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final VoidCallback onAddBook;
  final Future<void> Function(int index) onDeleteBook;

  const BooksPage({
    super.key,
    required this.books,
    required this.onAddBook,
    required this.onDeleteBook,
  });

  @override
  Widget build(BuildContext context) {
    return NotebookPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kitaplarım',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Okuduğun kitapları burada tut.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddBook,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Kitap Ekle'),
              ),
            ),

            const SizedBox(height: 22),

            if (books.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDDF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Henüz kitap eklemedin.',
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