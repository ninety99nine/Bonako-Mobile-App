import 'package:bonako_demo/features/products/widgets/create_or_update_product_form/product_logo.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_money_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/products/repositories/product_repository.dart';
import 'package:bonako_demo/features/stores/repositories/store_repository.dart';
import 'package:bonako_demo/features/products/providers/product_provider.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/stores/providers/store_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/features/products/models/product.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/utils/snackbar.dart';
import 'package:bonako_demo/core/utils/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class CreateOrUpdateProductForm extends StatefulWidget {
  
  final Product? product;
  final ShoppableStore store;
  final Function(bool) onDeleting;
  final Function(bool) onSubmitting;
  final Function(int, int) onSendProgress;
  final Function(Product)? onDeletedProduct;
  final Function(Product)? onUpdatedProduct;
  final Function(Product)? onCreatedProduct;

  const CreateOrUpdateProductForm({
    super.key,
    this.product,
    required this.store,
    this.onDeletedProduct,
    this.onUpdatedProduct,
    this.onCreatedProduct,
    required this.onDeleting,
    required this.onSubmitting,
    required this.onSendProgress,
  });

  @override
  State<CreateOrUpdateProductForm> createState() => CreateOrUpdateProductFormState();
}

class CreateOrUpdateProductFormState extends State<CreateOrUpdateProductForm> {

  XFile? photo;
  Map productForm = {};
  Map serverErrors = {};
  bool isDeleting= false;
  bool isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  
  bool get isEditing => product != null;
  bool get isCreating => product == null;
  Product? get product => widget.product;
  ShoppableStore get store => widget.store;
  Function(bool) get onDeleting => widget.onDeleting;
  Function(bool) get onSubmitting => widget.onSubmitting;
  Function(int, int) get onSendProgress => widget.onSendProgress;
  Function(Product)? get onDeletedProduct => widget.onDeletedProduct;
  Function(Product)? get onUpdatedProduct => widget.onUpdatedProduct;
  Function(Product)? get onCreatedProduct => widget.onCreatedProduct;
  StoreRepository get storeRepository => storeProvider.storeRepository;
  ProductRepository get productRepository => productProvider.productRepository;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ProductProvider get productProvider => Provider.of<ProductProvider>(context, listen: false);

  void _startDeleteLoader() => setState(() => isDeleting = true);
  void _stopDeleteLoader() => setState(() => isDeleting = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    
    /// Future.delayed() is used so that we can wait for the
    /// variables to be set e.g The "product" getter property
    Future.delayed(Duration.zero).then((value) {
      
      setProductForm();

    });
  }

  setProductForm() {

    setState(() {
      
      productForm = {

        /// Name
        'name': isEditing ? product!.name : '',

        /// Visibility
        'visible': isEditing ? product!.visible.status : true,
        
        /// Description
        'showDescription': isEditing ? product!.showDescription.status : false,
        'description': isEditing ? product!.description : '',

        /// Tracking
        'sku' : isEditing ? product!.sku : '',
        'barcode': isEditing ? product!.barcode : '',

        /// Variations
        'allowVariations': isEditing ? product!.allowVariations.status : false,
        'variantAttributes': isEditing ? product!.variantAttributes : [],

        /// Pricing
        'isFree': isEditing ? product!.isFree.status : false,
        'currency': isEditing ? product!.currency.code : 'BWP',
        'unitRegularPrice': isEditing ? product!.unitRegularPrice.amount.toStringAsFixed(2) : '0.00',
        'unitSalePrice': isEditing ? product!.unitSalePrice.amount.toStringAsFixed(2) : '0.00',
        'unitCostPrice': isEditing ? product!.unitCostPrice.amount.toStringAsFixed(2) : '0.00',

        /// Quantity
        'allowedQuantityPerOrder': isEditing ? product!.allowedQuantityPerOrder.value.toLowerCase() : 'unlimited',
        'maximumAllowedQuantityPerOrder': isEditing ? product!.maximumAllowedQuantityPerOrder.value.toString() : '5',

        /// Stock
        'stockQuantityType': isEditing ? product!.stockQuantityType.value.toLowerCase() : 'unlimited',
        'stockQuantity': isEditing ? product!.stockQuantity.value.toString() : '10',

      };

    });

  }

