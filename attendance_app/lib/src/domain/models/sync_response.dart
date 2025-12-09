import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_response.freezed.dart';
part 'sync_response.g.dart';

/// Response from the sync API endpoint
@freezed
class SyncResponse with _$SyncResponse {
  const factory SyncResponse({
    required bool success,
    required List<Map<String, dynamic>> syncedRecords,
    required List<String> failedRecordIds,
    required DateTime serverTimestamp,
    String? message,
  }) = _SyncResponse;

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);
}
