import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Selectable base maps for the Track screen.
///
/// Usage notes (check each provider's terms before a public release):
/// - Standard: OpenStreetMap tile server (light use only, see
///   https://operations.osmfoundation.org/policies/tiles/).
/// - Satellite: Esri World Imagery, free for development with attribution.
///   Use a licensed key/provider for high-volume production use.
/// - Terrain: OpenTopoMap (CC-BY-SA), tiles stop at zoom 17.
///
/// Tiles are only fetched up to [maxNativeZoom]; closer zoom levels
/// enlarge those tiles instead of going blank.
enum TrackMapStyle {
  standard(
    label: 'Standard',
    description: 'Streets and places',
    icon: LucideIcons.map,
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    maxNativeZoom: 19,
    attribution: 'OpenStreetMap contributors',
  ),
  satellite(
    label: 'Satellite',
    description: 'Aerial imagery',
    icon: LucideIcons.satellite,
    // Esri uses {z}/{y}/{x} order.
    urlTemplate:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    maxNativeZoom: 18,
    attribution: 'Esri, Maxar, Earthstar Geographics',
  ),
  terrain(
    label: 'Terrain',
    description: 'Contours and trails',
    icon: LucideIcons.mountain,
    urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    maxNativeZoom: 17,
    attribution: 'OpenTopoMap (CC-BY-SA), OpenStreetMap contributors',
  );

  final String label;
  final String description;
  final IconData icon;
  final String urlTemplate;
  final int maxNativeZoom;
  final String attribution;

  const TrackMapStyle({
    required this.label,
    required this.description,
    required this.icon,
    required this.urlTemplate,
    required this.maxNativeZoom,
    required this.attribution,
  });
}
