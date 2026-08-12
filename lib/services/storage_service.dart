import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../models/monthly_plan.dart';
import '../models/reading_record.dart';

class StorageService {
  final SharedPreferencesAsync preferences =
      SharedPreferencesAsync();

  Future<List<Book>> loadBooks() async {
    final data =
        await preferences.getString('leaf_books');

    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data);

    return (decoded as List)
        .map(
          (item) => Book.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveBooks(
    List<Book> books,
  ) async {
    final data =
        books.map((book) => book.toMap()).toList();

    await preferences.setString(
      'leaf_books',
      jsonEncode(data),
    );
  }

  Future<Map<String, int>> loadHistory() async {
    final data =
        await preferences.getString(
      'leaf_history',
    );

    if (data == null) {
      return {};
    }

    final decoded = jsonDecode(data);

    return Map<String, int>.from(
      decoded.map(
        (key, value) => MapEntry(
          key.toString(),
          int.parse(value.toString()),
        ),
      ),
    );
  }

  Future<void> saveHistory(
    Map<String, int> history,
  ) async {
    await preferences.setString(
      'leaf_history',
      jsonEncode(history),
    );
  }

  Future<List<ReadingRecord>>
      loadReadingRecords() async {
    final data =
        await preferences.getString(
      'leaf_reading_records',
    );

    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data);

    return (decoded as List)
        .map(
          (item) => ReadingRecord.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveReadingRecords(
    List<ReadingRecord> records,
  ) async {
    final data =
        records.map((record) {
      return record.toMap();
    }).toList();

    await preferences.setString(
      'leaf_reading_records',
      jsonEncode(data),
    );
  }

  Future<List<MonthlyPlan>>
      loadMonthlyPlans() async {
    final data =
        await preferences.getString(
      'leaf_monthly_plans',
    );

    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data);

    return (decoded as List)
        .map(
          (item) => MonthlyPlan.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> saveMonthlyPlans(
    List<MonthlyPlan> plans,
  ) async {
    final data =
        plans.map((plan) {
      return plan.toMap();
    }).toList();

    await preferences.setString(
      'leaf_monthly_plans',
      jsonEncode(data),
    );
  }
}