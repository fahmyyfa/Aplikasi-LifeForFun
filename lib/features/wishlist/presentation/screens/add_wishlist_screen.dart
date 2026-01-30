import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../providers/wishlist_provider.dart';

class AddWishlistScreen extends ConsumerStatefulWidget {
  const AddWishlistScreen({super.key});

  @override
  ConsumerState<AddWishlistScreen> createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends ConsumerState<AddWishlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWishlist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Parse price if provided
      double? price;
      if (_priceController.text.isNotEmpty) {
        final priceText = _priceController.text.replaceAll('.', '').replaceAll(',', '');
        price = double.tryParse(priceText);
      }

      // Save to Supabase via provider
      await ref.read(wishlistNotifierProvider.notifier).addWishlistItem(
        name: _nameController.text,
        price: price,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wishlist berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('[AddWishlistScreen] Error saving wishlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: ${_formatErrorMessage(e)}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Format error message for user-friendly display
  String _formatErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.contains('AuthException')) {
      return 'Sesi login telah berakhir. Silakan login kembali.';
    }
    if (message.contains('PostgrestException')) {
      return 'Gagal menyimpan ke database. Periksa koneksi internet Anda.';
    }
    if (message.contains('SocketException') || message.contains('network')) {
      return 'Tidak ada koneksi internet.';
    }
    return message.replaceAll('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Wishlist')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image placeholder
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, 
                      size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 8),
                    Text('Tambah Gambar', style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Nama Barang', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Contoh: iPhone 15 Pro'),
                validator: (v) => v?.isEmpty == true ? 'Masukkan nama barang' : null,
              ),
              const SizedBox(height: 16),

              Text('Harga (Opsional)', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
              ),
              const SizedBox(height: 16),

              Text('Catatan (Opsional)', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Tambahkan catatan...'),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveWishlist,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan Wishlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
