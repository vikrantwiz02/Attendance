import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/attendance_log.dart';
import '../providers/service_providers.dart';

/// Attendance history page showing all clock in/out records
class AttendanceHistoryPage extends ConsumerStatefulWidget {
  const AttendanceHistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends ConsumerState<AttendanceHistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<AttendanceLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Default to last 7 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 7));
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final repo = ref.read(attendanceRepositoryProvider);
    final logs = await repo.getAttendanceHistory(
      startDate: _startDate,
      endDate: _endDate,
    );
    
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDateFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance records found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clock in/out to create records',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Group logs by date
    final groupedLogs = <String, List<AttendanceLog>>{};
    for (final log in _logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.clientTimestamp);
      groupedLogs.putIfAbsent(dateKey, () => []).add(log);
    }

    return ListView.builder(
      itemCount: groupedLogs.length,
      itemBuilder: (context, index) {
        final dateKey = groupedLogs.keys.elementAt(index);
        final logsForDate = groupedLogs[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              ...logsForDate.map((log) => _buildLogItem(log)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogItem(AttendanceLog log) {
    final isClockIn = log.actionType == AttendanceActionType.clockIn;
    final time = DateFormat('HH:mm:ss').format(log.clientTimestamp);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isClockIn ? Colors.green[100] : Colors.red[100],
        child: Icon(
          isClockIn ? Icons.login : Icons.logout,
          color: isClockIn ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        isClockIn ? 'Clock In' : 'Clock Out',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: $time'),
          if (log.latitude != null && log.longitude != null)
            Text('Location: ${log.latitude!.toStringAsFixed(4)}, ${log.longitude!.toStringAsFixed(4)}'),
          if (log.remarks != null && log.remarks!.isNotEmpty)
            Text('Remarks: ${log.remarks}'),
        ],
      ),
      trailing: _buildSyncStatus(log),
    );
  }

  Widget _buildSyncStatus(AttendanceLog log) {
    switch (log.syncStatus) {
      case SyncStatus.synced:
        return Icon(Icons.cloud_done, color: Colors.green[700]);
      case SyncStatus.pending:
        return Icon(Icons.cloud_upload, color: Colors.orange[700]);
      case SyncStatus.failed:
        return Icon(Icons.cloud_off, color: Colors.red[700]);
    }
  }

  Future<void> _showDateFilterDialog() async {
    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) => _DateFilterDialog(
        startDate: _startDate,
        endDate: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result['start'];
        _endDate = result['end'];
      });
      _loadHistory();
    }
  }
}

class _DateFilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const _DateFilterDialog({
    required this.startDate,
    required this.endDate,
  });

  @override
  State<_DateFilterDialog> createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<_DateFilterDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.startDate;
    _end = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text(_start != null ? DateFormat('MMM d, yyyy').format(_start!) : 'Not set'),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _start ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _start = date);
            },
          ),
          ListTile(
            title: const Text('End Date'),
            subtitle: Text(_end != null ? DateFormat('MMM d, yyyy').format(_end!) : 'Not set'),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _end ?? DateTime.now(),
                firstDate: _start ?? DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _end = date);
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _end = DateTime.now();
                    _start = _end!.subtract(const Duration(days: 7));
                  });
                },
                child: const Text('Last 7 days'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _end = DateTime.now();
                    _start = _end!.subtract(const Duration(days: 30));
                  });
                },
                child: const Text('Last 30 days'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {'start': _start, 'end': _end});
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
