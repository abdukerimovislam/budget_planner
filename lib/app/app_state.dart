import 'package:flutter/material.dart';

import '../data/datasources/local/local_storage_service.dart';

class AppState extends ChangeNotifier {
  bool _isOnboardingCompleted = false;
  bool _isInitialized = false;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isInitialized => _isInitialized;

  Future<void> load() async {
    _isOnboardingCompleted =
        LocalStorageService.instance.getOnboardingCompleted();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    if (_isOnboardingCompleted) return;
    _isOnboardingCompleted = true;
    await LocalStorageService.instance.setOnboardingCompleted(true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _isOnboardingCompleted = false;
    await LocalStorageService.instance.setOnboardingCompleted(false);
    notifyListeners();
  }
}