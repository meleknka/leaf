class Book {
  String title;
  int totalPages;
  int readPages;

  Book({
    required this.title,
    required this.totalPages,
    this.readPages = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'totalPages': totalPages,
      'readPages': readPages,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'],
      totalPages: map['totalPages'],
      readPages: map['readPages'],
    );
  }
}