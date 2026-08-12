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
        scaffoldBackgroundColor: const Color(0xFFECE7D9),
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

  List<Map<String, dynamic>> readingRecords = [];

  // Aylık planlar:
  //
  // {
  //   "month": 8,
  //   "year": 2026,
  //   "bookGoal": 3,
  //   "pageGoal": 500,
  //   "books": ["Suç ve Ceza", "1984"]
  // }
  List<Map<String, dynamic>> monthlyPlans = [];
  void changePage(int page) {
  setState(() {
    selectedPage = page;
  });

  Navigator.pop(context);
}

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
    final savedPlans = prefs.getString('leaf_monthly_plans');

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

    if (savedPlans != null) {
      final decodedPlans = jsonDecode(savedPlans);

      monthlyPlans = List<Map<String, dynamic>>.from(
        decodedPlans.map(
          (plan) => Map<String, dynamic>.from(plan),
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

    await prefs.setString(
      'leaf_monthly_plans',
      jsonEncode(monthlyPlans),
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
  // AY ANAHTARI
  // ============================================================

  String monthKey(int month, int year) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // SEÇİLİ AYIN PLANI
  // ============================================================

  Map<String, dynamic>? getPlan(
    int month,
    int year,
  ) {
    final key = monthKey(month, year);

    for (final plan in monthlyPlans) {
      if (plan['monthKey'] == key) {
        return plan;
      }
    }

    return null;
  }

  // ============================================================
  // AYLIK PLAN KAYDET
  // ============================================================

  Future<void> saveMonthlyPlan({
    required int month,
    required int year,
    required int bookGoal,
    required int pageGoal,
    required List<String> plannedBooks,
  }) async {
    final key = monthKey(month, year);

    final newPlan = {
      'monthKey': key,
      'month': month,
      'year': year,
      'bookGoal': bookGoal,
      'pageGoal': pageGoal,
      'books': plannedBooks,
    };

    final existingIndex = monthlyPlans.indexWhere(
      (plan) => plan['monthKey'] == key,
    );

    if (existingIndex != -1) {
      monthlyPlans[existingIndex] = newPlan;
    } else {
      monthlyPlans.add(newPlan);
    }

    await saveData();

    setState(() {});
  }

  // ============================================================
  // OKUMA EKLE
  // ============================================================

  Future<void> addReading() async {
    if (books.isEmpty) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFCF5),
            title: const Text(
              'Önce bir kitap ekleyelim 📚',
            ),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hangi kitabı okuyorsun?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
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

                    readingHistory[date] =
                        (readingHistory[date] ?? 0) + pages;

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

                      if (totalPages > 0 &&
                          newReadPages > totalPages) {
                        newReadPages = totalPages;
                      }

                      books[bookIndex]['readPages'] =
                          newReadPages;
                    }

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
                  hintText: 'Örneğin: Suç ve Ceza',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Toplam sayfa',
                  hintText: 'Örneğin: 687',
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
                final name =
                    nameController.text.trim();

                final totalPages =
                    int.tryParse(
                  pagesController.text,
                );

                if (name.isEmpty ||
                    totalPages == null ||
                    totalPages <= 0) {
                  return;
                }

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
  // AYLIK PLAN OLUŞTUR / DÜZENLE
  // ============================================================

  Future<void> editMonthlyPlan(
    int month,
    int year,
  ) async {
    final existingPlan =
        getPlan(month, year);

    final bookGoalController =
        TextEditingController(
      text: existingPlan == null
          ? ''
          : existingPlan['bookGoal'].toString(),
    );

    final pageGoalController =
        TextEditingController(
      text: existingPlan == null
          ? ''
          : existingPlan['pageGoal'].toString(),
    );

    List<String> selectedBooks = [];

    if (existingPlan != null) {
      selectedBooks =
          List<String>.from(
        existingPlan['books'] ?? [],
      );
    }

    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  const Color(0xFFFFFCF5),

              title: Text(
                'Aylık Plan • ${monthName(month)} $year',
              ),

              content: SizedBox(
                width: 450,
                child:
                    SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Bu ay için hedeflerin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      TextField(
                        controller:
                            bookGoalController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Kaç kitap?',
                          hintText:
                              'Örneğin: 3',
                          border:
                              OutlineInputBorder(),
                          suffixText:
                              'kitap',
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      TextField(
                        controller:
                            pageGoalController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Kaç sayfa?',
                          hintText:
                              'Örneğin: 500',
                          border:
                              OutlineInputBorder(),
                          suffixText:
                              'sayfa',
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(
                        'Bu ay okumak istediklerin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      if (books.isEmpty)
                        const Text(
                          'Önce Kitaplarım bölümünden kitap eklemelisin.',
                        ),

                      ...books.map(
                        (book) {
                          final name =
                              book['name']
                                  .toString();

                          return CheckboxListTile(
                            contentPadding:
                                EdgeInsets.zero,
                            title:
                                Text(name),
                            value:
                                selectedBooks
                                    .contains(
                              name,
                            ),
                            onChanged:
                                (checked) {
                              setDialogState(
                                () {
                                  if (checked ==
                                      true) {
                                    if (!selectedBooks
                                        .contains(
                                      name,
                                    )) {
                                      selectedBooks
                                          .add(
                                        name,
                                      );
                                    }
                                  } else {
                                    selectedBooks
                                        .remove(
                                      name,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child:
                      const Text('İptal'),
                ),

                FilledButton(
                  onPressed: () {
                    final bookGoal =
                        int.tryParse(
                      bookGoalController
                          .text,
                    ) ??
                        0;

                    final pageGoal =
                        int.tryParse(
                      pageGoalController
                          .text,
                    ) ??
                        0;

                    if (bookGoal <= 0 &&
                        pageGoal <= 0) {
                      return;
                    }

                    saveMonthlyPlan(
                      month: month,
                      year: year,
                      bookGoal: bookGoal,
                      pageGoal: pageGoal,
                      plannedBooks:
                          selectedBooks,
                    );

                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child:
                      const Text('Planı Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    bookGoalController.dispose();
    pageGoalController.dispose();

    if (result == true) {
      setState(() {});
    }
  }

  // ============================================================
  // AYLIK PLAN SAYFASI
  // ============================================================

  Widget buildMonthlyPlanPage() {
    final now = DateTime.now();

    final currentPlan =
        getPlan(
      now.month,
      now.year,
    );

    final int bookGoal =
        currentPlan == null
            ? 0
            : (currentPlan['bookGoal'] ?? 0)
                as int;

    final int pageGoal =
        currentPlan == null
            ? 0
            : (currentPlan['pageGoal'] ?? 0)
                as int;

    final List<String> plannedBooks =
        currentPlan == null
            ? []
            : List<String>.from(
                currentPlan['books'] ?? [],
              );

    final String currentMonthKey =
        monthKey(
      now.month,
      now.year,
    );

    final monthlyRecords =
        readingRecords.where(
      (record) =>
          record['date']
              .toString()
              .startsWith(
                currentMonthKey,
              ),
    ).toList();

    int monthlyPages = 0;

    final Set<String> finishedBooks = {};

    for (final record in monthlyRecords) {
      monthlyPages +=
          (record['pages'] ?? 0) as int;
    }

    for (final book in books) {
      final readPages =
          (book['readPages'] ?? 0) as int;

      final totalPages =
          (book['totalPages'] ?? 0) as int;

      if (totalPages > 0 &&
          readPages >= totalPages) {
        finishedBooks.add(
          book['name'].toString(),
        );
      }
    }

    int completedPlannedBooks = 0;

    for (final bookName in plannedBooks) {
      if (finishedBooks.contains(
        bookName,
      )) {
        completedPlannedBooks++;
      }
    }

    final pageProgress =
        pageGoal > 0
            ? (monthlyPages / pageGoal)
                .clamp(0.0, 1.0)
            : 0.0;

    final bookProgress =
        bookGoal > 0
            ? (completedPlannedBooks /
                    bookGoal)
                .clamp(0.0, 1.0)
            : 0.0;

    return notebookPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        '${monthName(now.month)} ${now.year}',
                        style:
                            const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Bu ay için küçük planım.',
                        style:
                            TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    editMonthlyPlan(
                      now.month,
                      now.year,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  tooltip:
                      'Planı düzenle',
                ),
              ],
            ),

            const SizedBox(height: 28),

            if (currentPlan == null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(22),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFE8EDDF),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Bu ay için henüz plan yok.',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Hedeflerini ve okumak istediğin kitapları belirleyelim.',
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        editMonthlyPlan(
                          now.month,
                          now.year,
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Bu Ayı Planla',
                      ),
                    ),
                  ],
                ),
              ),

            if (currentPlan != null) ...[
              // HEDEF KARTLARI
              Row(
                children: [
                  Expanded(
                    child: buildGoalCard(
                      title: 'Kitap',
                      current:
                          completedPlannedBooks,
                      target:
                          bookGoal,
                      icon: Icons
                          .menu_book_outlined,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: buildGoalCard(
                      title: 'Sayfa',
                      current:
                          monthlyPages,
                      target:
                          pageGoal,
                      icon: Icons
                          .auto_stories_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              const Text(
                'Bu ay okumak istediklerim',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              if (plannedBooks.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFE8EDDF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Text(
                    'Bu ay için kitap seçmedin.',
                  ),
                ),

              ...plannedBooks.map(
                (bookName) {
                  final completed =
                      finishedBooks.contains(
                    bookName,
                  );

                  return Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    padding:
                        const EdgeInsets.all(
                      17,
                    ),
                    decoration:
                        BoxDecoration(
                      color: completed
                          ? const Color(
                              0xFFE2EBD9,
                            )
                          : const Color(
                              0xFFF8F4E9,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color: completed
                            ? const Color(
                                0xFFB8C9A9,
                              )
                            : const Color(
                                0xFFE3DBCA,
                              ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          completed
                              ? Icons
                                  .check_circle_outline
                              : Icons
                                  .radio_button_unchecked,
                          color:
                              completed
                                  ? const Color(
                                      0xFF667A55,
                                    )
                                  : const Color(
                                      0xFF8B897F,
                                    ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            bookName,
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w600,
                              decoration:
                                  completed
                                      ? TextDecoration
                                          .lineThrough
                                      : TextDecoration
                                          .none,
                            ),
                          ),
                        ),
                        Text(
                          completed
                              ? 'Tamamlandı'
                              : 'Devam ediyor',
                          style:
                              TextStyle(
                            fontSize: 13,
                            color: completed
                                ? const Color(
                                    0xFF667A55,
                                  )
                                : const Color(
                                    0xFF77746A,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // GENEL İLERLEME
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(20),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFE8EDDF),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Aylık ilerleme',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(
                      'Sayfa hedefi: $monthlyPages / $pageGoal',
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    LinearProgressIndicator(
                      value:
                          pageProgress,
                      minHeight: 7,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      'Kitap hedefi: $completedPlannedBooks / $bookGoal',
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    LinearProgressIndicator(
                      value:
                          bookProgress,
                      minHeight: 7,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEDEF KARTI
  // ============================================================

  Widget buildGoalCard({
    required String title,
    required int current,
    required int target,
    required IconData icon,
  }) {
    final progress =
        target > 0
            ? (current / target)
                .clamp(0.0, 1.0)
            : 0.0;

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF8F4E9),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE3DBCA),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                const Color(0xFF667A55),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,
            style:
                const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            '$current / $target',
            style:
                const TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEFTER SAYFASI
  // ============================================================

  Widget notebookPage({
    required Widget child,
    bool showLines = true,
  }) {
    return Container(
      margin:
          const EdgeInsets.all(12),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFCF4),
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset:
                Offset(2, 5),
            color:
                Color(0x22000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (showLines)
            Positioned.fill(
              child:
                  IgnorePointer(
                child:
                    CustomPaint(
                  painter:
                      NotebookLinePainter(),
                ),
              ),
            ),

          Positioned(
            left: 52,
            top: 0,
            bottom: 0,
            child:
                Container(
              width: 1,
              color:
                  const Color(
                0xFFE1B7B7,
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.only(
              left: 78,
              right: 28,
              top: 28,
              bottom: 28,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANA SAYFA
  // ============================================================

  Widget buildHomePage() {
    return notebookPage(
      child:
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'leaf',
                        style:
                            TextStyle(
                          fontSize: 34,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'okuma defterim',
                        style:
                            TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed:
                      addBook,
                  icon:
                      const Icon(
                    Icons
                        .add_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 42,
            ),

            const Text(
              'Bugün kaç sayfa okudun?',
              style: TextStyle(
                fontSize: 23,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 26,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF6F0E4,
                ),
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      const Color(
                    0xFFE4DCCB,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE2E9D9,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .menu_book_outlined,
                      size: 32,
                      color:
                          Color(
                        0xFF647656,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 18,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Bugün',
                          style:
                              TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          '$todayPages',
                          style:
                              const TextStyle(
                            fontSize: 38,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'sayfa okudun',
                          style:
                              TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              width: double.infinity,
              child:
                  FilledButton.icon(
                onPressed:
                    addReading,
                style:
                    FilledButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF6C7F5B,
                  ),
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 15,
                  ),
                ),
                icon:
                    const Icon(
                  Icons.add,
                ),
                label:
                    const Text(
                  'Bugünkü Okumayı Ekle',
                  style:
                      TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 44,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Text(
                  'Kitaplarım',
                  style:
                      TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedPage = 2;
                    });
                  },
                  icon:
                      const Icon(
                    Icons.arrow_forward,
                    size: 17,
                  ),
                  label:
                      const Text(
                    'Tümü',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            if (books.isEmpty)
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFE8EDDF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child:
                    const Text(
                  'Henüz bir kitap eklemedin.',
                ),
              ),

            ...books
                .asMap()
                .entries
                .map(
              (entry) {
                return buildBookCard(
                  entry.value,
                  entry.key,
                );
              },
            ),
          ],
        ),
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
    final name =
        book['name'].toString();

    final totalPages =
        (book['totalPages'] ?? 0)
            as int;

    final readPages =
        (book['readPages'] ?? 0)
            as int;

    double progress = 0;

    if (totalPages > 0) {
      progress =
          readPages / totalPages;
    }

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF8F4E9),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              const Color(0xFFE3DBCA),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .menu_book_outlined,
                color:
                    Color(0xFF647656),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  name,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    () async {
                  books.removeAt(
                    index,
                  );

                  await saveData();

                  setState(() {});
                },
                icon:
                    const Icon(
                  Icons
                      .delete_outline,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            '$readPages / $totalPages sayfa',
            style:
                const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          LinearProgressIndicator(
            value:
                progress.clamp(
              0.0,
              1.0,
            ),
            minHeight: 6,
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            backgroundColor:
                const Color(
              0xFFDDE2D4,
            ),
            color:
                const Color(
              0xFF7A8E69,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            '${(progress * 100).round()}% tamamlandı',
            style:
                const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAKVİM
  // ============================================================

  Widget buildCalendarPage() {
    final now =
        DateTime.now();

    final firstDay =
        DateTime(
      now.year,
      now.month,
      1,
    );

    final daysInMonth =
        DateTime(
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

    return notebookPage(
      child:
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'Okuma Takvimi',
              style:
                  TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Okuma alışkanlığını gün gün takip et.',
              style:
                  TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 34,
            ),

            Center(
              child:
                  Text(
                '${monthNames[now.month - 1]} ${now.year}',
                style:
                    const TextStyle(
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

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

            const SizedBox(
              height: 12,
            ),

            GridView.builder(
              shrinkWrap:
                  true,
              physics:
                  const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    7,
                childAspectRatio:
                    1,
              ),
              itemCount:
                  startingWeekday -
                      1 +
                      daysInMonth,
              itemBuilder:
                  (context,
                      index) {
                if (index <
                    startingWeekday -
                        1) {
                  return const SizedBox();
                }

                final day =
                    index -
                        (startingWeekday -
                            1) +
                        1;

                final key =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

                final pages =
                    readingHistory[
                            key] ??
                        0;

                final isToday =
                    day ==
                        now.day;

                return GestureDetector(
                  onTap:
                      () {
                    showDayInfo(
                      day,
                      pages,
                    );
                  },
                  child:
                      Container(
                    margin:
                        const EdgeInsets
                            .all(
                      3,
                    ),
                    decoration:
                        BoxDecoration(
                      color: pages >
                              0
                          ? const Color(
                              0xFFDCE7D2,
                            )
                          : isToday
                              ? const Color(
                                  0xFFE8EDDF,
                                )
                              : Colors
                                  .transparent,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      border:
                          isToday
                              ? Border.all(
                                  color:
                                      const Color(
                                    0xFF667A55,
                                  ),
                                  width:
                                      2,
                                )
                              : null,
                    ),
                    child:
                        Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          '$day',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                        if (pages >
                            0)
                          Text(
                            '$pages',
                            style:
                                const TextStyle(
                              fontSize:
                                  10,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 25,
            ),

            const Text(
              'Bu ay okudukların',
              style:
                  TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            ...buildMonthlyRecords(
              now,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildMonthlyRecords(
    DateTime now,
  ) {
    final monthPrefix =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final records =
        readingRecords.where(
      (record) {
        return record['date']
            .toString()
            .startsWith(
              monthPrefix,
            );
      },
    ).toList();

    if (records.isEmpty) {
      return [
        Container(
          width:
              double.infinity,
          padding:
              const EdgeInsets.all(
            18,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFE8EDDF,
            ),
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
          child:
              const Text(
            'Bu ay henüz bir okuma kaydı yok.',
          ),
        ),
      ];
    }

    return records.reversed
        .map(
      (record) {
        return Container(
          width:
              double.infinity,
          margin:
              const EdgeInsets.only(
            bottom: 10,
          ),
          padding:
              const EdgeInsets.all(
            16,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFF8F4E9,
            ),
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color:
                  const Color(
                0xFFE3DBCA,
              ),
            ),
          ),
          child:
              Row(
            children: [
              const Icon(
                Icons
                    .menu_book_outlined,
                size: 22,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      record['book']
                          .toString(),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      record['date']
                          .toString(),
                      style:
                          const TextStyle(
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${record['pages']} sayfa',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ],
          ),
        );
      },
    ).toList();
  }

  void showDayInfo(
    int day,
    int pages,
  ) {
    final now =
        DateTime.now();

    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    final dayRecords =
        readingRecords.where(
      (record) {
        return record['date']
                .toString() ==
            date;
      },
    ).toList();

    showDialog(
      context: context,
      builder:
          (context) {
        return AlertDialog(
          backgroundColor:
              const Color(
            0xFFFFFCF5,
          ),
          title: Text(
            '$day ${monthName(now.month)}',
          ),
          content:
              dayRecords.isEmpty
                  ? const Text(
                      'Bu gün için henüz bir okuma kaydı yok.',
                    )
                  : Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Toplam: $pages sayfa',
                          style:
                              const TextStyle(
                            fontSize:
                                17,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ...dayRecords.map(
                          (record) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    10,
                              ),
                              child:
                                  Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .menu_book_outlined,
                                    size:
                                        19,
                                  ),
                                  const SizedBox(
                                    width:
                                        8,
                                  ),
                                  Expanded(
                                    child:
                                        Text(
                                      record[
                                              'book']
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
                Navigator.pop(
                  context,
                );
              },
              child:
                  const Text(
                'Kapat',
              ),
            ),
          ],
        );
      },
    );
  }

  String monthName(
    int month,
  ) {
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
  // KİTAPLAR
  // ============================================================

  Widget buildBooksPage() {
    return notebookPage(
      child:
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'Kitaplarım',
              style:
                  TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Okuduğun kitapları burada tut.',
              style:
                  TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  FilledButton.icon(
                onPressed:
                    addBook,
                icon:
                    const Icon(
                  Icons.add,
                ),
                label:
                    const Text(
                  'Yeni Kitap Ekle',
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            if (books.isEmpty)
              const Center(
                child:
                    Padding(
                  padding:
                      EdgeInsets.all(
                    30,
                  ),
                  child:
                      Text(
                    'Henüz kitap eklemedin.',
                  ),
                ),
              ),

            ...books
                .asMap()
                .entries
                .map(
              (entry) {
                return buildBookCard(
                  entry.value,
                  entry.key,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // İSTATİSTİK
  // ============================================================

  Widget buildStatisticsPage() {
    int totalPages = 0;

    for (final pages
        in readingHistory.values) {
      totalPages +=
          pages;
    }

    return notebookPage(
      child:
          SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'İstatistikler',
              style:
                  TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Okuma yolculuğuna küçük bir bakış.',
              style:
                  TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            buildStatisticCard(
              'Toplam okunan sayfa',
              '$totalPages',
              Icons
                  .menu_book_outlined,
            ),

            const SizedBox(
              height: 12,
            ),

            buildStatisticCard(
              'Okunan gün',
              '${readingHistory.length}',
              Icons
                  .calendar_month_outlined,
            ),

            const SizedBox(
              height: 12,
            ),

            buildStatisticCard(
              'Kitap sayısı',
              '${books.length}',
              Icons
                  .library_books_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatisticCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFE8EDDF,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            size: 28,
            color:
                const Color(
              0xFF667A55,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child:
                Text(
              title,
              style:
                  const TextStyle(
                fontSize:
                    16,
              ),
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize:
                  25,
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

      case 4:
        return buildMonthlyPlanPage();

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
      backgroundColor:
          const Color(0xFFECE7D9),

      appBar:
          AppBar(
        backgroundColor:
            const Color(
          0xFFECE7D9,
        ),
        elevation: 0,
        title:
            const Text(
          'leaf',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      drawer:
          Drawer(
        backgroundColor:
            const Color(
          0xFFF7F4EC,
        ),
        child:
            SafeArea(
          child:
              Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(
                  25,
                ),
                child:
                    Row(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size:
                          30,
                      color:
                          Color(
                        0xFF667A55,
                      ),
                    ),
                    const SizedBox(
                      width:
                          10,
                    ),
                    const Text(
                      'leaf',
                      style:
                          TextStyle(
                        fontSize:
                            28,
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
                    selectedPage ==
                        0,
                onTap:
                    () {
                  changePage(
                    0,
                  );
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
                    selectedPage ==
                        1,
                onTap:
                    () {
                  changePage(
                    1,
                  );
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
                    selectedPage ==
                        2,
                onTap:
                    () {
                  changePage(
                    2,
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons
                      .bar_chart_outlined,
                ),
                title:
                    const Text(
                  'İstatistikler',
                ),
                selected:
                    selectedPage ==
                        3,
                onTap:
                    () {
                  changePage(
                    3,
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons
                      .edit_calendar_outlined,
                ),
                title:
                    const Text(
                  'Aylık Plan',
                ),
                selected:
                    selectedPage ==
                        4,
                onTap:
                    () {
                  changePage(
                    4,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body:
          currentPage(),
    );
  }
}

// ============================================================
// DEFTER ÇİZGİLERİ
// ============================================================

class NotebookLinePainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint =
        Paint()
          ..color =
              const Color(
            0xFFE8E1D5,
          )
          ..strokeWidth = 1;

    const lineSpacing =
        30.0;

    for (
      double y = 28;
      y < size.height;
      y += lineSpacing
    ) {
      canvas.drawLine(
        Offset(
          0,
          y,
        ),
        Offset(
          size.width,
          y,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {
    return false;
  }
}