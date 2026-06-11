import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/leave_request.dart';
import '../providers/auth_controller.dart';
import '../providers/leave_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_dropdown_field.dart';
import '../widgets/app_text_field.dart';
import '../widgets/glass_card.dart';
import '../../core/utils/date_util.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  LeaveType _selectedType = LeaveType.sakit;
  
  File? _evidenceFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.user != null) {
        context.read<LeaveProvider>().fetchMyLeaves(auth.user!.userId);
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime.now().subtract(const Duration(days: 7)), // Allow slight backdate
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _evidenceFile = File(pickedFile.path));
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthController>();
    final user = auth.user;
    if (user == null) return;

    final provider = context.read<LeaveProvider>();
    final success = await provider.submitLeave(
      employeeId: user.userId,
      employeeName: user.name,
      startDate: DateUtil.toDateKey(_startDate),
      endDate: DateUtil.toDateKey(_endDate),
      type: _selectedType,
      reason: _reasonController.text,
      evidenceFile: _evidenceFile,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.successMessage ?? 'Berhasil')),
      );
      _reasonController.clear();
      setState(() => _evidenceFile = null);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<LeaveProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Izin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Isi Formulir Izin', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      
                      // Tanggal
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Rentang Tanggal Izin'),
                        subtitle: Text('${DateFormat('dd MMM yyyy').format(_startDate)} s/d ${DateFormat('dd MMM yyyy').format(_endDate)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDateRange,
                      ),
                      const SizedBox(height: 16),
                      
                      // Tipe Izin
                      AppDropdownField<LeaveType>(
                        value: _selectedType,
                        label: 'Tipe Izin',
                        items: const [
                          DropdownMenuItem(value: LeaveType.sakit, child: Text('Sakit')),
                          DropdownMenuItem(value: LeaveType.cuti, child: Text('Cuti')),
                          DropdownMenuItem(value: LeaveType.keperluanPribadi, child: Text('Keperluan Pribadi')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Alasan
                      AppTextField(
                        controller: _reasonController,
                        label: 'Alasan',
                        icon: Icons.notes,
                        maxLines: 3,
                        validator: (val) {
                          if (val == null || val.trim().length < 10) {
                            return 'Alasan minimal 10 karakter.';
                          }
                          return null;
                        },
                      ),
                      
                      // Bukti / Lampiran
                      const SizedBox(height: 16),
                      Text('Lampiran (Opsional)', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_evidenceFile != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _evidenceFile!,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _evidenceFile = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: _showImagePickerOptions,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.5), style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_rounded, color: Colors.grey),
                                SizedBox(width: 8),
                                Text('Upload Bukti / Surat Dokter', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Submit
                      AppButton(
                        label: 'Ajukan Izin',
                        isLoading: provider.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Riwayat Izin', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            
            if (provider.isLoading && provider.myLeaves.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (provider.myLeaves.isEmpty)
              const Center(child: Text('Belum ada pengajuan.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.myLeaves.length,
                itemBuilder: (context, index) {
                  final leave = provider.myLeaves[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${leave.type.name.toUpperCase()} - ${leave.startDate} s/d ${leave.endDate}'),
                      subtitle: Text(leave.reason),
                      trailing: _buildStatusBadge(leave.status),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(LeaveStatus status) {
    Color color;
    String text;
    switch (status) {
      case LeaveStatus.approved:
        color = Colors.green;
        text = 'Disetujui';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
