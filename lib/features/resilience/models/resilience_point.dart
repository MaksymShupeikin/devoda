import '../../../core/l10n/app_localizations.dart';

/// A "Пункт незламності" (point of resilience) from the `resilience_points`
/// table. Coordinates are stored as plain `lat` / `lon` doubles (nullable).
class ResiliencePoint {
  const ResiliencePoint({
    required this.id,
    this.name,
    this.status,
    this.heating,
    this.generator,
    this.charging,
    this.water,
    this.internet,
    this.mobileConnection,
    this.firstAid,
    this.accessibility,
    this.type,
    this.oblast,
    this.rayon,
    this.settlement,
    this.address,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String? name;
  final String? status;

  // Available services (raw text values from the dataset).
  final String? heating; // obigriv
  final String? generator; // generator
  final String? charging; // pidzariadk
  final String? water; // voda
  final String? internet; // internet
  final String? mobileConnection; // mob_zvaz
  final String? firstAid; // aptech
  final String? accessibility; // invalid

  final String? type;
  final String? oblast;
  final String? rayon;
  final String? settlement;
  final String? address;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String title(AppLocalizations l) => (name != null && name!.trim().isNotEmpty)
      ? name!.trim()
      : (l.isUk ? 'Пункт незламності' : 'Resilience point');

  /// Best-effort human-readable location line.
  String? get locationLine {
    final parts = [address, settlement, rayon, oblast]
        .where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  factory ResiliencePoint.fromJson(Map<String, dynamic> json) {
    double? toDouble(Object? v) => v == null ? null : (v as num).toDouble();
    String? str(Object? v) => v?.toString();
    return ResiliencePoint(
      id: (json['id'] as num).toInt(),
      name: str(json['name']),
      status: str(json['status']),
      heating: str(json['obigriv']),
      generator: str(json['generator']),
      charging: str(json['pidzariadk']),
      water: str(json['voda']),
      internet: str(json['internet']),
      mobileConnection: str(json['mob_zvaz']),
      firstAid: str(json['aptech']),
      accessibility: str(json['invalid']),
      type: str(json['type']),
      oblast: str(json['oblast']),
      rayon: str(json['rayon']),
      settlement: str(json['settlement']),
      address: str(json['address']),
      latitude: toDouble(json['lat']),
      longitude: toDouble(json['lon']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'obigriv': heating,
    'generator': generator,
    'pidzariadk': charging,
    'voda': water,
    'internet': internet,
    'mob_zvaz': mobileConnection,
    'aptech': firstAid,
    'invalid': accessibility,
    'type': type,
    'oblast': oblast,
    'rayon': rayon,
    'settlement': settlement,
    'address': address,
    'lat': latitude,
    'lon': longitude,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResiliencePoint &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(id, name, latitude, longitude);

  @override
  String toString() => 'ResiliencePoint(id: $id, name: $name)';
}
