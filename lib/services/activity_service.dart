import 'package:flutter/foundation.dart';
import '../models/activity.dart';

class ActivityService extends ChangeNotifier {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final List<Activity> _activities = [];

  List<Activity> get activities => List.unmodifiable(_activities);

  void addActivity(Activity activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void removeActivity(String id) {
    _activities.removeWhere((activity) => activity.id == id);
    notifyListeners();
  }

  void setActivities(List<Activity> activities) {
    _activities.clear();
    _activities.addAll(activities);
    notifyListeners();
  }

  void clearActivities() {
    _activities.clear();
    notifyListeners();
  }

  Activity? getActivityById(String id) {
    try {
      return _activities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Activity> getActivitiesSortedByDistance() {
    final sorted = List<Activity>.from(_activities);
    sorted.sort((a, b) => a.distance.compareTo(b.distance));
    return sorted;
  }
}