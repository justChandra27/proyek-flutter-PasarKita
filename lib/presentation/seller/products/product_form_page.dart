import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../../core/services/product_service_appwrite.dart';
import '../../../core/appwrite/appwrite_service.dart';

import 'package:image_picker/image_picker.dart';

import '../../../core/services/storage_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../core/services/category_service_appwrite.dart';
import '../../../data/models/category_model.dart';
import '../widgets/product_form_section.dart';
import '../widgets/product_image_upload.dart';
import '../widgets/seller_tip_card.dart';
import '../widgets/product_variant_section.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final descriptionController = TextEditingController();

  final priceController = TextEditingController();

  final stockController = TextEditingController();

  final weightController = TextEditingController();

  final minPurchaseController = TextEditingController();

  final ProductServiceAppwrite _service = ProductServiceAppwrite();

  bool isLoading = false;

  Uint8List? selectedImage;

  String? uploadedImageUrl;

  final StorageServiceAppwrite _storageService = StorageServiceAppwrite();

  String? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  bool _enableColorVariant = false;
  bool _enableSizeVariant = false;
  final _colorController = TextEditingController();
  final Set<String> _selectedSizes = {};
  final List<String> _customSizes = [];
  bool _showCustomSizeField = false;
  final _customSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      nameController.text = widget.product!.name;
      _selectedCategory = widget.product!.category;
      descriptionController.text = widget.product!.description;
      priceController.text = widget.product!.price.toString();
      stockController.text = widget.product!.stock.toString();
      weightController.text = widget.product!.weight.toStringAsFixed(0);
      minPurchaseController.text = widget.product!.minPurchase.toString();

      uploadedImageUrl = widget.product!.imageUrl;

      if (widget.product!.colors.isNotEmpty) {
        _enableColorVariant = true;
        _colorController.text = widget.product!.colors.join(', ');
      }
      if (widget.product!.sizes.isNotEmpty) {
        _enableSizeVariant = true;
        _selectedSizes.addAll(widget.product!.sizes);
      }
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryServiceAppwrite().getAllCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<String> getCurrentUserId() async {
    final user = await AppwriteService.account.get();

    return user.$id;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      selectedImage = bytes;
    });
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.product == null && selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar produk terlebih dahulu')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final sellerId = await getCurrentUserId();

      String imageUrl;

      // gambar baru dipilih
      if (selectedImage != null) {
        final fileId = await _storageService.uploadImage(
          bytes: selectedImage!,
          fileName: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        imageUrl = _storageService.getImageUrl(fileId);
      }
      // edit produk tanpa ganti gambar
      else {
        imageUrl = widget.product!.imageUrl;
      }

      final category = _selectedCategory ?? '';

      final colors = _enableColorVariant && _colorController.text.isNotEmpty
          ? _colorController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];
      final sizes = _enableSizeVariant ? _selectedSizes.toList() : <String>[];

      if (widget.product == null) {
        await _service.addProduct(
          sellerId: sellerId,
          name: nameController.text.trim(),
          category: category,
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          stock: int.parse(stockController.text.trim()),
          imageUrl: imageUrl,
          weight: double.parse(weightController.text.trim()),
          minPurchase: int.parse(minPurchaseController.text.trim()),
          colors: colors,
          sizes: sizes,
        );
      } else {
        await _service.updateProduct(
          productId: widget.product!.id,
          name: nameController.text.trim(),
          category: category,
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          stock: int.parse(stockController.text.trim()),
          imageUrl: imageUrl,
          active: widget.product!.active,
          weight: double.parse(weightController.text.trim()),
          minPurchase: int.parse(minPurchaseController.text.trim()),
          colors: colors,
          sizes: sizes,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan produk : $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    weightController.dispose();
    minPurchaseController.dispose();
    _colorController.dispose();
    _customSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: isWide ? _buildWebForm() : _buildMobileForm(),
      ),
    );
  }

  Widget _buildWebForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Produk',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ProductFormSection(
                icon: Icons.shopping_bag,
                title: 'Informasi Dasar',
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: _isLoadingCategories
                          ? null
                          : _categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.name,
                                child: Text(cat.name),
                              );
                            }).toList(),
                      onChanged: _isLoadingCategories
                          ? null
                          : (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ProductFormSection(
                icon: Icons.image,
                title: 'Media',
                child: ProductImageUpload(
                  selectedImage: selectedImage,
                  existingImageUrl: widget.product?.imageUrl,
                  onPickImage: pickImage,
                  onRemoveImage: () {
                    setState(() {
                      selectedImage = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              ProductFormSection(
                icon: Icons.description,
                title: 'Deskripsi',
                child: TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Produk',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ProductFormSection(
                icon: Icons.inventory_2,
                title: 'Stok & Informasi Produk',
                child: Column(
                  children: [
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stok',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Berat Produk (gram)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Berat produk wajib diisi';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Berat harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: minPurchaseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minimal Pembelian',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Minimal pembelian wajib diisi';
                        }
                        final min = int.tryParse(value);
                        if (min == null || min < 1) {
                          return 'Minimal pembelian minimal 1';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ProductFormSection(
                icon: Icons.widgets,
                title: 'Varian Produk',
                child: ProductVariantSection(
                  enableColor: _enableColorVariant,
                  onColorToggle: (v) => setState(() => _enableColorVariant = v),
                  colorController: _colorController,
                  enableSize: _enableSizeVariant,
                  onSizeToggle: (v) => setState(() => _enableSizeVariant = v),
                  selectedSizes: _selectedSizes,
                  onSizeSelected: (size) {
                    setState(() {
                      if (_selectedSizes.contains(size)) {
                        _selectedSizes.remove(size);
                      } else {
                        _selectedSizes.add(size);
                      }
                    });
                  },
                  customSizes: _customSizes,
                  showCustomSizeField: _showCustomSizeField,
                  onAddCustomSize: () => setState(() => _showCustomSizeField = true),
                  customSizeController: _customSizeController,
                  onConfirmCustomSize: () {
                    final text = _customSizeController.text.trim();
                    if (text.isNotEmpty && !_customSizes.contains(text)) {
                      setState(() {
                        _customSizes.add(text);
                        _selectedSizes.add(text);
                        _customSizeController.clear();
                        _showCustomSizeField = false;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveProduct,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isLoading
                        ? 'Menyimpan...'
                        : widget.product == null
                        ? 'Simpan Produk'
                        : 'Update Produk',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          ProductImageUpload(
            selectedImage: selectedImage,
            existingImageUrl: widget.product?.imageUrl,
            onPickImage: pickImage,
            onRemoveImage: () {
              setState(() {
                selectedImage = null;
              });
            },
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.shopping_bag,
            title: 'Nama Produk',
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama produk wajib diisi';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.attach_money,
            title: 'Harga & Stok',
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.category,
            title: 'Kategori',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _isLoadingCategories
                  ? null
                  : _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.name,
                        child: Text(cat.name),
                      );
                    }).toList(),
              onChanged: _isLoadingCategories
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori wajib diisi';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.monitor_weight,
            title: 'Berat Produk',
            child: TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Berat Produk (gram)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Berat produk wajib diisi';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Berat harus lebih dari 0';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.shopping_cart,
            title: 'Minimal Pembelian',
            child: TextFormField(
              controller: minPurchaseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimal Pembelian',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Minimal pembelian wajib diisi';
                }
                final min = int.tryParse(value);
                if (min == null || min < 1) {
                  return 'Minimal pembelian minimal 1';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.description,
            title: 'Deskripsi',
            child: TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Produk',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ProductFormSection(
            icon: Icons.widgets,
            title: 'Varian Produk',
            child: ProductVariantSection(
              enableColor: _enableColorVariant,
              onColorToggle: (v) => setState(() => _enableColorVariant = v),
              colorController: _colorController,
              enableSize: _enableSizeVariant,
              onSizeToggle: (v) => setState(() => _enableSizeVariant = v),
              selectedSizes: _selectedSizes,
              onSizeSelected: (size) {
                setState(() {
                  if (_selectedSizes.contains(size)) {
                    _selectedSizes.remove(size);
                  } else {
                    _selectedSizes.add(size);
                  }
                });
              },
              customSizes: _customSizes,
              showCustomSizeField: _showCustomSizeField,
              onAddCustomSize: () => setState(() => _showCustomSizeField = true),
              customSizeController: _customSizeController,
              onConfirmCustomSize: () {
                final text = _customSizeController.text.trim();
                if (text.isNotEmpty && !_customSizes.contains(text)) {
                  setState(() {
                    _customSizes.add(text);
                    _selectedSizes.add(text);
                    _customSizeController.clear();
                    _showCustomSizeField = false;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          const SellerTipCard(),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : saveProduct,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                isLoading
                    ? 'Menyimpan...'
                    : widget.product == null
                    ? 'Simpan Produk'
                    : 'Update Produk',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
