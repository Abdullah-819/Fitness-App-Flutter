import 'package:latlong2/latlong.dart';

/// Configuration constants for OpenStreetMap tiles and Live Tracking.
///
/// Tile Usage Policy Note:
/// OpenStreetMap tiles are provided by the OpenStreetMap Foundation free of charge
/// under the tile usage policy (https://operations.osmfoundation.org/policies/tiles/).
/// Heavy automated downloading is prohibited and a valid User-Agent package name
/// is required. For high-volume production use, switch [osmTileUrlTemplate] to a
/// commercial tile provider (e.g. Mapbox, Stadia, Stadia Maps, or self-hosted tile server).
class TrackConfig {
  TrackConfig._();

  /// OpenStreetMap standard tile server URL template.
  /// Can be overridden or swapped for an alternate provider.
  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User-agent package identifier identifying requests per OSM policy.
  static const String userAgentPackageName = 'com.walee.step_counter';

  /// Default fallback map center: Pakistan geographic center.
  static const LatLng defaultCenter = LatLng(30.3753, 69.3451);
  static const double defaultZoom = 5.0;

  /// Zoom level used when focused on the active user location.
  static const double trackingZoom = 16.5;

  /// Default starting position for staging mock route (Washington Sq Park, NY as in designs).
  static const LatLng stagingMockCenter = LatLng(40.7295, -73.9965);
}
