class MonetizationConfig {
  static const int freeMessageLimit = 10;
  
  static const List<String> freeCoachIds = [
    'productivity_coach',
    'deep_work_coach',
    'systems_coach',
  ];

  static bool isCoachFree(String id) {
    return freeCoachIds.contains(id);
  }
}
