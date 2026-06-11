import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/leave_request.dart';
import '../../providers/leave_provider.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Perizinan'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Pending'),
              Tab(text: 'Di-ACC'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: provider.isLoading && provider.allLeaves.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildList(provider.allLeaves),
                  _buildList(provider.pendingLeaves),
                  _buildList(provider.approvedLeaves),
                  _buildList(provider.rejectedLeaves),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<LeaveRequest> leaves) {
    if (leaves.isEmpty) {
      return const Center(child: Text('Tidak ada data perizinan.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<LeaveProvider>().fetchAllLeaves(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          final leave = leaves[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          leave.employeeName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      _buildStatusPill(leave.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${leave.startDate} s/d ${leave.endDate}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text('Tipe: ${leave.type.name.toUpperCase()}'),
                  const SizedBox(height: 4),
                  Text('Alasan: ${leave.reason}'),
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
        color = Colors.green;
        text = 'Di-ACC';
        break;
      case LeaveStatus.rejected:
        color = Colors.red;
        text = 'Ditolak';
        break;
      case LeaveStatus.pending:
      default:
        color = Colors.orange;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
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
