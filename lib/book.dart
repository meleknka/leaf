class Book {
  String title;
  int totalPages;
  int readPages;

  Book({
    required this.title,
    required this.totalPages,
    this.readPages = 0,
  });
}