import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srpski_padezi/models/models.dart';

/// Хранит прогресс обучения между запусками приложения.
///
/// Результаты лежат в одной таблице «ключ тренировки → лучший результат»,
/// поэтому и падежи, и числительные учитываются одинаково. Ключ падежа -
/// `case_<номер>`, ключ раздела числительных - `numerals_<тема>`.
///
/// Падеж считается пройденным, если лучший результат не ниже [passingScore].
/// Это только отметка о прогрессе: все падежи доступны с самого начала,
/// порядок в списке подсказывает маршрут, но ничего не запирает.
class ProgressService extends ChangeNotifier {
  ProgressService._();

  static final ProgressService instance = ProgressService._();

  static const int passingScore = 70;
  static const String _key = 'srpski_padezi_progress_v2';

  final Map<String, int> _bestScores = {};
  int _totalAnswers = 0;
  int _totalCorrect = 0;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get totalAnswers => _totalAnswers;
  int get totalCorrect => _totalCorrect;

  static String caseKey(GramCase c) => 'case_${c.index}';

  /// Лучший результат тренировки в процентах (0, если её ещё не проходили).
  int bestScore(String key) => _bestScores[key] ?? 0;

  bool isPassedKey(String key) => bestScore(key) >= passingScore;

  /// Лучший результат по падежу.
  int caseScore(GramCase c) => bestScore(caseKey(c));

  bool isPassed(GramCase c) => caseScore(c) >= passingScore;

  /// Сколько падежей пройдено.
  int get passedCount => GramCase.values.where(isPassed).length;

  /// Доля пройденного курса падежей от 0 до 1.
  double get courseProgress => passedCount / GramCase.values.length;

  bool get isCourseComplete => passedCount == GramCase.values.length;

  /// Следующий падеж, который стоит изучать.
  GramCase get currentCase => GramCase.values.firstWhere(
    (c) => !isPassed(c),
    orElse: () => GramCase.values.last,
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final scores = (data['scores'] as Map<String, dynamic>?) ?? {};
        for (final entry in scores.entries) {
          _bestScores[entry.key] = (entry.value as num).toInt();
        }
        _totalAnswers = (data['answers'] as num?)?.toInt() ?? 0;
        _totalCorrect = (data['correct'] as num?)?.toInt() ?? 0;
      } on Object catch (_) {
        // Повреждённые данные просто игнорируем и начинаем с нуля.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Сохраняет результат тренировки, если он лучше предыдущего.
  Future<void> recordResult(String key, int scorePercent) async {
    if (scorePercent > bestScore(key)) {
      _bestScores[key] = scorePercent;
      notifyListeners();
      await _persist();
    }
  }

  /// Учитывает ответы в общей статистике.
  Future<void> recordAnswers({required int total, required int correct}) async {
    _totalAnswers += total;
    _totalCorrect += correct;
    notifyListeners();
    await _persist();
  }

  Future<void> reset() async {
    _bestScores.clear();
    _totalAnswers = 0;
    _totalCorrect = 0;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'scores': _bestScores,
      'answers': _totalAnswers,
      'correct': _totalCorrect,
    };
    await prefs.setString(_key, jsonEncode(data));
  }
}
