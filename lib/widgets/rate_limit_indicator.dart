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
import 'package:flutter/material.dart';
import '../services/odesli_service.dart';
import '../services/rate_limiter_service.dart';

class RateLimitIndicator extends StatefulWidget {
  const RateLimitIndicator({super.key});

  @override
  State<RateLimitIndicator> createState() => _RateLimitIndicatorState();
}

class _RateLimitIndicatorState extends State<RateLimitIndicator> {
  final OdesliService _odesliService = OdesliService();
  final RateLimiterService _rateLimiter = RateLimiterService();

  bool _isInitialized = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _rateLimiter.ensureInitialized();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      _startRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final remaining = _odesliService.remainingQuota;
    final total = RateLimiterService.maxRequests;
    final percentage = remaining / total;

    Color indicatorColor;
    IconData icon;

    if (percentage >= 0.7) {
      indicatorColor = Colors.green;
      icon = Icons.check_circle;
    } else if (percentage >= 0.3) {
      indicatorColor = Colors.orange;
      icon = Icons.warning_amber_rounded;
    } else {
      indicatorColor = Colors.red;
      icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: indicatorColor),
          const SizedBox(width: 6),
          Text(
            '$remaining/$total requests',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: indicatorColor,
            ),
          ),
          if (remaining <= 2) ...[
            const SizedBox(width: 8),
            Text(
              _getWaitTimeText(),
              style: TextStyle(
                fontSize: 11,
                color: indicatorColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getWaitTimeText() {
    final waitTime = _odesliService.timeUntilNextRequest;

    if (waitTime == null) return '';

    final seconds = waitTime.inSeconds;

    if (seconds < 60) {
      return '(${seconds}s)';
    } else {
      final minutes = (seconds / 60).ceil();

      return '(${minutes}min)';
    }
  }
}
