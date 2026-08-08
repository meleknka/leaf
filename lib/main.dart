import 'package:flutter/material.dart';
import 'book.dart';

void main() {
  runApp(const LeafApp());
}

class LeafApp extends StatelessWidget {
  const LeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leaf',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF7F4EA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF71805D),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int todayPages = 0;

  final List<Book> books = [];

  // --------------------------------------------------
  // OKUMA EKLE
  // --------------------------------------------------

  void addReading() {
    final pagesController = TextEditingController();
    final bookController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF4),

          title: const Text(
            'Okuma Ekle',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bookController,
                decoration: const InputDecoration(
                  labelText: 'Kitap adı',
                  hintText: 'Örneğin: Muhteşem Gatsby',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bugün kaç sayfa okudun?',
                  suffixText: 'sayfa',
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),

            FilledButton(
              onPressed: () {
                final bookName = bookController.text.trim();
                final pages = int.tryParse(pagesController.text);

                if (bookName.isEmpty || pages == null || pages <= 0) {
                  return;
                }

                setState(() {
                  todayPages += pages;

                  final existingBook = books.where(
                    (book) =>
                        book.title.toLowerCase() ==
                        bookName.toLowerCase(),
                  );

                  if (existingBook.isNotEmpty) {
                    existingBook.first.readPages += pages;
                  } else {
                    books.add(
                      Book(
                        title: bookName,
                        totalPages: 0,
                        readPages: pages,
                      ),
                    );
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // KİTAP EKLE
  // --------------------------------------------------

  void addBook() {
    final titleController = TextEditingController();
    final totalPagesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF4),

          title: const Text(
            'Yeni Kitap',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Kitap adı',
                  hintText: 'Örneğin: Suç ve Ceza',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: totalPagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Toplam sayfa',
                  suffixText: 'sayfa',
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),

            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final totalPages =
                    int.tryParse(totalPagesController.text);

                if (title.isEmpty ||
                    totalPages == null ||
                    totalPages <= 0) {
                  return;
                }

                final alreadyExists = books.any(
                  (book) =>
                      book.title.toLowerCase() ==
                      title.toLowerCase(),
                );

                if (alreadyExists) {
                  return;
                }

                setState(() {
                  books.add(
                    Book(
                      title: title,
                      totalPages: totalPages,
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Kitabı Ekle'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // ANA EKRAN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          'leaf',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Bugün kaç sayfa okudun?',
              style: TextStyle(
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 28),

            // --------------------------------------------------
            // BUGÜNKÜ OKUMA
            // --------------------------------------------------

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 20,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF4),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: const Color(0xFFE5E0D3),
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    'Bugün',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '$todayPages',

                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Text(
                    'sayfa',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,

                    child: FilledButton(
                      onPressed: addReading,

                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE7ECD9),
                        foregroundColor: const Color(0xFF536246),
                        elevation: 0,
                      ),

                      child: const Text(
                        'Okuma Ekle',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --------------------------------------------------
            // KİTAPLARIM BAŞLIK
            // --------------------------------------------------

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

                IconButton(
                  onPressed: addBook,
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // KİTAP LİSTESİ
            // --------------------------------------------------

            Expanded(
              child: books.isEmpty
                  ? Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EDDF),

                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                          ),

                          SizedBox(width: 14),

                          Text(
                            'Henüz kitap eklenmedi',

                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )

                  : ListView.builder(
                      itemCount: books.length,

                      itemBuilder: (context, index) {
                        final book = books[index];

                        double progress = 0;

                        if (book.totalPages > 0) {
                          progress =
                              book.readPages / book.totalPages;

                          if (progress > 1) {
                            progress = 1;
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EDDF),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_outlined,
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      book.title,

                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Text(
                                '${book.readPages} / ${book.totalPages} sayfa',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 8),

                              LinearProgressIndicator(
                                value: progress,

                                minHeight: 7,

                                backgroundColor:
                                    const Color(0xFFD5DAC9),

                                color:
                                    const Color(0xFF71805D),

                                borderRadius:
                                    BorderRadius.circular(10),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                '${(progress * 100).round()}% tamamlandı',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}