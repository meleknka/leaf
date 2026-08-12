class MonthlyPlan {
  final String monthKey;
  final int month;
  final int year;
  final int bookGoal;
  final int pageGoal;
  final List<String> books;

  MonthlyPlan({
    required this.monthKey,
    required this.month,
    required this.year,
    required this.bookGoal,
    required this.pageGoal,
    required this.books,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthKey': monthKey,
      'month': month,
      'year': year,
      'bookGoal': bookGoal,
      'pageGoal': pageGoal,
      'books': books,
    };
  }

  factory MonthlyPlan.fromMap(
    Map<String, dynamic> map,
  ) {
    return MonthlyPlan(
      monthKey: map['monthKey'] ?? '',
      month: map['month'] ?? 1,
      year: map['year'] ?? 2026,
      bookGoal: map['bookGoal'] ?? 0,
      pageGoal: map['pageGoal'] ?? 0,
      books: List<String>.from(
        map['books'] ?? [],
      ),
    );
  }
}