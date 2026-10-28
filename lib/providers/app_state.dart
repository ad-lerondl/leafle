import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/routine.dart';
import '../models/leafle.dart';
import '../models/forest.dart';
import '../models/anti_routine.dart';
import '../models/anti_routine_result.dart';
import '../models/day_rating.dart';
import '../services/notification_service.dart';

/// Provider principal qui gère tout l'état de l'application
class AppState extends ChangeNotifier {
  List<Routine> _routines = [];
  List<AntiRoutine> _antiRoutines = [];
  List<DayRating> _dayRatings = [];
  Leafle _leafle = Leafle();
  Forest _forest = Forest();
  int _totalPoints = 0;
  DateTime _lastUpdateDate = DateTime.now();
  int _dayStartHour = 3;
  bool _notificationsEnabled = false;
  // Permet d'attendre que les données soient chargées avant d'afficher l'UI
  final Completer<void> _loadedCompleter = Completer<void>();

  // Getters
  List<Routine> get routines => _routines;
  List<AntiRoutine> get antiRoutines => _antiRoutines;
  List<DayRating> get dayRatings => _dayRatings;
  Leafle get leafle => _leafle;
  Forest get forest => _forest;
  int get totalPoints => _totalPoints;
  DateTime get lastUpdateDate => _lastUpdateDate;
  int get dayStartHour => _dayStartHour;
  bool get notificationsEnabled => _notificationsEnabled;

  DateTime get currentDayKey => _dayKey(DateTime.now());

  DateTime _dayKey(DateTime date) {
    final adjusted = date.subtract(Duration(hours: _dayStartHour));
    return DateTime(adjusted.year, adjusted.month, adjusted.day);
  }

  // Points disponibles pour nourrir Leafle ou planter des arbres
  int get availablePoints => _totalPoints;

  AppState() {
    _initializeDefaultRoutines();
    _initializeDefaultAntiRoutines();
    loadData();
  }

  /// Retourne un Future qui se résout quand les données ont été chargées
  Future<void> ensureLoaded() => _loadedCompleter.future;

  /// Initialise les routines par défaut
  void _initializeDefaultRoutines() {
    _routines = [
      Routine(
        name: 'Italien',
        icon: '🍝',
        points: 20,
        description: 'Apprendre l\'italien avec l\'appli Parlami',
      ),
      Routine(
        name: 'Méditation/Prière',
        icon: '🙏',
        points: 15,
        description: 'Prendre un moment de méditation ou de prière',
      ),
      Routine(
        name: 'Course/Sport',
        icon: '🏃',
        points: 30,
        description: 'Faire de l\'exercice physique',
      ),
      Routine(
        name: 'Se lever tôt',
        icon: '🌅',
        points: 25,
        description: 'Se lever dès que le réveil sonne',
      ),
      Routine(
        name: 'Prendre l\'air',
        icon: '🌳',
        points: 15,
        description: 'Sortir et respirer l\'air frais',
      ),
      Routine(
        name: 'Lecture',
        icon: '📚',
        points: 20,
        description: 'Lire pendant 30 minutes',
      ),
      Routine(
        name: 'Hydratation',
        icon: '💧',
        points: 10,
        description: 'Boire au moins 2L d\'eau',
      ),
      Routine(
        name: 'Repas sain',
        icon: '🥗',
        points: 15,
        description: 'Manger équilibré',
      ),
    ];
  }

  /// Initialise les anti-routines par défaut
  void _initializeDefaultAntiRoutines() {
    _antiRoutines = [
      AntiRoutine(
        name: 'Cigarettes',
        icon: '🚬',
        description: 'Limiter le nombre de cigarettes fumées',
        unit: 'cigarettes',
        dailyLimit: 5, // Objectif : ne pas dépasser 5 cigarettes
        rewardPoints: 20,
      ),
    ];
  }

