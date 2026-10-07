import 'package:flutter/foundation.dart';
import '../../../../core/services/local_database.dart';
import '../data/models/history_record_model.dart';
import '../data/models/report_metrics.dart';

/// Provider managing report metrics, charts, monthly progress, and history records.
class HistoryProvider extends ChangeNotifier {
  // Lifetime aggregate metrics
  int _totalSteps = 256480;
  int _totalTimeSeconds = (85 * 3600) + (24 * 60); // 85h 24m
  int _totalCalories = 20492;
  double _totalDistanceKm = 294.35;

  // Report filters and selections
  ReportPeriodFilter _periodFilter = ReportPeriodFilter.thisWeek;
  ReportMetricType _metricType = ReportMetricType.steps;
  int _selectedBarIndex = 4; // Day 20 by default (matching design)
  DateTime _currentMonth = DateTime(2024, 12, 1);
  int _selectedCalendarDay = 22; // Day 22 by default (matching design)

  // Chart data
  late List<ChartDayData> _weeklyChartDays;

  // History entries list (for History tab & swipe deletion)
  late List<HistoryRecordModel> _historyRecords;
  HistoryRecordModel? _recentlyDeletedRecord;
  int? _recentlyDeletedIndex;

  HistoryProvider() {
    _initSampleData();
    _loadFromDatabase();
  }

  // Getters
  int get totalSteps => _totalSteps;
  int get totalTimeSeconds => _totalTimeSeconds;
  int get totalCalories => _totalCalories;
  double get totalDistanceKm => _totalDistanceKm;

