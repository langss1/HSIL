import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/leave_request.dart';
import '../../providers/auth_controller.dart';
import '../../providers/leave_provider.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().fetchPendingLeaves();
    });
  }

  Future<void> _review(LeaveRequest leave, bool approved) async {
    final auth = context.read<AuthController>();
    final admin = auth.user;
    if (admin == null) return;

    final provider = context.read<LeaveProvider>();

    final success = await provider.reviewLeave(
      requestId: leave.id,
      adminId: admin.userId,
      adminName: admin.name,
      approved: approved,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.successMessage ?? 'Berhasil')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Gagal')),
        );
      }
    }
  }

  void _showReviewDialog(LeaveRequest leave, bool approved) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi ${approved ? 'Persetujuan' : 'Penolakan'}'),
        content: Text('Anda yakin ingin ${approved ? 'menyetujui' : 'menolak'} izin ${leave.employeeName} dari ${leave.startDate} s/d ${leave.endDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _review(leave, approved);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approved ? Colors.green : Colors.red,
            ),
            child: Text(approved ? 'Setujui' : 'Tolak', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Persetujuan Izin')),
      body: provider.isLoading && provider.pendingLeaves.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchPendingLeaves(),
              child: provider.pendingLeaves.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('Tidak ada pengajuan izin tertunda.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.pendingLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = provider.pendingLeaves[index];
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
                                    Text(
                                      leave.employeeName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text('${leave.startDate} s/d ${leave.endDate}', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Tipe: ${leave.type.name.toUpperCase()}'),
                                const SizedBox(height: 4),
                                Text('Alasan: ${leave.reason}'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showReviewDialog(leave, false),
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showReviewDialog(leave, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        icon: const Icon(Icons.check, color: Colors.white),
                                        label: const Text('Setuju', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
