import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../dashboard/presentation/widgets/location_permission_dialog.dart';
import '../../data/track_config.dart';
import '../../data/track_map_style.dart';
import '../providers/track_provider.dart';
import '../widgets/track_active_stats_sheet.dart';
import '../widgets/track_locate_button.dart';
import '../widgets/track_map_style_button.dart';
import '../widgets/track_map_view.dart';
import '../widgets/track_start_button.dart';
import '../widgets/track_summary_dialog.dart';

/// Full-screen live GPS tracking screen matching designs:
/// - 30_Light_track.png: Idle state with map, user pin, locate button, START button
/// - 31_Light_track - steps counter active.png: Tracking state with polyline, stats sheet, Stop button
class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final MapController _mapController = MapController();
  bool _hasCheckedPermission = false;
  TrackMapStyle _mapStyle = TrackMapStyle.standard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndInit();
    });
  }

  Future<void> _checkPermissionsAndInit() async {
    if (_hasCheckedPermission) return;
    _hasCheckedPermission = true;

    final permissions = PermissionService.instance;
    final hasLoc = await permissions.hasLocation();

    if (!hasLoc) {
      if (!mounted) return;
      final granted = await LocationPermissionDialog.show(context);
      if (granted != true) {
        AppToast.info('Location access is required for live route tracking');
        return;
      }
    }

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      if (!mounted) return;
      _showEnableGpsDialog();
      return;
    }

    if (!mounted) return;
    final provider = context.read<TrackProvider>();
    await provider.initLocation();

    if (provider.currentPosition != null && mounted) {
      _mapController.move(provider.currentPosition!, TrackConfig.trackingZoom);
    }
  }

  Future<void> _showEnableGpsDialog() async {
    final p = AppPalette.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enable Location Services',
          style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Device GPS is currently turned off. Please turn on location services to track your route.',
          style: TextStyle(color: p.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openLocationSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStart({bool simulate = false}) async {
    final permissions = PermissionService.instance;
    if (!await permissions.hasLocation()) {
      if (!mounted) return;
      final granted = await LocationPermissionDialog.show(context);
      if (granted != true) {
        AppToast.info('Location permission needed to start tracking');
        return;
      }
    }

    if (!mounted) return;
    final provider = context.read<TrackProvider>();
    await provider.startTracking(simulateInStaging: simulate);

    if (provider.currentPosition != null) {
      _mapController.move(provider.currentPosition!, TrackConfig.trackingZoom);
    }
  }

  Future<void> _handleStop() async {
    final provider = context.read<TrackProvider>();
    final session = await provider.stopTracking();
    if (session != null && mounted) {
      await TrackSummaryDialog.show(context, session);
    }
  }

  void _handleLocate() {
    final provider = context.read<TrackProvider>();
    provider.setAutoFollow(true);
    final target = provider.currentPosition ??
        (AppConfig.isStaging
            ? TrackConfig.stagingMockCenter
            : TrackConfig.defaultCenter);
    _mapController.move(target, TrackConfig.trackingZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackProvider>(
      builder: (context, track, child) {
        // Auto-follow map centering when new points are accepted
        if (track.isTracking && track.isAutoFollow && track.currentPosition != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(track.currentPosition!, TrackConfig.trackingZoom);
            }
          });
        }

        final initialCenter = track.currentPosition ??
            (AppConfig.isStaging
                ? TrackConfig.stagingMockCenter
                : TrackConfig.defaultCenter);

        return Stack(
          children: [
            // 1. Full-screen OpenStreetMap view
            Positioned.fill(
              child: TrackMapView(
                mapController: _mapController,
                center: initialCenter,
                zoom: track.currentPosition != null ? TrackConfig.trackingZoom : TrackConfig.defaultZoom,
                polylinePoints: track.polylinePoints,
                currentPosition: track.currentPosition,
                startPosition: track.startPosition,
                isTracking: track.isTracking,
                mapStyle: _mapStyle,
                // Keep the credit clear of START button / stats sheet.
                bottomInset: track.isTracking ? 215 : 90,
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    track.setAutoFollow(false);
                  }
                },
              ),
            ),

            // Map type switcher (Standard / Satellite / Terrain), top right
            Positioned(
              right: 20,
              top: 16,
              child: TrackMapStyleButton(
                style: _mapStyle,
                onChanged: (style) => setState(() => _mapStyle = style),
              ),
            ),

            // 2. Floating Round Purple Locate Button (bottom right)
            Positioned(
              right: 20,
              bottom: track.isTracking ? 220 : 96,
              child: TrackLocateButton(
                onTap: _handleLocate,
                isTracking: track.isTracking,
              ),
            ),

            // 3. Staging-only Mock GPS Simulation trigger
            if (AppConfig.isStaging && !track.isTracking)
              Positioned(
                left: 20,
                bottom: 96,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: IconButton(
                    tooltip: 'Simulate Walking Route (Staging Only)',
                    icon: const Icon(
                      LucideIcons.route,
                      color: AppColors.primaryPurple,
                      size: 22,
                    ),
                    onPressed: () => _handleStart(simulate: true),
                  ),
                ),
              ),

            // 4. Idle state: Big START Button (Design 30)
            if (!track.isTracking)
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: TrackStartButton(
                  onTap: () => _handleStart(simulate: false),
                ),
              ),

            // 5. Active state: Stats Sheet + Stop Button (Design 31)
            if (track.isTracking)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TrackActiveStatsSheet(
                  steps: track.steps,
                  formattedTime: track.formattedDuration,
                  kcal: track.kcal,
                  distanceKm: track.distanceKm,
                  onStop: _handleStop,
                ),
              ),
          ],
        );
      },
    );
  }
}
