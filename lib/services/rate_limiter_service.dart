/*
 * Music Sharity - Share music across all platforms
 * Copyright (C) 2026 Sikelio (Byte Roast)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class RateLimiterService {
  static const int maxRequests = 10;
  static const Duration windowDuration = Duration(minutes: 1);
  static const String _storageKey = 'rate_limiter_timestamps';

  final List<DateTime> _requestTimestamps = [];
  final StreamController<int> _quotaController =
      StreamController<int>.broadcast();

  bool _isInitialized = false;

  static final RateLimiterService _instance = RateLimiterService._internal();

  factory RateLimiterService() => _instance;

  RateLimiterService._internal() {
    _loadTimestamps();
  }

  Future<void> _loadTimestamps() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedTimestamps = prefs.getStringList(_storageKey);

      if (savedTimestamps != null) {
        _requestTimestamps.clear();

        for (final timestamp in savedTimestamps) {
          final dateTime = DateTime.parse(timestamp);

          if (DateTime.now().difference(dateTime) <= windowDuration) {
            _requestTimestamps.add(dateTime);
          }
        }

        _requestTimestamps.sort();
      }
    } catch (e) {
      // We do nothing and continue
    }

    _isInitialized = true;
    _quotaController.add(remainingQuota);
  }

  Future<void> _saveTimestamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamps = _requestTimestamps
          .map((dt) => dt.toIso8601String())
          .toList();

      await prefs.setStringList(_storageKey, timestamps);
    } catch (e) {
      // We do nothing and continue
    }
  }

  Stream<int> get quotaStream => _quotaController.stream;

  void _cleanOldTimestamps() {
    final now = DateTime.now();

    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > windowDuration,
    );
  }

  Future<void> ensureInitialized() async {
    await _loadTimestamps();
  }

  int get remainingQuota {
    _cleanOldTimestamps();

    final remaining = maxRequests - _requestTimestamps.length;

    return remaining < 0 ? 0 : remaining;
  }

  Duration? get timeUntilNextAvailable {
    _cleanOldTimestamps();

    if (_requestTimestamps.isEmpty || _requestTimestamps.length < maxRequests) {
      return null;
    }

    final oldestRequest = _requestTimestamps.first;
    final timeElapsed = DateTime.now().difference(oldestRequest);
    final waitTime = windowDuration - timeElapsed;

    return waitTime.isNegative ? Duration.zero : waitTime;
  }

  bool canMakeRequest() {
    _cleanOldTimestamps();

    return _requestTimestamps.length < maxRequests;
  }

  void recordRequest() {
    _requestTimestamps.add(DateTime.now());
    _quotaController.add(remainingQuota);

    _saveTimestamps();
  }

  Future<T> executeWithRateLimit<T>(Future<T> Function() request) async {
    await _loadTimestamps();

    if (!canMakeRequest()) {
      final waitTime = timeUntilNextAvailable;

      if (waitTime != null) {
        throw RateLimitException(
          'Rate limit exceeded. Please wait ${waitTime.inSeconds} seconds.',
          waitTime,
        );
      }
    }

    recordRequest();

    return await request();
  }

  void dispose() {
    _quotaController.close();
  }
}

class RateLimitException implements Exception {
  final String message;
  final Duration waitTime;

  RateLimitException(this.message, this.waitTime);

  @override
  String toString() => message;
}
