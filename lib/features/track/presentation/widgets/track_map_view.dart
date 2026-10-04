import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/track_config.dart';

/// Interactive OpenStreetMap widget rendering live polyline, start marker,
/// and current user location pin.
class TrackMapView extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final double zoom;
  final List<LatLng> polylinePoints;
  final LatLng? currentPosition;
  final LatLng? startPosition;
  final bool isTracking;
  final void Function(MapCamera camera, bool hasGesture)? onPositionChanged;

  const TrackMapView({
    super.key,
    required this.mapController,
    required this.center,
    this.zoom = 16.0,
    this.polylinePoints = const [],
    this.currentPosition,
    this.startPosition,
    this.isTracking = false,
    this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    // 1. Starting position marker (when route has begun)
    if (startPosition != null && isTracking) {
      markers.add(
        Marker(
          point: startPosition!,
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Current position marker (matches design 30 idle avatar / 31 active arrow)
    final userPos = currentPosition ?? center;
    markers.add(
      Marker(
        point: userPos,
        width: 44,
        height: 44,
        child: isTracking
            ? _buildActiveTrackingMarker()
            : _buildIdleLocationMarker(),
      ),
    );

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        // OpenStreetMap raster tiles
        TileLayer(
          urlTemplate: TrackConfig.osmTileUrlTemplate,
          userAgentPackageName: TrackConfig.userAgentPackageName,
          maxZoom: 19,
        ),

        // Route Polyline
        if (polylinePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                strokeWidth: 5.5,
                color: AppColors.primaryPurple,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),

        // Map markers
        MarkerLayer(markers: markers),

        // Mandatory OpenStreetMap attribution per policy
        RichAttributionWidget(
          attributions: const [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  /// Tracking marker: vibrant purple circle with white navigation arrow/heading (design 31).
  Widget _buildActiveTrackingMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Icon(LucideIcons.navigation, color: Colors.white, size: 20),
      ),
    );
  }

  /// Idle marker: purple pin with white center dot (design 30).
  Widget _buildIdleLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        // Inner pin
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(LucideIcons.user, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
