import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/point_category.dart';

/// A single water point as stored in the Supabase `point` table.
///
/// The table exposes `latitude` / `longitude` as plain double columns, so no
/// PostGIS parsing is needed on the client.
class WaterPoint {
  const WaterPoint({
    required this.id,
    required this.region,
    required this.tags,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.osmId,
    this.amenity,
    this.name,
    this.wheelchair,
    this.fee,
    this.access,
    this.openingHours,
  });

  final int id;
  final String? osmId;
  final String? amenity;
  final String? name;
  final String? wheelchair;
  final String? fee;
  final String? access;
  final String? openingHours;
  final String region;
  final Map<String, dynamic> tags;
  final String type;
  final String status;
  final double latitude;
  final double longitude;

  static const WaterPoint empty = WaterPoint(
    id: 0,
    region: '',
    tags: {},
    type: '',
    status: 'active',
    latitude: 0,
    longitude: 0,
  );

  /// UI category derived from the OSM amenity (falling back to `type`).
  PointCategory get category => PointCategoryX.fromAmenity(amenity ?? type);

  /// Best human-readable title for the point (localized).
  String title(AppLocalizations l) =>
      (name != null && name!.trim().isNotEmpty)
          ? name!.trim()
          : category.label(l);

  factory WaterPoint.fromJson(Map<String, dynamic> json) {
    return WaterPoint(
      id: (json['id'] as num).toInt(),
      osmId: json['osm_id'] as String?,
      amenity: json['amenity'] as String?,
      name: json['name'] as String?,
      wheelchair: json['wheelchair'] as String?,
      fee: json['fee'] as String?,
      access: json['access'] as String?,
      openingHours: json['opening_hours'] as String?,
      region: (json['region'] as String?) ?? '',
      tags: json['tags'] is Map
          ? Map<String, dynamic>.from(json['tags'] as Map)
          : <String, dynamic>{},
      type: (json['type'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'active',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'osm_id': osmId,
      'amenity': amenity,
      'name': name,
      'wheelchair': wheelchair,
      'fee': fee,
      'access': access,
      'opening_hours': openingHours,
      'region': region,
      'tags': tags,
      'type': type,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  WaterPoint copyWith({
    int? id,
    String? osmId,
    String? amenity,
    String? name,
    String? wheelchair,
    String? fee,
    String? access,
    String? openingHours,
    String? region,
    Map<String, dynamic>? tags,
    String? type,
    String? status,
    double? latitude,
    double? longitude,
  }) {
    return WaterPoint(
      id: id ?? this.id,
      osmId: osmId ?? this.osmId,
      amenity: amenity ?? this.amenity,
      name: name ?? this.name,
      wheelchair: wheelchair ?? this.wheelchair,
      fee: fee ?? this.fee,
      access: access ?? this.access,
      openingHours: openingHours ?? this.openingHours,
      region: region ?? this.region,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WaterPoint &&
        other.id == id &&
        other.amenity == amenity &&
        other.name == name &&
        other.status == status &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode =>
      Object.hash(id, amenity, name, status, latitude, longitude);

  @override
  String toString() =>
      'WaterPoint(id: $id, name: $name, amenity: $amenity, '
      'lat: $latitude, lng: $longitude)';
}
