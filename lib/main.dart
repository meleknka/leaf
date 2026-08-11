import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LeafApp());
}

class LeafApp extends StatelessWidget {
  const LeafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667A55),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F4EC),
      ),
      home: const LeafHomePage(),
    );
  }
}

class LeafHomePage extends StatefulWidget {
  const LeafHomePage({super.key});

  @override
  State<LeafHomePage> createState() => _LeafHomePageState();
}

class _LeafHomePageState extends State<LeafHomePage> {
  int selectedPage = 0;

  int todayPages = 0;

  List<Map<String, dynamic>> books = [];

  Map<String, int> readingHistory = {};

  // Her okuma kaydı:
  // {
  //   "date": "2026-08-12",
  //   "book": "Muhteşem Gatsby",
  //   "pages": 25
  // }
  List<Map<String, dynamic>> readingRecords = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ============================================================
  // VERİLERİ YÜKLE
  // ============================================================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBooks = prefs.getString('leaf_books');
    final savedHistory = prefs.getString('leaf_history');
    final savedRecords = prefs.getString('leaf_reading_records');

    if (savedBooks != null) {
      final decodedBooks = jsonDecode(savedBooks);

      books = List<Map<String, dynamic>>.from(
        decodedBooks.map(
          (book) => Map<String, dynamic>.from(book),
        ),
      );
    }

    if (savedHistory != null) {
      final decodedHistory = jsonDecode(savedHistory);

      readingHistory = Map<String, int>.from(
        decodedHistory.map(
          (key, value) => MapEntry(
            key.toString(),
            int.parse(value.toString()),
          ),
        ),
      );
    }

    if (savedRecords != null) {
      final decodedRecords = jsonDecode(savedRecords);

      readingRecords = List<Map<String, dynamic>>.from(
        decodedRecords.map(
          (record) => Map<String, dynamic>.from(record),
        ),
      );
    }

    updateTodayPages();

