import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sync_engine.dart';
import '../providers/service_providers.dart';

/// Banner widget that displays current sync status
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncEngine = ref.watch(syncEngineProvider);

    return StreamBuilder<SyncStatus>(
      stream: syncEngine.syncStatus,
      initialData: SyncStatus.idle,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;

        // Don't show banner if idle
        if (status == SyncStatus.idle) {
          return const SizedBox.shrink();
        }

        final bannerInfo = _getBannerInfo(status, syncEngine.isConnected);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          color: bannerInfo.color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (status == SyncStatus.syncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  bannerInfo.icon,
                  color: Colors.white,
                  size: 16,
                ),
              const SizedBox(width: 12),
              Text(
                bannerInfo.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _BannerInfo _getBannerInfo(SyncStatus status, bool isConnected) {
    if (!isConnected) {
      return _BannerInfo(
        message: 'Offline - Changes will sync when online',
        color: Colors.orange,
        icon: Icons.cloud_off,
      );
    }

    switch (status) {
      case SyncStatus.syncing:
        return _BannerInfo(
          message: 'Syncing data...',
          color: Colors.blue,
          icon: Icons.sync,
        );
      case SyncStatus.synced:
        return _BannerInfo(
          message: 'All changes synced',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case SyncStatus.failed:
        return _BannerInfo(
          message: 'Sync failed - Will retry',
          color: Colors.red,
          icon: Icons.error,
        );
      case SyncStatus.idle:
        return _BannerInfo(
          message: '',
          color: Colors.transparent,
          icon: Icons.info,
        );
    }
  }
}

class _BannerInfo {
  final String message;
  final Color color;
  final IconData icon;

  _BannerInfo({
    required this.message,
    required this.color,
    required this.icon,
  });
}
