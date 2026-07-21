import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../data/models/product_model.dart';
import '../../../../features/categories/presentation/providers/categories_providers.dart';
import '../../../../features/suppliers/presentation/providers/suppliers_providers.dart';
import '../../../../providers/user_session_provider.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../widgets/buttons/luxury_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/layouts/editorial_header.dart';
import '../../../../widgets/layouts/luxury_scaffold.dart';
import '../providers/products_providers.dart';
import '../../../../services/storage_service.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key, this.productToEdit});

  /// When set, the form runs in edit mode and calls [ProductsNotifier.updateProduct].
  final ProductModel? productToEdit;

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSupplier;
  bool _isSaving = false;
  String? _imageUrl;
  bool _isUploadingImage = false;

  bool get _isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.productToEdit;
    if (existing != null) {
      _nameController.text = existing.name;
      _stockController.text = existing.stock.toString();
      _priceController.text = existing.price.toString();
      _barcodeController.text = existing.barcode ?? '';
      _selectedCategory = existing.category;
      _selectedSupplier = existing.supplier;
      _imageUrl = existing.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      AppSnackbar.showError(context, 'Sign in to upload product images.');
      return;
    }

    XFile? pickedFile;
    try {
      pickedFile = await StorageService.pickImage(context: context);
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('Invalid argument(s): ', '');
        AppSnackbar.showError(context, 'Could not access photo library: $errorMsg');
      }
      return;
    }
    if (pickedFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await StorageService.uploadImage(
        file: pickedFile,
        bucketPath: StorageService.userScopedPath(
          uid: uid,
          folder: 'products',
          fileName: fileName,
        ),
      );
      setState(() {
        _imageUrl = url;
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Image uploaded successfully!');
      }
    } catch (e) {
      debugPrint('[AddProduct] Image upload failed: $e');
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('Invalid argument(s): ', '');
        AppSnackbar.showError(context, 'Upload failed: $errorMsg');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? -1;
    final price = double.tryParse(_priceController.text.trim()) ?? -1;
    final barcode = _barcodeController.text.trim();

    if (stock < 0 || price < 0) {
      AppSnackbar.showError(context, 'Enter valid stock and price values.');
      return;
    }

    setState(() => _isSaving = true);

    final notifier = ref.read(productsProvider.notifier);

    if (_isEditing) {
      await notifier.updateProduct(
        widget.productToEdit!.copyWith(
          name: name,
          category: _selectedCategory!,
          supplier: _selectedSupplier!,
          stock: stock,
          price: price,
          barcode: barcode,
          imageUrl: _imageUrl,
        ),
      );
    } else {
      await notifier.addProduct(
        name: name,
        category: _selectedCategory!,
        supplier: _selectedSupplier!,
        stock: stock,
        price: price,
        barcode: barcode,
        imageUrl: _imageUrl,
      );
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (ref.read(productsProvider).hasError) {
      AppSnackbar.showError(context, 'Could not save product. Please try again.');
      return;
    }

    AppSnackbar.showSuccess(context, _isEditing ? 'Product Updated' : 'Product Added');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryOptionsProvider);
    final suppliers = ref.watch(supplierOptionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return LuxuryScaffold(
      route: AppRoutes.addProduct,
      title: _isEditing ? 'Edit Product' : 'Compose Product',
      header: EditorialHeader(
        eyebrow: _isEditing ? 'Inventory Update' : 'Inventory Creation',
        title: _isEditing ? 'Update Inventory Entity' : 'Design a New Inventory Entity',
        subtitle: _isEditing
            ? 'Changes are saved to local SQLite and reflected across the dashboard.'
            : 'Category and supplier lists update instantly from management modules.',
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadImage,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
                        border: Border.all(color: colorScheme.outlineVariant),
                        image: _imageUrl != null && _imageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageUrl != null && _imageUrl!.isNotEmpty
                          ? null
                          : Center(
                              child: _isUploadingImage
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 44,
                                          color: colorScheme.onSurface.withValues(alpha: 0.58),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to upload image',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Product Name',
                    icon: Icons.inventory_2_outlined,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 12),
                  AppDropdownField(
                    label: 'Category',
                    hint: 'Select Category',
                    value: _selectedCategory,
                    items: categories,
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 12),
                  AppDropdownField(
                    label: 'Supplier',
                    hint: 'Select Supplier',
                    value: _selectedSupplier,
                    items: suppliers,
                    onChanged: (value) => setState(() => _selectedSupplier = value),
                    validator: (value) => value == null ? 'Please select a supplier' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Stock Quantity',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    controller: _stockController,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Barcode',
                    icon: Icons.qr_code_rounded,
                    controller: _barcodeController,
                    required: false,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      onPressed: () async {
                        final scanned = await Navigator.pushNamed(context, AppRoutes.scanner);
                        if (scanned != null && scanned is String) {
                          _barcodeController.text = scanned;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Price',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: LuxuryButton(
                      label: _isSaving
                          ? 'Saving...'
                          : (_isEditing ? 'Update Product' : 'Save Product'),
                      icon: Icons.check_rounded,
                      onPressed: _isSaving ? null : _saveProduct,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}