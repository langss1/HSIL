import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/leave_request.dart';
import '../../providers/leave_provider.dart';
import '../../../core/themes/color_palette.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().fetchAllLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Riwayat Perizinan',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.deepNavy,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : AppColors.deepNavy,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: _selectedDate != null ? AppColors.safetyOrange : (isDark ? Colors.white : AppColors.deepNavy),
              ),
              tooltip: 'Filter Tanggal',
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark 
                            ? const ColorScheme.dark(primary: AppColors.safetyOrange)
                            : const ColorScheme.light(primary: AppColors.safetyOrange),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            if (_selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.redAccent),
                tooltip: 'Hapus Filter',
                onPressed: () => setState(() => _selectedDate = null),
              ),
          ],
          bottom: TabBar(
            isScrollable: false,
            labelColor: AppColors.safetyOrange,
            unselectedLabelColor: isDark ? Colors.white54 : AppColors.textSecondary,
            indicatorColor: AppColors.safetyOrange,
            dividerColor: Colors.transparent, // Fix the annoying black line
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Pending'),
              Tab(text: 'Di-ACC'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: provider.isLoading && provider.allLeaves.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.safetyOrange))
            : TabBarView(
                children: [
                  _buildList(provider.allLeaves, isDark),
                  _buildList(provider.pendingLeaves, isDark),
                  _buildList(provider.approvedLeaves, isDark),
                  _buildList(provider.rejectedLeaves, isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<LeaveRequest> leaves, bool isDark) {
    // Filter by date if a date is selected
    final filteredLeaves = _selectedDate == null 
        ? leaves 
        : leaves.where((l) {
            final searchDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
            // Simple check if selected date matches either start or end date
            // For a robust system, we would parse and check if it falls within the range
            return l.startDate == searchDateStr || l.endDate == searchDateStr;
          }).toList();

    if (filteredLeaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text(
              _selectedDate == null ? 'Tidak ada data perizinan.' : 'Tidak ada perizinan di tanggal tersebut.',
              style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<LeaveProvider>().fetchAllLeaves(),
      color: AppColors.safetyOrange,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(20),
        itemCount: filteredLeaves.length,
        itemBuilder: (context, index) {
          final leave = filteredLeaves[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.deepNavy.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.deepNavy.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          leave.employeeName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: isDark ? Colors.white : AppColors.deepNavy,
                          ),
                        ),
                      ),
                      _buildStatusPill(leave.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.date_range_rounded, size: 16, color: AppColors.safetyOrange.withValues(alpha: 0.8)),
                      const SizedBox(width: 8),
                      Text(
                        '${leave.startDate} s/d ${leave.endDate}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondary, 
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCardLight : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tipe: ',
                              style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 13),
                            ),
                            Text(
                              leave.type.name.toUpperCase(),
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.deepNavy, 
                                fontSize: 13, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alasan: ',
                              style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary, fontSize: 13),
                            ),
                            Expanded(
                              child: Text(
                                leave.reason,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.deepNavy, 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusPill(LeaveStatus status) {
    Color color;
    String text;

    switch (status) {
      case LeaveStatus.approved:
        color = AppColors.success;
        text = 'Di-ACC';
        break;
      case LeaveStatus.rejected:
        color = Colors.redAccent;
        text = 'Ditolak';
        break;
      case LeaveStatus.pending:
      default:
        color = AppColors.safetyOrange;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
