import 'package:flutter/material.dart';

class ProductVariantSection extends StatelessWidget {
  final bool enableColor;
  final ValueChanged<bool> onColorToggle;
  final TextEditingController colorController;

  final bool enableSize;
  final ValueChanged<bool> onSizeToggle;
  final Set<String> selectedSizes;
  final ValueChanged<String> onSizeSelected;

  final List<String> customSizes;
  final bool showCustomSizeField;
  final VoidCallback onAddCustomSize;
  final TextEditingController customSizeController;
  final VoidCallback onConfirmCustomSize;

  const ProductVariantSection({
    super.key,
    required this.enableColor,
    required this.onColorToggle,
    required this.colorController,
    required this.enableSize,
    required this.onSizeToggle,
    required this.selectedSizes,
    required this.onSizeSelected,
    required this.customSizes,
    required this.showCustomSizeField,
    required this.onAddCustomSize,
    required this.customSizeController,
    required this.onConfirmCustomSize,
  });

  static const _defaultSizes = ['S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorSection(),
        const SizedBox(height: 24),
        _buildSizeSection(),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Warna Produk',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Switch(
              value: enableColor,
              onChanged: onColorToggle,
              activeThumbColor: const Color(0xff2563EB),
            ),
          ],
        ),
        if (enableColor) ...[
          const SizedBox(height: 12),
          TextField(
            controller: colorController,
            decoration: const InputDecoration(
              hintText: 'Contoh: Merah, Biru, Hitam',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ukuran Produk',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Switch(
              value: enableSize,
              onChanged: onSizeToggle,
              activeThumbColor: const Color(0xff2563EB),
            ),
          ],
        ),
        if (enableSize) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._defaultSizes.map((size) => _buildSizeChip(size)),
              ...customSizes.map((size) => _buildSizeChip(size)),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Kustom'),
                onPressed: onAddCustomSize,
              ),
            ],
          ),
          if (showCustomSizeField) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customSizeController,
                    decoration: const InputDecoration(
                      hintText: 'Ukuran custom',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onConfirmCustomSize,
                  icon: const Icon(Icons.check, color: Color(0xff2563EB)),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSizeChip(String size) {
    final isSelected = selectedSizes.contains(size);
    return FilterChip(
      label: Text(size),
      selected: isSelected,
      onSelected: (_) => onSizeSelected(size),
      selectedColor: const Color(0xffEFF6FF),
      checkmarkColor: const Color(0xff2563EB),
      side: BorderSide(
        color: isSelected ? const Color(0xff2563EB) : Colors.grey.shade300,
      ),
    );
  }
}