    setState(() {});
  }

  // ============================================================
  // VERİLERİ KAYDET
  // ============================================================

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'leaf_books',
      jsonEncode(books),
    );

    await prefs.setString(
      'leaf_history',
      jsonEncode(readingHistory),
    );

    await prefs.setString(
      'leaf_reading_records',
      jsonEncode(readingRecords),
    );
  }

  // ============================================================
  // BUGÜNÜN TARİHİ
  // ============================================================

  String todayKey() {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void updateTodayPages() {
    todayPages = readingHistory[todayKey()] ?? 0;
  }

  // ============================================================
  // OKUMA EKLE
  // ============================================================

  Future<void> addReading() async {
    // Eğer hiç kitap yoksa önce kitap eklememiz gerekiyor.
    if (books.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Önce bir kitap ekleyelim 📚'),
            content: const Text(
              'Okuma ekleyebilmek için önce Kitaplarım bölümünden bir kitap eklemelisin.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );

      return;
    }

    String? selectedBook;
    final pagesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFCF5),

              title: const Text(
                'Okuma Ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hangi kitabı okuyorsun?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // KİTAP SEÇİMİ
                  // ------------------------------------------------

                  DropdownButtonFormField<String>(
                    initialValue: selectedBook,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Kitap seç',
                    ),

                    items: books.map((book) {
                      return DropdownMenuItem<String>(
                        value: book['name'].toString(),
                        child: Text(
                          book['name'].toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setDialogState(() {
                        selectedBook = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Bugün kaç sayfa okudun?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: pagesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Örneğin: 25',
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
                  onPressed: () async {
                    final pages =
                        int.tryParse(pagesController.text);

                    if (selectedBook == null ||
                        pages == null ||
                        pages <= 0) {
                      return;
                    }

                    final date = todayKey();

                    // ----------------------------------------------
                    // GÜNLÜK TOPLAMA EKLE
                    // ----------------------------------------------

                    readingHistory[date] =
                        (readingHistory[date] ?? 0) + pages;

                    // ----------------------------------------------
                    // KİTABA OKUNAN SAYFALARI EKLE
                    // ----------------------------------------------

                    final bookIndex = books.indexWhere(
                      (book) =>
                          book['name'].toString() ==
                          selectedBook,
                    );

                    if (bookIndex != -1) {
                      final currentReadPages =
                          (books[bookIndex]['readPages'] ?? 0)
                              as int;

                      final totalPages =
                          (books[bookIndex]['totalPages'] ?? 0)
                              as int;

                      int newReadPages =
                          currentReadPages + pages;

                      // Toplam sayfayı aşmasın.
                      if (totalPages > 0 &&
                          newReadPages > totalPages) {
                        newReadPages = totalPages;
                      }

                      books[bookIndex]['readPages'] =
                          newReadPages;
                    }

                    // ----------------------------------------------
                    // AYRICA AYRI OKUMA KAYDI OLUŞTUR
                    // ----------------------------------------------

                    readingRecords.add({
                      'date': date,
                      'book': selectedBook,
                      'pages': pages,
                    });

                    updateTodayPages();

                    await saveData();

                    setState(() {});

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },

                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    pagesController.dispose();
  }

  // ============================================================
  // KİTAP EKLE
  // ============================================================

  Future<void> addBook() async {
    final nameController = TextEditingController();
    final pagesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCF5),

          title: const Text(
            'Yeni Kitap',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Kitap adı',
                  hintText: 'Örneğin: Muhteşem Gatsby',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Toplam sayfa',
                  hintText: 'Örneğin: 208',
                  border: OutlineInputBorder(),
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
              onPressed: () async {
                final name = nameController.text.trim();

                final totalPages =
                    int.tryParse(pagesController.text);

                if (name.isEmpty ||
                    totalPages == null ||
                    totalPages <= 0) {
                  return;
                }

                // Aynı kitap daha önce eklenmiş mi?
                final alreadyExists = books.any(
                  (book) =>
                      book['name']
                          .toString()
                          .toLowerCase() ==
                      name.toLowerCase(),
                );

                if (alreadyExists) {
                  return;
                }

                books.add({
                  'name': name,
                  'totalPages': totalPages,
                  'readPages': 0,
                });

                await saveData();

                setState(() {});

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Kitabı Ekle'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    pagesController.dispose();
  }

  // ============================================================
  // MENÜDEN SAYFA DEĞİŞTİR
  // ============================================================

  void changePage(int page) {
    setState(() {
      selectedPage = page;
    });

    Navigator.pop(context);
  }

  // ============================================================
  // ANA SAYFA
  // ============================================================

  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'leaf',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Bugün kaç sayfa okudun?',
            style: TextStyle(
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 30),

          // ------------------------------------------------------
          // BUGÜN KARTI
          // ------------------------------------------------------

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(30),

            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF5),

              borderRadius:
                  BorderRadius.circular(24),

              border: Border.all(
                color: const Color(0xFFE5E0D4),
              ),
            ),

            child: Column(
              children: [
                const Text(
                  'Bugün',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '$todayPages',

                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  'sayfa',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,

                  child: FilledButton.icon(
                    onPressed: addReading,

                    icon: const Icon(
                      Icons.add,
                    ),

                    label: const Text(
                      'Okuma Ekle',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          // ------------------------------------------------------
          // KİTAPLARIM
          // ------------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Kitaplarım',

                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
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

          const SizedBox(height: 15),

          if (books.isEmpty)
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: const Color(0xFFE9EDDF),
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                  ),

                  SizedBox(width: 12),

                  Text(
                    'Henüz kitap eklenmedi',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

          ...books.asMap().entries.map(
            (entry) {
              return buildBookCard(
                entry.value,
                entry.key,
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KİTAP KARTI
  // ============================================================

  Widget buildBookCard(
    Map<String, dynamic> book,
    int index,
  ) {
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
      margin:
          const EdgeInsets.only(bottom: 14),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFE9EDDF),

        borderRadius:
            BorderRadius.circular(18),
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
                  name,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                onPressed: () async {
                  books.removeAt(index);

                  await saveData();

                  setState(() {});
                },

                icon: const Icon(
                  Icons.delete_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '$readPages / $totalPages sayfa',
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value:
                progress.clamp(0.0, 1.0),

            minHeight: 7,

            borderRadius:
                BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OKUMA TAKVİMİ
  // ============================================================

  Widget buildCalendarPage() {
    final now = DateTime.now();

    final firstDay = DateTime(
      now.year,
      now.month,
      1,
    );

    final daysInMonth = DateTime(
      now.year,
      now.month + 1,
      0,
    ).day;

    final startingWeekday =
        firstDay.weekday;

    final monthNames = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Okuma Takvimi',

            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Okuma alışkanlığını gün gün takip et.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(25),

            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFFCF5),

              borderRadius:
                  BorderRadius.circular(24),

              border: Border.all(
                color:
                    const Color(0xFFE5E0D4),
              ),
            ),

            child: Column(
              children: [
                Text(
                  '${monthNames[now.month - 1]} ${now.year}',

                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceAround,

                  children: [
                    Text('P'),
                    Text('S'),
                    Text('Ç'),
                    Text('P'),
                    Text('C'),
                    Text('C'),
                    Text('P'),
                  ],
                ),

                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),

                  itemCount:
                      startingWeekday -
                          1 +
                          daysInMonth,

                  itemBuilder:
                      (context, index) {
                    if (index <
                        startingWeekday - 1) {
                      return const SizedBox();
                    }

                    final day =
                        index -
                            (startingWeekday - 1) +
                            1;

                    final key =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

                    final pages =
                        readingHistory[key] ?? 0;

                    final isToday =
                        day == now.day;

                    return GestureDetector(
                      onTap: () {
                        showDayInfo(
                          day,
                          pages,
                        );
                      },

                      child: Container(
                        margin:
                            const EdgeInsets.all(3),

                        decoration:
                            BoxDecoration(
                          color: pages > 0
                              ? const Color(
                                  0xFFDDE8D0,
                                )
                              : isToday
                                  ? const Color(
                                      0xFFE9EDDF,
                                    )
                                  : Colors
                                      .transparent,

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          border: isToday
                              ? Border.all(
                                  color:
                                      const Color(
                                    0xFF667A55,
                                  ),

                                  width: 2,
                                )
                              : null,
                        ),

                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Text(
                              '$day',

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            if (pages > 0)
                              Text(
                                '$pages',

                                style:
                                    const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ------------------------------------------------------
          // TAKVİMİN ALTINDAKİ OKUMA KAYITLARI
          // ------------------------------------------------------

          const Text(
            'Bu ay okudukların',

            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 15),

          ...buildMonthlyRecords(now),
        ],
      ),
    );
  }

  // ============================================================
  // AYLIK OKUMA KAYITLARI
  // ============================================================

  List<Widget> buildMonthlyRecords(
    DateTime now,
  ) {
    final monthPrefix =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final records = readingRecords.where(
      (record) {
        final date =
            record['date'].toString();

        return date.startsWith(monthPrefix);
      },
    ).toList();

    if (records.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDDF),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: const Text(
            'Bu ay henüz bir okuma kaydı yok.',
          ),
        ),
      ];
    }

    return records.reversed.map(
      (record) {
        return Container(
          width: double.infinity,

          margin:
              const EdgeInsets.only(bottom: 10),

          padding:
              const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color:
                const Color(0xFFE9EDDF),

            borderRadius:
                BorderRadius.circular(18),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      record['book'].toString(),

                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      record['date'].toString(),
                    ),
                  ],
                ),
              ),

              Text(
                '${record['pages']} sayfa',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    ).toList();
  }

  // ============================================================
  // GÜN DETAYI
  // ============================================================

  void showDayInfo(
    int day,
    int pages,
  ) {
    final now = DateTime.now();

    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    final dayRecords =
        readingRecords.where(
      (record) =>
          record['date'].toString() ==
          date,
    ).toList();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFFFFCF5),

          title: Text(
            '$day ${monthName(now.month)}',
          ),

          content: dayRecords.isEmpty
              ? const Text(
                  'Bu gün için henüz bir okuma kaydı yok.',
                )
              : Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Toplam: $pages sayfa',

                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...dayRecords.map(
                      (record) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .menu_book_outlined,
                                size: 20,
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Expanded(
                                child: Text(
                                  record['book']
                                      .toString(),
                                ),
                              ),

                              Text(
                                '${record['pages']} sf.',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
                  const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  String monthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return months[month - 1];
  }

  // ============================================================
  // KİTAPLAR SAYFASI
  // ============================================================

  Widget buildBooksPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Kitaplarım',

            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Okuduğun kitapları burada tut.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,

            child: FilledButton.icon(
              onPressed: addBook,

              icon: const Icon(
                Icons.add,
              ),

              label:
                  const Text(
                'Yeni Kitap Ekle',
              ),
            ),
          ),

          const SizedBox(height: 25),

          if (books.isEmpty)
            const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(30),

                child: Text(
                  'Henüz kitap eklemedin.',
                ),
              ),
            ),

          ...books.asMap().entries.map(
            (entry) {
              return buildBookCard(
                entry.value,
                entry.key,
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // İSTATİSTİKLER
  // ============================================================

  Widget buildStatisticsPage() {
    int totalPages = 0;

    for (final pages
        in readingHistory.values) {
      totalPages += pages;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'İstatistikler',

            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Okuma yolculuğuna küçük bir bakış.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 30),

          buildStatisticCard(
            'Toplam okunan sayfa',
            '$totalPages',
            Icons.menu_book_outlined,
          ),

          const SizedBox(height: 15),

          buildStatisticCard(
            'Okunan gün',
            '${readingHistory.length}',
            Icons.calendar_month_outlined,
          ),

          const SizedBox(height: 15),

          buildStatisticCard(
            'Kitap sayısı',
            '${books.length}',
            Icons.library_books_outlined,
          ),
        ],
      ),
    );
  }

  Widget buildStatisticCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color:
            const Color(0xFFE9EDDF),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Text(
              title,

              style:
                  const TextStyle(
                fontSize: 17,
              ),
            ),
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 27,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAYFA SEÇİMİ
  // ============================================================

  Widget currentPage() {
    switch (selectedPage) {
      case 1:
        return buildCalendarPage();

      case 2:
        return buildBooksPage();

      case 3:
        return buildStatisticsPage();

      default:
        return buildHomePage();
    }
  }

  // ============================================================
  // ANA BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7F4EC),

        elevation: 0,

        title: const Text(
          'leaf',
          style: TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // YANDAN AÇILAN MENÜ
      // ----------------------------------------------------------

      drawer: Drawer(
        backgroundColor:
            const Color(0xFFF7F4EC),

        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(25),

                child: Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size: 30,
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'leaf',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              ListTile(
                leading:
                    const Icon(
                  Icons.home_outlined,
                ),

                title:
                    const Text(
                  'Ana Sayfa',
                ),

                selected:
                    selectedPage == 0,

                onTap: () {
                  changePage(0);
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons
                      .calendar_month_outlined,
                ),

                title:
                    const Text(
                  'Okuma Takvimi',
                ),

                selected:
                    selectedPage == 1,

                onTap: () {
                  changePage(1);
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons
                      .menu_book_outlined,
                ),

                title:
                    const Text(
                  'Kitaplarım',
                ),

                selected:
                    selectedPage == 2,

                onTap: () {
                  changePage(2);
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons.bar_chart_outlined,
                ),

                title:
                    const Text(
                  'İstatistikler',
                ),

                selected:
                    selectedPage == 3,

                onTap: () {
                  changePage(3);
                },
              ),
            ],
          ),
        ),
      ),

      body: currentPage(),
    );
  }
}