  /// Met à jour l'état quotidien
  void updateDailyState() {
    final now = DateTime.now();
    final today = _dayKey(now);
    final lastUpdate = _lastUpdateDate;
    final lastUpdateDay = _dayKey(lastUpdate);

    // Met à jour l'embonpoint de Leafle en fonction des points
    _leafle.updateEmbonpoint(_totalPoints);

    // Met à jour l'énergie de Leafle avec le temps écoulé (même si pas un nouveau jour)
    _leafle.updateEnergyOverTime(_forest.aliveTreesCount);

    // Vérifie si c'est un nouveau jour (ou plusieurs jours écoulés)
    final elapsedDays = today.difference(lastUpdateDay).inDays;
    if (elapsedDays > 0) {
      // Applique une dégradation/jour de la forêt même si l'app était fermée
      for (int i = 0; i < elapsedDays; i++) {
        _forest.updateTreesHealth(_leafle.energy);
      }

      // Traite les anti-routines du jour précédent (récompenses/pénalités)
      _processEndOfDayAntiRoutines();

      // Pénalité pour routines en mode difficile non réalisées la veille
      _processMissedHardModeRoutines();

      // Bonus: si toutes les routines du jour précédent étaient faites, plante un arbre doré
      final allCompleted = _routines.isNotEmpty && _routines.every((r) => r.isCompletedToday);
      if (allCompleted) {
        _forest.plantGoldenTree(const Uuid().v4());
      }

      // Réinitialise les routines
      for (var routine in _routines) {
        routine.resetDaily();
      }

      // Réinitialise les anti-routines
      for (var ar in _antiRoutines) {
        ar.resetDaily();
      }

      // Met à jour la santé de la forêt pour l'état courant (jour présent)
      _forest.updateTreesHealth(_leafle.energy);

      _lastUpdateDate = now;
      saveData();
      if (_notificationsEnabled) {
        NotificationService.instance.scheduleDailyReminder(_dayStartHour);
      }
      notifyListeners();
    } else {
      // Sauvegarde quand même pour enregistrer la perte d'énergie
      saveData();
      notifyListeners();
    }
  }

  /// Applique des dégâts aux arbres pour chaque routine "mode difficile" non effectuée
  void _processMissedHardModeRoutines() {
    // Dégâts par routine manquée (un seul arbre ciblé, ajusté par taille/doré)
    const double damagePerMissed = 5.0;
    final missedHard = _routines.where((r) => r.hardMode && !r.isCompletedToday).toList();
    for (var _ in missedHard) {
      _forest.damageOneTree(damagePerMissed);
    }
  }

  /// Complète une routine et donne des points
  void completeRoutine(String routineId) {
    updateDailyState();
    final routine = _routines.firstWhere((r) => r.id == routineId);

    if (!routine.isCompletedToday) {
      routine.complete();
      // Normalise le gain: si la somme des points des routines > 100,
      // on distribue au prorata sur une base 100.
      final normalized = _normalizedRoutineReward(routine.points);
      _totalPoints += normalized;

      // Nourrit automatiquement Leafle
      _leafle.feed(normalized);

      // Met à jour l'embonpoint en fonction des nouveaux points
      _leafle.updateEmbonpoint(_totalPoints);

      saveData();
      notifyListeners();
    }
  }

  /// Calcule le gain de points normalisé pour une routine.
  /// - Si la somme des points de toutes les routines <= 100, on garde la valeur telle quelle.
  /// - Sinon, on attribue round(points / total * 100) pour répartir sur 100 points par jour.
  int _normalizedRoutineReward(int routinePoints) {
    final total = _routines.fold<int>(0, (sum, r) => sum + r.points);
    if (total <= 0) return routinePoints;
    if (total <= 100) return routinePoints;
    final value = (routinePoints / total) * 100.0;
    final rounded = value.round();
    // Garantit au moins 1 point si la routine a un poids non nul
    return rounded.clamp(1, 100);
  }

  // -------- Anti-routines --------

  /// Enregistre la valeur du jour pour une anti-routine
  /// Les effets (récompense/pénalité) seront appliqués au changement de jour
  AntiRoutineResult recordAntiRoutine(String antiRoutineId, int value) {
    updateDailyState();
    final anti = _antiRoutines.firstWhere((a) => a.id == antiRoutineId);
    final previous = anti.todayValue ?? 0;
    anti.recordToday(value, dayKey: currentDayKey);

    final status = (previous == value) ? AntiRoutineStatus.noChange : AntiRoutineStatus.recorded;

    String message;
    if (value <= anti.dailyLimit) {
      message = '✅ Valeur enregistrée ($value ${anti.unit}). '
          'Limite respectée ! La forêt sera soignée en fin de journée.';
    } else {
      final excess = value - anti.dailyLimit;
      message = '⚠️ Valeur enregistrée ($value ${anti.unit}). '
          'Dépassement de $excess ${anti.unit}. La forêt subira des dégâts en fin de journée.';
    }

    saveData();
    notifyListeners();

    return AntiRoutineResult(
      status: status,
      previousValue: previous,
      newValue: value,
      message: message,
    );
  }

  /// Applique les récompenses/pénalités des anti-routines en fin de journée
  void _processEndOfDayAntiRoutines() {
    for (var anti in _antiRoutines) {
      // Ignore les anti-routines non renseignées aujourd'hui
      if (anti.todayValue == null) continue;

      if (anti.todayValue! <= anti.dailyLimit) {
        // Récompense: soigne légèrement tous les arbres
        const healAmount = 3.0;
        for (var tree in _forest.trees) {
          tree.heal(healAmount);
        }
      } else {
        // Pénalité: endommage les arbres proportionnellement au dépassement
        final excess = anti.todayValue! - anti.dailyLimit;
        final damagePerTree = (excess * 0.5).clamp(1.0, 5.0);
        for (var tree in _forest.trees) {
          tree.damage(damagePerTree);
        }
      }
    }
    _forest.updateOverallHealth();
  }

