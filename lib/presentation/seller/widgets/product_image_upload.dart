import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProductImageUpload extends StatelessWidget {
  final Uint8List? selectedImage;
  final String? existingImageUrl;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const ProductImageUpload({
    super.key,
    this.selectedImage,
    this.existingImageUrl,
    required this.onPickImage,
    this.onRemoveImage,
  });

  bool get _hasImage => selectedImage != null || (existingImageUrl != null && existingImageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (_hasImage) {
      return _buildPreview();
    }
    return _buildUploadArea();
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          border: Border.all(
            color: const Color(0xff2563EB).withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Color(0xff2563EB),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload foto produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PNG, JPG, JPEG (Maks. 5MB)',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text('Pilih Gambar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff2563EB),
                side: const BorderSide(color: Color(0xff2563EB)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: selectedImage != null
                ? Image.memory(
                    selectedImage!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    existingImageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: Colors.grey.shade100,
                      child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Ganti Gambar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff2563EB),
                    side: const BorderSide(color: Color(0xff2563EB)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (onRemoveImage != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onRemoveImage,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
