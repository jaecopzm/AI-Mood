import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/connectivity_service.dart';
import '../config/premium_theme.dart';

/// Provider for connectivity status
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivityService = ConnectivityService();
  return connectivityService.connectivityStream;
});

/// Banner widget to show connectivity status
class ConnectivityBanner extends ConsumerWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (isConnected) => Column(
        children: [
          if (!isConnected) _buildOfflineBanner(),
          Expanded(child: child),
        ],
      ),
      loading: () => child,
      error: (_, __) => child,
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spaceMd,
        vertical: PremiumTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white, size: 20),
            const SizedBox(width: PremiumTheme.spaceSm),
            Expanded(
              child: Text(
                'You\'re offline. Using cached messages and templates.',
                style: PremiumTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.info_outline,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
