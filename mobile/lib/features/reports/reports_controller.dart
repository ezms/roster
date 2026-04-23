import 'package:flutter/material.dart';
import 'package:mobile/core/models/attendance_report.dart';
import 'package:mobile/core/models/class.dart';
import 'package:mobile/core/models/user.dart';
import 'package:mobile/shared/repositories/reports_repository.dart';

class ReportsController extends ChangeNotifier {
  final ReportsRepository _repository;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  Class? selectedClass;
  User? selectedTeacher;

  List<User> teachers = [];
  AttendanceReport? report;
  bool isLoading = false;
  bool isLoadingTeachers = false;
  String? errorMessage;
  bool showAllSessions = false;

  ReportsController(this._repository) {
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    isLoadingTeachers = true;
    notifyListeners();
    try {
      teachers = await _repository.fetchTeachers();
    } catch (_) {
    } finally {
      isLoadingTeachers = false;
      notifyListeners();
    }
  }

  Future<void> generateReport(List<Class> classes) async {
    isLoading = true;
    errorMessage = null;
    report = null;
    notifyListeners();

    try {
      report = await _repository.fetchReport(
        month: selectedMonth,
        year: selectedYear,
        classId: selectedClass?.id,
        teacherId: selectedTeacher?.id,
      );
    } catch (_) {
      errorMessage = 'Não foi possível gerar o relatório.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setMonth(int month) {
    selectedMonth = month;
    report = null;
    notifyListeners();
  }

  void setYear(int year) {
    selectedYear = year;
    report = null;
    notifyListeners();
  }

  void setClass(Class? c) {
    selectedClass = c;
    report = null;
    notifyListeners();
  }

  void setTeacher(User? teacher) {
    selectedTeacher = teacher;
    report = null;
    notifyListeners();
  }

  void toggleShowAllSessions() {
    showAllSessions = !showAllSessions;
    notifyListeners();
  }

  String buildCsv() => _repository.buildCsv(report!, selectedMonth, selectedYear);
}
