class ReadingRecord {
  final String date;
  final String book;
  final int pages;

  ReadingRecord({
    required this.date,
    required this.book,
    required this.pages,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'book': book,
      'pages': pages,
    };
  }

  factory ReadingRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReadingRecord(
      date: map['date'] ?? '',
      book: map['book'] ?? '',
      pages: map['pages'] ?? 0,
    );
  }
}