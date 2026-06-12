import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../../core/services/product_service_appwrite.dart';
import '../../../core/appwrite/appwrite_service.dart';

import 'package:image_picker/image_picker.dart';

import '../../../core/services/storage_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../core/services/category_service_appwrite.dart';
import '../../../data/models/category_model.dart';

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

  final ProductServiceAppwrite _service = ProductServiceAppwrite();

  bool isLoading = false;

  Uint8List? selectedImage;

  String? uploadedImageUrl;

  final StorageServiceAppwrite _storageService = StorageServiceAppwrite();

  String? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      nameController.text = widget.product!.name;
      _selectedCategory = widget.product!.category;
      descriptionController.text = widget.product!.description;
      priceController.text = widget.product!.price.toString();
      stockController.text = widget.product!.stock.toString();

      uploadedImageUrl = widget.product!.imageUrl;
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

      if (widget.product == null) {
        await _service.addProduct(
          sellerId: sellerId,
          name: nameController.text.trim(),
          category: category,
          description: descriptionController.text.trim(),
          price: double.parse(priceController.text.trim()),
          stock: int.parse(stockController.text.trim()),
          imageUrl: imageUrl,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Produk',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.product != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.product!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(child: Text('Belum ada gambar dipilih')),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Gambar Produk'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Produk',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

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
        ),
      ),
    );
  }
}
