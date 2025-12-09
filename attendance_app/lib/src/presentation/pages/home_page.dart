import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/attendance_log.dart';
import '../providers/service_providers.dart';
import '../widgets/sync_status_banner.dart';
import 'attendance_history_page.dart';
import 'profile_page.dart';

/// Main home page with clock in/out functionality
class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isClockingIn = false;
  AttendanceLog? _latestLog;

  @override
  void initState() {
    super.initState();
    _loadLatestLog();
  }

  Future<void> _loadLatestLog() async {
    final repo = ref.read(attendanceRepositoryProvider);
    final log = await repo.getLatestLog();
    setState(() => _latestLog = log);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AttendanceHistoryPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sync status banner
          const SyncStatusBanner(),

          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clock status display
                  _buildStatusDisplay(),
                  const SizedBox(height: 40),

                  // Clock in/out button
                  _buildClockButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDisplay() {
    final isClockedIn = _latestLog != null &&
        _latestLog!.actionType == AttendanceActionType.clockIn;

    return Column(
      children: [
        Icon(
          Icons.access_time,
          size: 80,
          color: isClockedIn ? Colors.green : Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          isClockedIn ? 'Clocked In' : 'Clocked Out',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_latestLog != null) ...[
          const SizedBox(height: 8),
          Text(
            _formatDateTime(_latestLog!.clientTimestamp),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildClockButton() {
    final isClockedIn = _latestLog != null &&
        _latestLog!.actionType == AttendanceActionType.clockIn;

    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        onPressed: _isClockingIn ? null : _handleClockAction,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isClockedIn ? Colors.orange : Colors.green,
        ),
        child: _isClockingIn
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isClockedIn ? Icons.logout : Icons.login,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isClockedIn ? 'Clock Out' : 'Clock In',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleClockAction() async {
    setState(() => _isClockingIn = true);

    try {
      // Get current location
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();

      // Check geofence (for demo, using a hardcoded office location)
      final isWithinGeofence = locationService.isWithinGeofence(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        geofenceLatitude: 37.7749, // Replace with actual office location
        geofenceLongitude: -122.4194,
        radiusMeters: 100,
      );

      final distance = locationService.getDistanceFromGeofence(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        geofenceLatitude: 37.7749,
        geofenceLongitude: -122.4194,
      );

      // Determine action type
      final isClockedIn = _latestLog != null &&
          _latestLog!.actionType == AttendanceActionType.clockIn;
      final actionType = isClockedIn
          ? AttendanceActionType.clockOut
          : AttendanceActionType.clockIn;

      // Execute clock action
      final useCase = ref.read(clockActionUseCaseProvider);
      final newLog = await useCase.execute(
        actionType: actionType,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        withinGeofence: isWithinGeofence,
        distanceFromGeofence: distance,
      );

      // Update UI
      setState(() {
        _latestLog = newLog;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actionType == AttendanceActionType.clockIn
                  ? 'Clocked in successfully!'
                  : 'Clocked out successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Show warning if not within geofence
      if (!isWithinGeofence && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: You are ${distance.toStringAsFixed(0)}m from the office',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isClockingIn = false);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')} on '
        '${local.day}/${local.month}/${local.year}';
  }
}
