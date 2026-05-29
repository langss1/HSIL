import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_controller.dart';
import '../providers/location_provider.dart';
import '../widgets/distance_info_card.dart';
import '../widgets/fade_slide.dart';
import '../widgets/location_status_widget.dart';

/// Screen displaying the Google Map with office geofence and user location,
/// GPS validation status, and clock-in/out action.
class GPSValidationScreen extends StatefulWidget {
  const GPSValidationScreen({super.key});

  @override
  State<GPSValidationScreen> createState() => _GPSValidationScreenState();
}

class _GPSValidationScreenState extends State<GPSValidationScreen> {
  GoogleMapController? _mapController;

  static const _officePosition = LatLng(
    AppConstants.officeLatitude,
    AppConstants.officeLongitude,
  );

  @override
  void initState() {
    super.initState();
    // Start GPS tracking after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      locationProvider.onEnterGeofence = _onEnterGeofence;
      locationProvider.onExitGeofence = _onExitGeofence;
      locationProvider.startTracking();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onEnterGeofence() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('🟢 Anda memasuki area kantor'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onExitGeofence() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('🔴 Anda keluar dari area kantor'),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Set<Marker> _buildMarkers(LocationProvider loc) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('office'),
        position: _officePosition,
        infoWindow: InfoWindow(title: AppConstants.officeName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    if (loc.currentResult != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(
            loc.currentResult!.latitude,
            loc.currentResult!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Lokasi Kamu'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    return {
      Circle(
        circleId: const CircleId('officeRadius'),
        center: _officePosition,
        radius: AppConstants.officeRadiusMeters,
        fillColor: AppColors.info.withValues(alpha: 0.08),
        strokeColor: AppColors.info.withValues(alpha: 0.4),
        strokeWidth: 2,
      ),
    };
  }

  void _animateToUser(LocationProvider loc) {
    if (_mapController != null && loc.currentResult != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(loc.currentResult!.latitude, loc.currentResult!.longitude),
          16.5,
        ),
      );
    }
  }

  Future<void> _handleClockAction() async {
    final loc = context.read<LocationProvider>();
    final att = context.read<AttendanceProvider>();
    final auth = context.read<AuthController>();

    if (loc.currentResult == null) return;

    final user = auth.user;
    if (user == null) return;

    bool success;
    if (att.canClockIn) {
      success = await att.clockIn(
        employeeId: user.userId,
        employeeName: user.name,
        gpsResult: loc.currentResult!,
      );
    } else if (att.canClockOut) {
      success = await att.clockOut(gpsResult: loc.currentResult!);
    } else {
      return;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(att.successMessage ?? 'Berhasil!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Refresh weekly stats
      att.refreshWeeklyStats(user.userId);
      // Go back to dashboard
      if (mounted) Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(att.errorMessage ?? 'Gagal!')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    att.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final att = context.watch<AttendanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi GPS'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            loc.stopTracking();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (loc.state == LocationState.ready)
            IconButton(
              icon: const Icon(Icons.my_location_rounded),
              tooltip: 'Lokasi Saya',
              onPressed: () => _animateToUser(loc),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Map ────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _officePosition,
                    zoom: 15.5,
                  ),
                  markers: _buildMarkers(loc),
                  circles: _buildCircles(),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (isDark) {
                      controller.setMapStyle(_darkMapStyle);
                    }
                  },
                ),
                // GPS accuracy overlay
                if (loc.state == LocationState.loading)
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.safetyOrange,
                            ),
                            SizedBox(height: 12),
                            Text('Mendeteksi lokasi GPS...'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom Panel ───────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.deepNavy : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : AppColors.deepNavy.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),

                    // Title
                    FadeSlide(
                      child: Text(
                        'Validasi Lokasi',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color:
                                  isDark ? AppColors.white : AppColors.deepNavy,
                            ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),

                    // Status indicator
                    FadeSlide(
                      delay: const Duration(milliseconds: 80),
                      child: _buildStatusWidget(loc),
                    ),
                    const SizedBox(height: Spacing.md),

                    // Distance info card
                    if (loc.state == LocationState.ready) ...[
                      FadeSlide(
                        delay: const Duration(milliseconds: 160),
                        child: DistanceInfoCard(
                          distanceMeters: loc.distanceMeters,
                          isInArea: loc.isInArea,
                          accuracy: loc.accuracy,
                          lastUpdated: loc.lastUpdated,
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                    ],

                    // Error state
                    if (loc.state == LocationState.error)
                      FadeSlide(
                        delay: const Duration(milliseconds: 160),
                        child: _buildErrorCard(loc),
                      ),

                    // Action button
                    FadeSlide(
                      delay: const Duration(milliseconds: 240),
                      child: _buildActionButton(loc, att),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(LocationProvider loc) {
    if (loc.state == LocationState.loading ||
        loc.state == LocationState.idle) {
      return const LocationStatusWidget(
        isInArea: false,
        distanceMeters: 0,
        isLoading: true,
      );
    }

    if (loc.state == LocationState.error) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_rounded, color: AppColors.error, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loc.errorMessage ?? 'Gagal mendapatkan lokasi',
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LocationStatusWidget(
      isInArea: loc.isInArea,
      distanceMeters: loc.distanceMeters,
    );
  }

  Widget _buildErrorCard(LocationProvider loc) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            loc.errorMessage ?? 'Terjadi kesalahan',
            style: const TextStyle(color: AppColors.error, fontSize: 14),
          ),
          const SizedBox(height: Spacing.sm),
          TextButton.icon(
            onPressed: loc.retry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: TextButton.styleFrom(foregroundColor: AppColors.safetyOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(LocationProvider loc, AttendanceProvider att) {
    final isReady = loc.state == LocationState.ready;
    final isInArea = loc.isInArea;
    final isProcessing = att.actionState == AttendanceActionState.loading;

    String label;
    IconData icon;
    if (att.isComplete) {
      label = 'Absensi Hari Ini Selesai ✅';
      icon = Icons.check_circle_rounded;
    } else if (att.canClockOut) {
      label = 'Clock Out';
      icon = Icons.logout_rounded;
    } else {
      label = 'Clock In';
      icon = Icons.login_rounded;
    }

    final canPress = isReady && isInArea && !isProcessing && !att.isComplete;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canPress ? _handleClockAction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              att.isComplete ? AppColors.success : AppColors.safetyOrange,
          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: canPress ? 4 : 0,
          shadowColor: AppColors.safetyOrange.withValues(alpha: 0.3),
        ),
        child: isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Dark map style for dark theme.
const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#181818"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]
''';
