import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity and provide offline capabilities
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isConnected = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startPeriodicConnectivityCheck();
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _updateConnectivity(result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } catch (e) {
      _updateConnectivity(false);
    }
  }

  /// Start periodic connectivity checks
  void _startPeriodicConnectivityCheck() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkConnectivity();
    });
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      _updateConnectivity(result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } catch (e) {
      _updateConnectivity(false);
    }
  }

  /// Update connectivity status and notify listeners
  void _updateConnectivity(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(_isConnected);
      debugPrint('🌐 Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}