  String get formattedTotalSteps => _formatNumber(_totalSteps);
  String get formattedTotalTime {
    final h = _totalTimeSeconds ~/ 3600;
    final m = (_totalTimeSeconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }
  String get formattedTotalCalories => _formatNumber(_totalCalories);
  String get formattedTotalDistance => _totalDistanceKm.toStringAsFixed(2);

  ReportPeriodFilter get periodFilter => _periodFilter;
  ReportMetricType get metricType => _metricType;
  int get selectedBarIndex => _selectedBarIndex;
  DateTime get currentMonth => _currentMonth;
  int get selectedCalendarDay => _selectedCalendarDay;
  List<ChartDayData> get weeklyChartDays => _weeklyChartDays;
  List<HistoryRecordModel> get historyRecords => _historyRecords;
  bool get canUndoDelete => _recentlyDeletedRecord != null;

  ChartDayData? get selectedChartDay =>
      (_selectedBarIndex >= 0 && _selectedBarIndex < _weeklyChartDays.length)
          ? _weeklyChartDays[_selectedBarIndex]
          : null;

  void _initSampleData() {
    _weeklyChartDays = [
      const ChartDayData(
        dayNumber: 16,
        dayLabel: '16',
        steps: 5520,
        activeMinutes: 72,
        calories: 380,
        distanceKm: 4.31,
      ),
      const ChartDayData(
        dayNumber: 17,
        dayLabel: '17',
        steps: 6700,
        activeMinutes: 88,
        calories: 470,
        distanceKm: 5.22,
      ),
      const ChartDayData(
        dayNumber: 18,
        dayLabel: '18',
        steps: 4210,
        activeMinutes: 55,
        calories: 290,
        distanceKm: 3.28,
      ),
      const ChartDayData(
        dayNumber: 19,
        dayLabel: '19',
        steps: 5850,
        activeMinutes: 76,
        calories: 405,
        distanceKm: 4.56,
      ),
      const ChartDayData(
        dayNumber: 20,
        dayLabel: '20',
        steps: 5289, // exact tooltip value from design 32_Light_report.png
        activeMinutes: 69,
        calories: 368,
        distanceKm: 4.12,
        isHighlighted: true,
      ),
      const ChartDayData(
        dayNumber: 21,
        dayLabel: '21',
        steps: 7120,
        activeMinutes: 92,
        calories: 495,
        distanceKm: 5.55,
      ),
      const ChartDayData(
        dayNumber: 22,
        dayLabel: '22',
        steps: 6430,
        activeMinutes: 84,
        calories: 445,
        distanceKm: 5.01,
      ),
    ];

    _historyRecords = [
      HistoryRecordModel(
        id: 'rec_today_1',
        sectionTitle: 'Today',
        timestamp: DateTime(2024, 12, 22, 10, 30),
        steps: 6496,
        durationMinutes: 94,
        calories: 525,
        distanceKm: 7.23,
      ),
      HistoryRecordModel(
        id: 'rec_sat_1',
        sectionTitle: 'Saturday, Dec 21 2024',
        timestamp: DateTime(2024, 12, 21, 9, 15),
        steps: 1668,
        durationMinutes: 26,
        calories: 122,
        distanceKm: 1.84,
      ),
      HistoryRecordModel(
        id: 'rec_sat_2',
        sectionTitle: 'Saturday, Dec 21 2024',
        timestamp: DateTime(2024, 12, 21, 14, 0),
        steps: 3228,
        durationMinutes: 48,
        calories: 238,
        distanceKm: 3.57,
      ),
      HistoryRecordModel(
        id: 'rec_sat_3',
        sectionTitle: 'Saturday, Dec 21 2024',
        timestamp: DateTime(2024, 12, 21, 18, 45),
        steps: 2309,
        durationMinutes: 35,
        calories: 170,
        distanceKm: 2.55,
      ),
      HistoryRecordModel(
        id: 'rec_fri_1',
        sectionTitle: 'Friday, Dec 20 2024',
        timestamp: DateTime(2024, 12, 20, 8, 30),
        steps: 3095,
        durationMinutes: 47,
        calories: 228,
        distanceKm: 3.49,
      ),
      HistoryRecordModel(
        id: 'rec_fri_2',
        sectionTitle: 'Friday, Dec 20 2024',
        timestamp: DateTime(2024, 12, 20, 17, 10),
        steps: 2194,
        durationMinutes: 33,
        calories: 162,
        distanceKm: 2.48,
      ),
      HistoryRecordModel(
        id: 'rec_thu_1',
        sectionTitle: 'Thursday, Dec 19 2024',
        timestamp: DateTime(2024, 12, 19, 10, 0),
        steps: 1926,
        durationMinutes: 29,
        calories: 142,
        distanceKm: 2.16,
      ),
      HistoryRecordModel(
        id: 'rec_thu_2',
        sectionTitle: 'Thursday, Dec 19 2024',
        timestamp: DateTime(2024, 12, 19, 16, 20),
        steps: 2553,
        durationMinutes: 39,
        calories: 188,
        distanceKm: 2.85,
      ),
    ];
  }

  Future<void> _loadFromDatabase() async {
    try {
      if (LocalDatabase.instance.isInitialized) {
        final box = LocalDatabase.instance.historyBox;
        if (box.isNotEmpty) {
          int dbSteps = 0;
          int dbMinutes = 0;
          int dbCalories = 0;
          double dbDistance = 0.0;

          for (final item in box.values) {
            dbSteps += item.steps;
            dbMinutes += item.activeMinutes;
            dbCalories += item.calories;
            dbDistance += item.distanceKm;
          }

          if (dbSteps > _totalSteps) {
            _totalSteps = dbSteps;
            _totalTimeSeconds = dbMinutes * 60;
            _totalCalories = dbCalories;
            _totalDistanceKm = dbDistance;
            notifyListeners();
          }
        }
      }
    } catch (_) {
      // Continue with sample baseline
    }
  }

  // Filter and selection mutators
  void setPeriodFilter(ReportPeriodFilter filter) {
    if (_periodFilter != filter) {
      _periodFilter = filter;
      notifyListeners();
    }
  }

  void setMetricType(ReportMetricType type) {
    if (_metricType != type) {
      _metricType = type;
      notifyListeners();
    }
  }

  void selectBarIndex(int index) {
    if (index >= 0 && index < _weeklyChartDays.length && _selectedBarIndex != index) {
      _selectedBarIndex = index;
      notifyListeners();
    }
  }

  void selectCalendarDay(int day) {
    if (_selectedCalendarDay != day) {
      _selectedCalendarDay = day;
      notifyListeners();
    }
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    notifyListeners();
  }

  /// Builds a list of [CalendarDayProgress] cells for the current month grid.
  List<CalendarDayProgress> buildMonthCalendarGrid() {
    final year = _currentMonth.year;
    final month = _currentMonth.month;

    // Days in current month
    final daysInCurrentMonth = DateTime(year, month + 1, 0).day;

    // First day of current month weekday (1 = Monday, ..., 7 = Sunday)
    final firstDayWeekday = DateTime(year, month, 1).weekday;
    // Map to 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    final sundayOffset = firstDayWeekday % 7;

    final List<CalendarDayProgress> cells = [];

    // Prior month trailing days (if any)
    if (sundayOffset > 0) {
      final daysInPrevMonth = DateTime(year, month, 0).day;
      for (int i = sundayOffset - 1; i >= 0; i--) {
        final dayNum = daysInPrevMonth - i;
        cells.add(CalendarDayProgress(
          date: DateTime(year, month - 1, dayNum),
          dayNumber: dayNum,
          progressRatio: 0.0,
          isCurrentMonth: false,
          isFuture: false,
        ));
      }
    }

    // Progress ratios mapping for December 2024 matching design 32_Light_report.png
    final Map<int, double> sampleRatios = {
      1: 1.0,
      2: 1.0,
      3: 0.75,
      4: 0.35,
      5: 0.80,
      6: 0.0,
      7: 1.0,
      8: 1.0,
      9: 0.60,
      10: 0.75,
      11: 1.0,
      12: 0.45,
      13: 1.0,
      14: 1.0,
      15: 0.20,
      16: 1.0,
      17: 1.0,
      18: 0.50,
      19: 0.60,
      20: 1.0,
      21: 1.0,
      22: 1.0, // active/highlighted day in design
      23: 0.0,
      24: 0.0,
      25: 0.0,
      26: 0.0,
      27: 0.0,
      28: 0.0,
      29: 0.0,
      30: 0.0,
      31: 0.0,
    };

    // Days of current month
    for (int day = 1; day <= daysInCurrentMonth; day++) {
      final isFutureDay = (year == 2024 && month == 12 && day > 22);
      final ratio = sampleRatios[day] ?? (isFutureDay ? 0.0 : 0.8);
      cells.add(CalendarDayProgress(
        date: DateTime(year, month, day),
        dayNumber: day,
        progressRatio: ratio,
        isCurrentMonth: true,
        isSelected: (day == _selectedCalendarDay && year == 2024 && month == 12),
        isFuture: isFutureDay,
      ));
    }

    // Trailing days of next month to complete 35 cells (or 42)
    final remainder = (7 - (cells.length % 7)) % 7;
    for (int day = 1; day <= remainder; day++) {
      cells.add(CalendarDayProgress(
        date: DateTime(year, month + 1, day),
        dayNumber: day,
        progressRatio: 0.0,
        isCurrentMonth: false,
        isFuture: true,
      ));
    }

    return cells;
  }

  // History deletion & undo actions
  void deleteRecord(HistoryRecordModel record) {
    final index = _historyRecords.indexOf(record);
    if (index != -1) {
      _recentlyDeletedRecord = record;
      _recentlyDeletedIndex = index;
      _historyRecords.removeAt(index);
      notifyListeners();
    }
  }

  void undoDelete() {
    if (_recentlyDeletedRecord != null && _recentlyDeletedIndex != null) {
      final insertIndex = _recentlyDeletedIndex!.clamp(0, _historyRecords.length);
      _historyRecords.insert(insertIndex, _recentlyDeletedRecord!);
      _recentlyDeletedRecord = null;
      _recentlyDeletedIndex = null;
      notifyListeners();
    }
  }

  void clearUndo() {
    _recentlyDeletedRecord = null;
    _recentlyDeletedIndex = null;
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
