import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Peta Kehadiran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: adminProv.isLoading && attendanceList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: Stack(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
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
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Hadir Terpantau',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: attendanceList.isEmpty
                              ? Center(
                                  child: Text(
                                    'Belum ada karyawan yang absen hari ini.',
                                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                  ),
                                )
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: attendanceList.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final record = attendanceList[index];
                                    final isLate = record.status == 'telat';
                                    
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        if (record.clockInLat != null && record.clockInLng != null) {
                                          _mapController?.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                              LatLng(record.clockInLat!, record.clockInLng!), 18
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.bgCardLight : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            if (!isDark)
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.03),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isLate 
                                                    ? AppColors.safetyOrange.withValues(alpha: 0.1) 
                                                    : Colors.green.withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.location_on,
                                                color: isLate ? AppColors.safetyOrange : Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    record.employeeName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? Colors.white : AppColors.deepNavy,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    record.clockIn != null 
                                                        ? DateFormat('HH:mm').format(record.clockIn!)
                                                        : '-',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isDark ? Colors.white54 : Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isLate ? AppColors.safetyOrange : Colors.green,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                record.status.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
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
