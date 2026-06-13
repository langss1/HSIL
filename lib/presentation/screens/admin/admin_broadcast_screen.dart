import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/spacing_constants.dart';
import '../../../core/themes/color_palette.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthController>().user;
      if (user == null) throw Exception('Sesi tidak ditemukan.');

      await FirebaseFirestore.instance.collection('broadcast_messages').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'senderId': user.userId,
        'senderName': user.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil dikirim!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pengumuman: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Pengumuman'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: Spacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kirim Notifikasi Massal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              const Text(
                'Pesan yang Anda tulis di sini akan dikirimkan ke seluruh smartphone karyawan yang terdaftar.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: Spacing.xl),
              AppTextField(
                controller: _titleController,
                label: 'Judul Pengumuman',
                hint: 'Cth: Rapat Divisi Diundur',
                icon: Icons.title_rounded,
                validator: (value) =>
                    value?.trim().isEmpty == true ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: Spacing.lg),
              AppTextField(
                controller: _bodyController,
                label: 'Isi Pesan',
                hint: 'Tulis pesan lengkap Anda di sini...',
                icon: Icons.message_rounded,
                maxLines: 5,
                validator: (value) =>
                    value?.trim().isEmpty == true ? 'Pesan harus diisi' : null,
              ),
              const SizedBox(height: Spacing.xxl),
              AppButton(
                label: 'Kirim ke Semua Karyawan',
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
