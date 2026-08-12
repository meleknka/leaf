class Book {
  String name;
  int totalPages;
  int readPages;

  Book({
    required this.name,
    required this.totalPages,
    this.readPages = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalPages': totalPages,
      'readPages': readPages,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      name: map['name'] ?? '',
      totalPages: map['totalPages'] ?? 0,
      readPages: map['readPages'] ?? 0,
    );
  }
}