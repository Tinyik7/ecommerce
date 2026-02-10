import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/screen_title.dart';
import '../../../data/models/product_model.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: GetBuilder<AdminController>(
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (c.products.isEmpty) {
            return RefreshIndicator(
              onRefresh: c.fetchProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No products found')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: c.fetchProducts,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              children: [
                const ScreenTitle(
                  title: 'Catalog',
                  dividerEndIndent: 220,
                ),
                20.verticalSpace,
                ...c.products.map(
                  (product) => Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      title: Text(product.name ?? '--'),
                      subtitle: Text(
                        'Price: \$${(product.price ?? 0).toStringAsFixed(2)}\n'
                        'Qty: ${product.quantity ?? 0}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openProductSheet(context, product: product);
                          } else if (value == 'delete' && product.id != null) {
                            controller.deleteProduct(product.id!);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ),
                ),
                80.verticalSpace,
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'change-role-fab',
            onPressed: () => _openRoleSheet(context),
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Change role'),
          ),
          10.verticalSpace,
          FloatingActionButton.extended(
            heroTag: 'new-product-fab',
            onPressed: () => _openProductSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('New product'),
          ),
        ],
      ),
    );
  }

  void _openProductSheet(BuildContext context, {ProductModel? product}) {
    final TextEditingController nameCtrl =
        TextEditingController(text: product?.name ?? '');
    final TextEditingController priceCtrl =
        TextEditingController(text: product?.price?.toString() ?? '');
    final TextEditingController qtyCtrl =
        TextEditingController(text: product?.quantity?.toString() ?? '');
    final TextEditingController categoryCtrl =
        TextEditingController(text: product?.category ?? '');
    final TextEditingController descriptionCtrl =
        TextEditingController(text: product?.description ?? '');
    final TextEditingController imageCtrl =
        TextEditingController(text: product?.image ?? '');
    final TextEditingController ratingCtrl =
        TextEditingController(text: product?.rating?.toString() ?? '');
    final TextEditingController reviewsCtrl =
        TextEditingController(text: product?.reviews ?? '');
    final TextEditingController sizeCtrl =
        TextEditingController(text: product?.size ?? '');
    final TextEditingController brandCtrl =
        TextEditingController(text: product?.brand ?? '');
    final TextEditingController colorCtrl =
        TextEditingController(text: product?.color ?? '');
    final TextEditingController discountCtrl =
        TextEditingController(text: product?.discount?.toString() ?? '');
    final TextEditingController createdAtCtrl = TextEditingController(
        text: product?.createdAt?.toIso8601String() ?? '');
    final TextEditingController updatedAtCtrl = TextEditingController(
        text: product?.updatedAt?.toIso8601String() ?? '');

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool isFavorite = product?.isFavorite ?? false;
    bool inCart = product?.inCart ?? false;
    bool featured = product?.featured ?? false;
    bool inStock = product?.inStock ?? true;

    DateTime? parseDate(String value) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }

    double? parseDouble(String value) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }

    Get.bottomSheet(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product == null ? 'Add product' : 'Edit product',
                      style: context.textTheme.titleLarge,
                    ),
                    if (product?.id != null) ...[
                      8.verticalSpace,
                      Text('ID: ${product!.id}'),
                    ],
                    20.verticalSpace,
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter product name'
                              : null,
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price'),
                      validator: (value) =>
                          value == null || double.tryParse(value) == null
                              ? 'Enter valid price'
                              : null,
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (value) =>
                          value == null || int.tryParse(value) == null
                              ? 'Enter valid quantity'
                              : null,
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: imageCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Image URL / path'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: ratingCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Rating'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: reviewsCtrl,
                      decoration: const InputDecoration(labelText: 'Reviews'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: sizeCtrl,
                      decoration: const InputDecoration(labelText: 'Size'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: brandCtrl,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: colorCtrl,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: categoryCtrl,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: discountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Discount'),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: descriptionCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: createdAtCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Created at (ISO 8601)',
                        hintText: '2024-01-01T10:00:00Z',
                      ),
                    ),
                    12.verticalSpace,
                    TextFormField(
                      controller: updatedAtCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Updated at (ISO 8601)',
                        hintText: '2024-01-01T10:00:00Z',
                      ),
                    ),
                    12.verticalSpace,
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Favorite'),
                      value: isFavorite,
                      onChanged: (value) => setState(() => isFavorite = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In cart'),
                      value: inCart,
                      onChanged: (value) => setState(() => inCart = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured'),
                      value: featured,
                      onChanged: (value) => setState(() => featured = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In stock'),
                      value: inStock,
                      onChanged: (value) => setState(() => inStock = value),
                    ),
                    20.verticalSpace,
                    GetBuilder<AdminController>(
                      builder: (c) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: c.isSubmitting
                              ? null
                              : () {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  controller.saveProduct(
                                    id: product?.id,
                                    name: nameCtrl.text.trim(),
                                    price: double.parse(priceCtrl.text.trim()),
                                    quantity: int.parse(qtyCtrl.text.trim()),
                                    description: descriptionCtrl.text,
                                    category: categoryCtrl.text,
                                    image: imageCtrl.text,
                                    rating: parseDouble(ratingCtrl.text),
                                    reviews: reviewsCtrl.text,
                                    size: sizeCtrl.text,
                                    isFavorite: isFavorite,
                                    inCart: inCart,
                                    brand: brandCtrl.text,
                                    color: colorCtrl.text,
                                    featured: featured,
                                    discount: parseDouble(discountCtrl.text),
                                    inStock: inStock,
                                    createdAt: parseDate(createdAtCtrl.text),
                                    updatedAt: parseDate(updatedAtCtrl.text),
                                  );
                                },
                          child: c.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(product == null ? 'Create' : 'Update'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openRoleSheet(BuildContext context) {
    final TextEditingController userIdCtrl = TextEditingController();
    String selectedRole = 'USER';
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change user role', style: context.textTheme.titleLarge),
                  16.verticalSpace,
                  TextFormField(
                    controller: userIdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'User ID'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter user id';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'User id must be a number';
                      }
                      return null;
                    },
                  ),
                  12.verticalSpace,
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'USER', child: Text('USER')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  20.verticalSpace,
                  GetBuilder<AdminController>(
                    builder: (c) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: c.isChangingRole
                            ? null
                            : () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                final userId = int.parse(userIdCtrl.text.trim());
                                try {
                                  await controller.changeUserRole(
                                    userId: userId,
                                    role: selectedRole,
                                  );
                                  if (Get.isBottomSheetOpen ?? false) {
                                    Get.back();
                                  }
                                } catch (_) {}
                              },
                        child: c.isChangingRole
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update role'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