  void addAntiRoutine(AntiRoutine antiRoutine) {
    _antiRoutines.add(antiRoutine);
    saveData();
    notifyListeners();
  }

  void updateAntiRoutine(String antiRoutineId, AntiRoutine updated) {
    final index = _antiRoutines.indexWhere((a) => a.id == antiRoutineId);
    if (index != -1) {
      _antiRoutines[index] = updated;
      saveData();
      notifyListeners();
    }
  }

  void deleteAntiRoutine(String antiRoutineId) {
    _antiRoutines.removeWhere((a) => a.id == antiRoutineId);
    saveData();
    notifyListeners();
  }

  // -------- Notes de journée --------

  /// Enregistre ou met à jour la note de la journée
  void rateDayToday(int stars, {String? note}) {
    updateDailyState();
    final today = currentDayKey;

    // Vérifie si une note existe déjà pour aujourd'hui
    final existingIndex = _dayRatings
        .indexWhere((r) => r.date.year == today.year && r.date.month == today.month && r.date.day == today.day);

    if (existingIndex != -1) {
      _dayRatings[existingIndex] = DayRating(
        date: today,
        stars: stars,
        note: note,
      );
    } else {
      _dayRatings.add(DayRating(
        date: today,
        stars: stars,
        note: note,
      ));
    }

    // Limiter l'historique aux 365 derniers jours
    if (_dayRatings.length > 365) {
      _dayRatings.sort((a, b) => a.date.compareTo(b.date));
      _dayRatings.removeRange(0, _dayRatings.length - 365);
    }

    saveData();
    notifyListeners();
  }

  /// Récupère la note d'aujourd'hui si elle existe
  DayRating? get todayRating {
    final today = currentDayKey;
    try {
      return _dayRatings
          .firstWhere((r) => r.date.year == today.year && r.date.month == today.month && r.date.day == today.day);
    } catch (_) {
      return null;
    }
  }

  /// Statistiques des notes de journée
  double get averageRating {
    if (_dayRatings.isEmpty) return 0.0;
    final sum = _dayRatings.fold<int>(0, (sum, r) => sum + r.stars);
    return sum / _dayRatings.length;
  }

  int get goodDaysCount => _dayRatings.where((r) => r.isGoodDay).length;
  int get averageDaysCount => _dayRatings.where((r) => r.isAverageDay).length;
  int get badDaysCount => _dayRatings.where((r) => r.isBadDay).length;

