import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/color_palette.dart';
import '../../providers/admin_provider.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final attendanceList = adminProv.todayAttendance;

    Set<Marker> mapMarkers = {
      // Office marker
      Marker(
        markerId: const MarkerId('office'),
        position: const LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude),
        infoWindow: const InfoWindow(title: 'Kantor Pusat'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    // Add employee markers
    for (var record in attendanceList) {
      if (record.clockInLat != null && record.clockInLng != null) {
        mapMarkers.add(
          Marker(
            markerId: MarkerId(record.id),
            position: LatLng(record.clockInLat!, record.clockInLng!),
            infoWindow: InfoWindow(
              title: record.employeeName,
              snippet: 'Status: ${record.status}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              record.status == 'telat' 
                  ? BitmapDescriptor.hueOrange 
                  : BitmapDescriptor.hueGreen
            ),
          ),
        );
      }
    }

    Set<Circle> mapCircles = {
      Circle(
        circleId: const CircleId('officeRadius'),
        center: const LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude),
        radius: AppConstants.officeRadiusMeters,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Kehadiran Hari Ini'),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
      ),
      body: adminProv.isLoading && attendanceList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude),
                    zoom: 15,
                  ),
                  markers: mapMarkers,
                  circles: mapCircles,
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _LegendItem(color: Colors.blue, text: 'Kantor'),
                        _LegendItem(color: Colors.green, text: 'Tepat Waktu'),
                        _LegendItem(color: Colors.orange, text: 'Terlambat'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
