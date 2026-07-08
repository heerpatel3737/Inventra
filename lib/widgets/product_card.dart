import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  Color get stockColor {
    if (product.stock <= 5) return AppColors.danger;
    if (product.stock <= 15) return AppColors.warning;
    return AppColors.success;
  }

  bool get _hasImage =>
      product.imageUrl != null && product.imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProductThumbnail(imageUrl: product.imageUrl),
                  if (onDelete != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    ),
                  Chip(label: Text(product.category)),
                ],
              ),
              const SizedBox(height: 12),
              Text(product.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Supplier: ${product.supplier}', style: Theme.of(context).textTheme.bodyMedium),
              if (_hasImage) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    height: 72,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      height: 72,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text('Stock ${product.stock}', style: TextStyle(color: stockColor, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 18),
              errorWidget: (_, __, ___) => const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 18),
            )
          : const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 18),
    );
  }
}