  requestCreateProduct() {

    if(isDeleting || isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      storeProvider.setStore(store).storeRepository.createProduct(
        photo: photo,
        sku: productForm['sku'],
        name: productForm['name'],
        isFree: productForm['isFree'],
        onSendProgress: onSendProgress,
        barcode: productForm['barcode'],
        visible: productForm['visible'],
        description: productForm['description'],
        stockQuantity: productForm['stockQuantity'],
        unitCostPrice: productForm['unitCostPrice'],
        unitSalePrice: productForm['unitSalePrice'],
        allowVariations: productForm['allowVariations'],
        showDescription: productForm['showDescription'],
        unitRegularPrice: productForm['unitRegularPrice'],
        stockQuantityType: productForm['stockQuantityType'],
        allowedQuantityPerOrder: productForm['allowedQuantityPerOrder'],
        maximumAllowedQuantityPerOrder: productForm['maximumAllowedQuantityPerOrder'],
      ).then((response) {

        if(response.statusCode == 201) {

          print('success 2');

          final Product createdProduct = Product.fromJson(response.data);

          print('success 3');

          /**
           *  This method must come before the SnackbarUtility.showSuccessMessage()
           *  in case this method executes a Get.back() to close a bottom modal
           *  sheet for instance. If we execute this after showSuccessMessage()
           *  then we will close the showSuccessMessage() Snackbar instead
           *  of the bottom modal sheet
           */
          if(onCreatedProduct != null) onCreatedProduct!(createdProduct);

          SnackbarUtility.showSuccessMessage(message: 'Created successfully');

        }
        
      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t create product');

      }).whenComplete(() {

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });


    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  requestUpdateProduct() {

    if(isDeleting || isSubmitting) return;

    _resetServerErrors();

    if(_formKey.currentState!.validate()) {

      _startSubmittionLoader();
      
      /// Notify parent that we are loading
      onSubmitting(true);

      productProvider.setProduct(product!).productRepository.updateProduct(
        sku: productForm['sku'],
        name: productForm['name'],
        isFree: productForm['isFree'],
        barcode: productForm['barcode'],
        visible: productForm['visible'],
        description: productForm['description'],
        stockQuantity: productForm['stockQuantity'],
        unitCostPrice: productForm['unitCostPrice'],
        unitSalePrice: productForm['unitSalePrice'],
        allowVariations: productForm['allowVariations'],
        showDescription: productForm['showDescription'],
        unitRegularPrice: productForm['unitRegularPrice'],
        stockQuantityType: productForm['stockQuantityType'],
        allowedQuantityPerOrder: productForm['allowedQuantityPerOrder'],
        maximumAllowedQuantityPerOrder: productForm['maximumAllowedQuantityPerOrder'],
      ).then((response) async {

        if(response.statusCode == 200) {

          final Product updatedProduct = Product.fromJson(response.data);
          
          /**
           *  This method must come before the SnackbarUtility.showSuccessMessage()
           *  in case this method executes a Get.back() to close a bottom modal
           *  sheet for instance. If we execute this after showSuccessMessage()
           *  then we will close the showSuccessMessage() Snackbar instead
           *  of the bottom modal sheet
           */
          if(onUpdatedProduct != null) onUpdatedProduct!(updatedProduct);

          SnackbarUtility.showSuccessMessage(message: 'Updated successfully');


        }

      }).onError((dio.DioException exception, stackTrace) {

        ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Can\'t update product');

      }).whenComplete(() {

        _stopSubmittionLoader();
      
        /// Notify parent that we are not loading
        onSubmitting(false);

      });

    }else{

      SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

    }

  }

  void _requestDeleteProduct() async {

    if(isDeleting || isSubmitting) return;

    final bool? confirmation = await confirmDelete();

    /// If we can delete
    if(confirmation == true) {

      _startDeleteLoader();

      /// Notify parent that we are starting the deleting process
      onDeleting(true);

      productProvider.setProduct(product!).productRepository.deleteProduct().then((response) async {

        if(response.statusCode == 200) {

          /// Notify parent that the product has been deleted
          if(onDeletedProduct != null) onDeletedProduct!(product!);

          SnackbarUtility.showSuccessMessage(message: response.data['message']);

        }

      }).catchError((error) {

        printError(info: error.toString());

        SnackbarUtility.showErrorMessage(message: 'Failed to delete groups');

      }).whenComplete(() {

        _stopDeleteLoader();

        /// Notify parent that we are ending the deleting process
        onDeleting(false);

      });

    }

  }

  /// Confirm delete product
  Future<bool?> confirmDelete() {

    return DialogUtility.showConfirmDialog(
      content: 'Are you sure you want to delete ${product!.name}?',
      context: context
    );

  }

  /// Reset the server errors
  void _resetServerErrors() => setState(() => serverErrors = {});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0,),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: productForm.isEmpty ? [] : [
              
              /// Spacer
              const SizedBox(height: 8),

              ProductPhoto(
                radius: 60,
                store: store,
                product: product,
                canChangePhoto: true,
                onPickedFile: (file) {
                  photo = file;

                  print('file');
                  print(file);
                  print('file.runtimeType');
                  print(file.runtimeType);
                  
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Visible Checkbox
              CustomCheckbox(
                value: productForm['visible'],
                disabled: isSubmitting,
                text: 'Show product',
                onChanged: (value) {
                  setState(() => productForm['visible'] = value ?? false); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Name
              CustomTextFormField(
                errorText: serverErrors.containsKey('name') ? serverErrors['name'] : null,
                enabled: !isSubmitting && !isDeleting,
                initialValue: productForm['name'],
                hintText: 'Standard Ticket',
                borderRadiusAmount: 16,
                labelText: 'Name',
                maxLength: 60,
                onChanged: (value) {
                  setState(() => productForm['name'] = value); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Show Description Checkbox
              CustomCheckbox(
                value: productForm['showDescription'],
                disabled: isSubmitting,
                text: 'Show description',
                onChanged: (value) {
                  setState(() => productForm['showDescription'] = value ?? false); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Description
              CustomTextFormField(
                errorText: serverErrors.containsKey('description') ? serverErrors['description'] : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                hintText: '1 day show with popular artists',
                initialValue: productForm['description'],
                enabled: !isSubmitting && !isDeleting,
                labelText: 'Description',
                borderRadiusAmount: 16,
                maxLength: 200,
                minLines: 1,
                onChanged: (value) {
                  setState(() => productForm['description'] = value); 
                },
                validator: (value) {
                  return null;
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Free Product Checkbox
              CustomCheckbox(
                value: productForm['isFree'],
                disabled: isSubmitting,
                text: 'This is a free product',
                onChanged: (value) {
                  setState(() => productForm['isFree'] = value ?? false); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Unit Regular Price
              CustomMoneyTextFormField(
                errorText: serverErrors.containsKey('unitRegularPrice') ? serverErrors['unitRegularPrice'] : null,
                enabled: !isSubmitting && !isDeleting && !productForm['isFree'],
                initialValue: productForm['unitRegularPrice'],
                labelText: 'Regular Price',
                hintText: '100.00',
                onChanged: (value) {
                  setState(() => productForm['unitRegularPrice'] = value); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Unit Sale Price
              CustomMoneyTextFormField(
                errorText: serverErrors.containsKey('unitSalePrice') ? serverErrors['unitSalePrice'] : null,
                enabled: !isSubmitting && !isDeleting && !productForm['isFree'],
                initialValue: productForm['unitSalePrice'],
                labelText: 'Sale Price',
                hintText: '50.00',
                onChanged: (value) {
                  setState(() => productForm['unitSalePrice'] = value); 
                },
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Unit Cost Price
              CustomMoneyTextFormField(
                errorText: serverErrors.containsKey('unitCostPrice') ? serverErrors['unitCostPrice'] : null,
                enabled: !isSubmitting && !isDeleting && !productForm['isFree'],
                initialValue: productForm['unitCostPrice'],
                labelText: 'Cost Price',
                hintText: '25.00',
                onChanged: (value) {
                  setState(() => productForm['unitCostPrice'] = value); 
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Allowed Quantity Per Order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBodyText('Quantities Per Order'),
                  DropdownButton(
                    value: productForm['allowedQuantityPerOrder'],
                    items: const [
                      DropdownMenuItem(
                        value: 'limited',
                        child: CustomBodyText('Limited'),
                      ),
                      DropdownMenuItem(
                        value: 'unlimited',
                        child: CustomBodyText('Unlimited'),
                      )
                    ],
                    onChanged: (value) {
                      setState(() => productForm['allowedQuantityPerOrder'] = value); 
                    },
                  ),
                ],
              ),

              if(productForm['allowedQuantityPerOrder'] == 'limited') ...[
              
                /// Spacer
                const SizedBox(height: 8),

                /// Maximum Allowed Quantity Per Order
                CustomTextFormField(
                  errorText: serverErrors.containsKey('maximumAllowedQuantityPerOrder') ? serverErrors['maximumAllowedQuantityPerOrder'] : null,
                  initialValue: productForm['maximumAllowedQuantityPerOrder'],
                  labelText: 'Maximum Quantities Per Order',
                  enabled: !isSubmitting && !isDeleting,
                  borderRadiusAmount: 16,
                  hintText: '10',
                  maxLength: 6,
                  onChanged: (value) {
                    setState(() => productForm['maximumAllowedQuantityPerOrder'] = value); 
                  },
                ),
              
                /// Spacer
                const SizedBox(height: 8),

              ],

              /// Stock Quantity Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBodyText('Available Stock'),
                  DropdownButton(
                    value: productForm['stockQuantityType'],
                    items: const [
                      DropdownMenuItem(
                        value: 'limited',
                        child: CustomBodyText('Limited'),
                      ),
                      DropdownMenuItem(
                        value: 'unlimited',
                        child: CustomBodyText('Unlimited'),
                      )
                    ],
                    onChanged: (value) {
                      setState(() => productForm['stockQuantityType'] = value); 
                    },
                  ),
                ],
              ),

              if(productForm['stockQuantityType'] == 'limited') ...[
              
                /// Spacer
                const SizedBox(height: 8),

                /// Stock Quantity
                CustomTextFormField(
                  errorText: serverErrors.containsKey('stockQuantity') ? serverErrors['stockQuantity'] : null,
                  initialValue: productForm['stockQuantity'],
                  enabled: !isSubmitting && !isDeleting,
                  labelText: 'Stock Quantity',
                  borderRadiusAmount: 16,
                  hintText: '10',
                  maxLength: 6,
                  onChanged: (value) {
                    setState(() => productForm['stockQuantity'] = value); 
                  },
                ),

              ],
              
              /// Spacer
              const SizedBox(height: 16),

              /// SKU
              CustomTextFormField(
                errorText: serverErrors.containsKey('sku') ? serverErrors['sku'] : null,
                enabled: !isSubmitting && !isDeleting,
                initialValue: productForm['sku'],
                borderRadiusAmount: 16,
                hintText: 'std-ticket',
                labelText: 'SKU',
                maxLength: 100,
                onChanged: (value) {
                  setState(() => productForm['sku'] = value); 
                },
                validator: (value) {
                  return null;
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              /// Barcode
              CustomTextFormField(
                errorText: serverErrors.containsKey('barcode') ? serverErrors['barcode'] : null,
                enabled: !isSubmitting && !isDeleting,
                initialValue: productForm['barcode'],
                borderRadiusAmount: 16,
                hintText: '123456789',
                labelText: 'Barcode',
                maxLength: 100,
                onChanged: (value) {
                  setState(() => productForm['barcode'] = value); 
                },
                validator: (value) {
                  return null;
                }
              ),
              
              /// Spacer
              const SizedBox(height: 16),

              if(isEditing) CustomElevatedButton(
                'Delete',
                width: 120,
                isError: true,
                isLoading: isDeleting,
                alignment: Alignment.center,
                onPressed: _requestDeleteProduct
              ),

              /// Spacer
              const SizedBox(height: 100)
              
            ]
          ),
        ),
      ),
    );
  }
}