  /// Plante un arbre avec une taille (small/medium/large) et un coût variable
  bool plantTree({String size = 'medium'}) {
    const costs = {
      'small': 60,
      'medium': 100,
      'large': 200,
    };
    final treeCost = costs[size] ?? 100;

    if (_totalPoints >= treeCost) {
      _totalPoints -= treeCost;
      _forest.plantTree(const Uuid().v4(), size: size);

      // Met à jour l'embonpoint en fonction des nouveaux points
      _leafle.updateEmbonpoint(_totalPoints);

      saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  // -------- Forêt multi-étages --------
  void addForestLayer() {
    _forest.addLayer();
    saveData();
    notifyListeners();
  }

  void setForestLayer(int index) {
    _forest.setCurrentLayer(index);
    saveData();
    notifyListeners();
  }

  void renameForestLayer(int index, String name) {
    _forest.renameLayer(index, name);
    saveData();
    notifyListeners();
  }

  void deleteForestLayer(int index, {int? transferToIndex}) {
    _forest.deleteLayer(index, transferToIndex: transferToIndex);
    saveData();
    notifyListeners();
  }

  /// Embauche un mini Leafle si les conditions sont remplies
  /// Conditions: suffisamment de points et une forêt assez développée
  bool hireMiniLeafle() {
    // Prix croissant en fonction du nombre déjà embauché
    const baseCost = 400;
    final cost = baseCost + (_leafle.miniHelpers * 200);

    // Condition de taille de forêt: au moins 20 arbres plantés, +10 par helper déjà embauché
    final requiredTrees = 20 + (_leafle.miniHelpers * 10);

    if (_totalPoints >= cost && _forest.totalTreesPlanted >= requiredTrees) {
      _totalPoints -= cost;
      _leafle.miniHelpers += 1;

      // Met à jour l'embonpoint en fonction des nouveaux points
      _leafle.updateEmbonpoint(_totalPoints);

      saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Ajoute une nouvelle routine personnalisée
  void addRoutine(Routine routine) {
    _routines.add(routine);
    saveData();
    notifyListeners();
  }

  /// Modifie une routine existante
  void updateRoutine(String routineId, Routine updatedRoutine) {
    final index = _routines.indexWhere((r) => r.id == routineId);
    if (index != -1) {
      _routines[index] = updatedRoutine;
      saveData();
      notifyListeners();
    }
  }

  /// Supprime une routine
  void deleteRoutine(String routineId) {
    _routines.removeWhere((r) => r.id == routineId);
    saveData();
    notifyListeners();
  }

  /// Sauvegarde toutes les données
  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarde les routines
      final routinesJson = jsonEncode(_routines.map((r) => r.toJson()).toList());
      await prefs.setString('routines', routinesJson);

      // Sauvegarde Leafle
      await prefs.setString('leafle', jsonEncode(_leafle.toJson()));

      // Sauvegarde la forêt
      await prefs.setString('forest', jsonEncode(_forest.toJson()));

      // Sauvegarde les anti-routines
      final antiJson = jsonEncode(_antiRoutines.map((a) => a.toJson()).toList());
      await prefs.setString('antiRoutines', antiJson);

      // Sauvegarde les notes de journée
      final ratingsJson = jsonEncode(_dayRatings.map((r) => r.toJson()).toList());
      await prefs.setString('dayRatings', ratingsJson);

      // Sauvegarde les points et la date
      await prefs.setInt('totalPoints', _totalPoints);
      await prefs.setString('lastUpdateDate', _lastUpdateDate.toIso8601String());
      await prefs.setInt('dayStartHour', _dayStartHour);
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
    }
  }

  /// Charge toutes les données sauvegardées
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charge les routines
      final routinesJson = prefs.getString('routines');
      if (routinesJson != null) {
        final List<dynamic> routinesList = jsonDecode(routinesJson);
        _routines = routinesList.map((json) => Routine.fromJson(json as Map<String, dynamic>)).toList();
      }

      // Charge Leafle
      final leafleJson = prefs.getString('leafle');
      if (leafleJson != null) {
        _leafle = Leafle.fromJson(jsonDecode(leafleJson));
      }

      // Charge la forêt
      final forestJson = prefs.getString('forest');
      if (forestJson != null) {
        _forest = Forest.fromJson(jsonDecode(forestJson));
      }

      // Charge les anti-routines
      final antiJson = prefs.getString('antiRoutines');
      if (antiJson != null) {
        final List<dynamic> list = jsonDecode(antiJson);
        _antiRoutines = list.map((json) => AntiRoutine.fromJson(json as Map<String, dynamic>)).toList();
      }

      // Charge les notes de journée
      final ratingsJson = prefs.getString('dayRatings');
      if (ratingsJson != null) {
        final List<dynamic> list = jsonDecode(ratingsJson);
        _dayRatings = list.map((json) => DayRating.fromJson(json as Map<String, dynamic>)).toList();
      }

      // Charge les points et la date
      _totalPoints = prefs.getInt('totalPoints') ?? 0;
      _dayStartHour = (prefs.getInt('dayStartHour') ?? 3).clamp(0, 23);
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      final lastUpdateStr = prefs.getString('lastUpdateDate');
      if (lastUpdateStr != null) {
        _lastUpdateDate = DateTime.parse(lastUpdateStr);
      }

      // Met à jour l'état quotidien
      updateDailyState();

      if (_notificationsEnabled) {
        await NotificationService.instance.initialize();
        await NotificationService.instance.scheduleDailyReminder(_dayStartHour);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
    } finally {
      if (!_loadedCompleter.isCompleted) {
        _loadedCompleter.complete();
      }
    }
  }

  /// Réinitialise toutes les données (pour debug/test)
  Future<void> resetAll() async {
    _routines.clear();
    _initializeDefaultRoutines();
    _antiRoutines.clear();
    _initializeDefaultAntiRoutines();
    _leafle = Leafle();
    _forest = Forest();
    _totalPoints = 0;
    _lastUpdateDate = DateTime.now();
    _dayStartHour = 3;
    _notificationsEnabled = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    saveData();
    notifyListeners();
  }

  Future<void> setDayStartHour(int hour) async {
    if (hour < 0 || hour > 23 || hour == _dayStartHour) return;
    _dayStartHour = hour;
    updateDailyState();
    if (_notificationsEnabled) {
      await NotificationService.instance.scheduleDailyReminder(_dayStartHour);
    }
    await saveData();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    if (enabled) {
      await NotificationService.instance.initialize();
      await NotificationService.instance.scheduleDailyReminder(_dayStartHour);
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
    await saveData();
    notifyListeners();
  }
}
