/// A single status report left on a point (`public.report`).
class Report {
  const Report({
    required this.id,
    required this.pointId,
    required this.reportedCondition,
    required this.status,
    required this.createdAt,
    this.userId,
    this.description,
  });

  final int id;
  final int pointId;
  final String? userId;
  final String reportedCondition;
  final String? description;
  final String status;
  final DateTime createdAt;

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: (json['id'] as num).toInt(),
      pointId: (json['point_id'] as num).toInt(),
      userId: json['user_id'] as String?,
      reportedCondition: (json['reported_condition'] as String?) ?? '',
      description: json['description'] as String?,
      status: (json['status'] as String?) ?? 'new',
      createdAt:
          DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Report(id: $id, pointId: $pointId, condition: $reportedCondition)';
}
