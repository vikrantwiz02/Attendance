import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_request.freezed.dart';
part 'leave_request.g.dart';

enum LeaveType {
  sick,
  personal,
  vacation,
  other,
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
}

/// Represents a leave request
@freezed
class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required String id,
    String? userId,
    required LeaveType leaveType,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    required LeaveStatus status,
    String? approverComment,
    required DateTime createdAt,
    DateTime? approvedAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);
}
