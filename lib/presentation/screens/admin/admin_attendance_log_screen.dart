import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/themes/color_palette.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../providers/admin_provider.dart';

class AdminAttendanceLogScreen extends StatefulWidget {
  final AppUser? initialEmployee;

  const AdminAttendanceLogScreen({super.key, this.initialEmployee});

  @override
  State<AdminAttendanceLogScreen> createState() => _AdminAttendanceLogScreenState();
}

class _AdminAttendanceLogScreenState extends State<AdminAttendanceLogScreen> {
  AppUser? _selectedEmployee;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      if (provider.employees.isEmpty) {
        await provider.fetchDashboardData();
      }

      if (widget.initialEmployee != null) {
        final match = provider.employees.firstWhere(
          (e) => e.userId == widget.initialEmployee!.userId,
          orElse: () => widget.initialEmployee!,
        );
        setState(() {
          _selectedEmployee = match;
        });
        _fetchLogs();
      } else if (provider.employees.isNotEmpty) {
        setState(() {
          _selectedEmployee = provider.employees.first;
        });
        _fetchLogs();
      }
    });
  }

  void _fetchLogs() {
    if (_selectedEmployee != null) {
      context.read<AdminProvider>().fetchEmployeeAttendance(
            _selectedEmployee!.userId,
            _startDate,
            _endDate,
          );
    }
  }

  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.safetyOrange,
              onPrimary: AppColors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.white,
            ),
            dialogBackgroundColor: AppColors.bgDark,
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });
      _fetchLogs();
    }
  }

  Future<void> _exportToCSV() async {
    final provider = context.read<AdminProvider>();
    final logs = provider.employeeAttendance;

    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data log kehadiran untuk diexport'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedEmployee == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final List<List<dynamic>> rows = [];

      // Header row
      rows.add([
        'Tanggal',
        'Nama Karyawan',
        'NIK',
        'Status',
        'Jam Masuk (Clock In)',
        'Jarak Masuk (m)',
        'Jam Keluar (Clock Out)',
        'Jarak Keluar (m)',
        'GPS Area Status'
      ]);

      // Log data rows
      final timeFormat = DateFormat('HH:mm:ss');
      for (final log in logs) {
        final dateObj = DateTime.tryParse(log.date) ?? DateTime.now();
        final dateStr = DateFormat('yyyy-MM-dd').format(dateObj);

        rows.add([
          dateStr,
          log.employeeName,
          _selectedEmployee!.nik,
          _getStatusLabel(log.status),
          log.clockIn != null ? timeFormat.format(log.clockIn!.toLocal()) : '-',
          log.clockInDistance != null ? log.clockInDistance!.toStringAsFixed(1) : '-',
          log.clockOut != null ? timeFormat.format(log.clockOut!.toLocal()) : '-',
          log.clockOutDistance != null ? log.clockOutDistance!.toStringAsFixed(1) : '-',
          log.gpsStatus,
        ]);
      }

      // Convert lists to CSV format
      final csvString = csv.encode(rows);

      // Save file in temporary storage
      final directory = await getTemporaryDirectory();
      final dateRangeStr = '${DateFormat('yyyyMMdd').format(_startDate)}_${DateFormat('yyyyMMdd').format(_endDate)}';
      final fileName = 'Laporan_Kehadiran_${_selectedEmployee!.name.replaceAll(' ', '_')}_$dateRangeStr.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);

      // Share CSV file using Share Plus
      final dateRangeText = '${DateFormat('d MMM yyyy', 'id_ID').format(_startDate)} - ${DateFormat('d MMM yyyy', 'id_ID').format(_endDate)}';
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Log Kehadiran ${_selectedEmployee!.name}',
        text: 'Berikut adalah laporan kehadiran untuk ${_selectedEmployee!.name} (${_selectedEmployee!.nik}) periode $dateRangeText.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil diexport dan siap dibagikan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengexport file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  String _getStatusLabel(String status) {
    return switch (status.toLowerCase()) {
      'hadir' => 'Hadir',
      'telat' => 'Terlambat',
      'izin' => 'Izin',
      'alpha' => 'Alpha',
      _ => status.toUpperCase(),
    };
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'hadir' => AppColors.statusHadir,
      'telat' => AppColors.statusTelat,
      'izin' => AppColors.statusIzin,
      'alpha' => AppColors.statusAlpha,
      _ => AppColors.white,
    };
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final dateRangeText = '${DateFormat('d MMM yyyy', 'id_ID').format(_startDate)} - ${DateFormat('d MMM yyyy', 'id_ID').format(_endDate)}';

    return Scaffold(
      backgroundColor: AppColors.bgDarker,
      appBar: AppBar(
        title: const Text('Log Kehadiran Karyawan'),
        centerTitle: true,
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isExporting ? null : _exportToCSV,
        backgroundColor: AppColors.safetyOrange,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
              )
            : const Icon(Icons.download_outlined, color: AppColors.white),
        label: const Text(
          'Export CSV',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter Panel Card
          _buildFilterPanel(adminProv, dateRangeText),
          
          // Result Lists Area
          Expanded(
            child: _buildLogsList(adminProv),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(AdminProvider provider, String dateRangeText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Karyawan
          const Text(
            'Pilih Karyawan',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          provider.employees.isEmpty
              ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.safetyOrange, strokeWidth: 2),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bgCardLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AppUser>(
                      value: _selectedEmployee,
                      isExpanded: true,
                      dropdownColor: AppColors.bgCard,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.safetyOrange),
                      style: const TextStyle(color: AppColors.white, fontSize: 15),
                      hint: const Text('Pilih Karyawan', style: TextStyle(color: AppColors.textSecondary)),
                      items: provider.employees.map((employee) {
                        return DropdownMenuItem<AppUser>(
                          value: employee,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.bgCardLight,
                                backgroundImage: employee.photoUrl != null
                                    ? NetworkImage(employee.photoUrl!)
                                    : null,
                                child: employee.photoUrl == null
                                    ? Text(
                                        employee.name.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  employee.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (employee) {
                        if (employee != null) {
                          setState(() {
                            _selectedEmployee = employee;
                          });
                          _fetchLogs();
                        }
                      },
                    ),
                  ),
                ),
          const SizedBox(height: 16),

          // Date Range Selector
          const Text(
            'Periode Tanggal',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bgCardLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range_outlined, color: AppColors.safetyOrange, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        dateRangeText,
                        style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Icon(Icons.edit_calendar_outlined, color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(AdminProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.safetyOrange),
      );
    }

    if (_selectedEmployee == null) {
      return const Center(
        child: Text(
          'Silakan pilih karyawan terlebih dahulu',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    final logs = provider.employeeAttendance;
    if (logs.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off_outlined, color: AppColors.textSecondary.withOpacity(0.4), size: 72),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada data log kehadiran',
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Untuk periode tanggal yang dipilih',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96), // Extra bottom padding for FAB
      itemCount: logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildAttendanceCard(log);
      },
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord log) {
    final dateObj = DateTime.tryParse(log.date) ?? DateTime.now();
    final dayName = DateFormat('EEEE', 'id_ID').format(dateObj);
    final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(dateObj);
    
    final statusColor = _getStatusColor(log.status);
    final statusLabel = _getStatusLabel(log.status);

    final checkInStr = log.clockIn != null 
        ? DateFormat('HH:mm').format(log.clockIn!.toLocal()) 
        : '--:--';
    
    final checkOutStr = log.clockOut != null 
        ? DateFormat('HH:mm').format(log.clockOut!.toLocal()) 
        : '--:--';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status left bar
              Container(
                width: 6,
                color: statusColor,
              ),
              
              // Log content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayName,
                                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                dateStr,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.bgCardLight, height: 24),
                      
                      // Details Clock In & Out
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.login_outlined, color: AppColors.success, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Masuk (In)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      checkInStr,
                                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    if (log.clockInDistance != null)
                                      Text(
                                        '${log.clockInDistance!.toStringAsFixed(1)}m',
                                        style: TextStyle(
                                          color: log.gpsStatus == 'IN_AREA' ? AppColors.textSecondary : AppColors.error,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.logout_outlined, color: AppColors.error, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Keluar (Out)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      checkOutStr,
                                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    if (log.clockOutDistance != null)
                                      Text(
                                        '${log.clockOutDistance!.toStringAsFixed(1)}m',
                                        style: TextStyle(
                                          color: log.gpsStatus == 'IN_AREA' ? AppColors.textSecondary : AppColors.error,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Extra validation flags (GPS / Area)
                      if (log.clockIn != null || log.clockOut != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              log.gpsStatus == 'IN_AREA' ? Icons.verified_outlined : Icons.report_gmailerrorred_outlined,
                              color: log.gpsStatus == 'IN_AREA' ? AppColors.success : AppColors.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              log.gpsStatus == 'IN_AREA' ? 'Absensi dilakukan di dalam area kantor' : 'Absensi dilakukan di luar area kantor',
                              style: TextStyle(
                                color: log.gpsStatus == 'IN_AREA' ? AppColors.success : AppColors.warning,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
