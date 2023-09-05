import 'package:bonako_demo/core/shared_widgets/text_form_field/custom_mobile_number_text_form_field.dart';
import '../../../../core/shared_widgets/text_form_field/custom_text_form_field.dart';
import 'package:bonako_demo/features/authentication/providers/auth_provider.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'package:bonako_demo/core/utils/error_utility.dart';
import 'package:bonako_demo/core/utils/mobile_number.dart';
import '../../repositories/store_repository.dart';
import '../../../../core/utils/snackbar.dart';
import '../../providers/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class CreateStoreForm extends StatefulWidget {

  final Function(ShoppableStore)? onCreatedStore;

  const CreateStoreForm({
    super.key,
    this.onCreatedStore
  });

  @override
  State<CreateStoreForm> createState() => _CreateStoreFormState();
}

class _CreateStoreFormState extends State<CreateStoreForm> {
  
  String name = '';
  Map serverErrors = {};
  String description = '';
  bool isSubmitting = false;
  String callToAction = 'Buy';
  late String mobileNumber;
  final _formKey = GlobalKey<FormState>();

  Function(ShoppableStore)? get onCreatedStore => widget.onCreatedStore;
  StoreRepository get storeRepository => friendGroupProvider.storeRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);
  StoreProvider get friendGroupProvider => Provider.of<StoreProvider>(context, listen: false);
  String? get nameErrorText => serverErrors.containsKey('name') ? serverErrors['name'] : null;
  String get mobileNumberWithExtension => MobileNumberUtility.addMobileNumberExtension(mobileNumber);
  String? get descriptionErrorText => serverErrors.containsKey('description') ? serverErrors['description'] : null;
  String? get mobileNumberErrorText => serverErrors.containsKey('mobileNumber') ? serverErrors['mobileNumber'] : null;

  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  @override
  void initState() {
    super.initState();
    mobileNumber = authProvider.user!.mobileNumber!.withoutExtension;
  }

  void _requestCreateStore() {

    _resetServerErrors().then((value) {

      if(_formKey.currentState!.validate()) {

        _startSubmittionLoader();

        storeRepository.createStore(
          name: name,
          description: description,
          callToAction: callToAction,
          mobileNumber: mobileNumberWithExtension
        ).then((response) async {

          if(response.statusCode == 201) {

            _resetForm();

            ShoppableStore createdStore = ShoppableStore.fromJson(response.data);

            if(onCreatedStore != null) onCreatedStore!(createdStore);

            SnackbarUtility.showSuccessMessage(message: 'Store created');

          }

        }).onError((dio.DioException exception, stackTrace) {

          ErrorUtility.setServerValidationErrors(setState, serverErrors, exception);

        }).catchError((error) {

          printError(info: error.toString());

          SnackbarUtility.showErrorMessage(message: 'Can\'t create store');

        }).whenComplete(() {

          _stopSubmittionLoader();

        });

      }else{

        SnackbarUtility.showErrorMessage(message: 'We found some mistakes');

      }

    });

  }

  /// Reset the server errors
  void _resetForm() {
    setState(() {
      name = '';

      Future.delayed(const Duration(milliseconds: 100)).then((value) {

        if(_formKey.currentState != null) {
          
          _formKey.currentState!.reset();

        }
      
      });
    });
  }

  /// Reset the server errors
  Future _resetServerErrors() {

    setState(() => serverErrors = {});

    /**
     *  We need to allow the setState() method to update the Widget Form Fields
     *  so that we can give the application a chance to update the inputs 
     *  before we validate them.
     */
    return Future.delayed(const Duration(milliseconds: 100));
    
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [

            /// Store Name
            CustomTextFormField(
              hintText: 'Baby Cakes 🧁',
              errorText: nameErrorText,
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              initialValue: name,
              labelText: 'Name',
              maxLength: 25,
              onChanged: (value) {
                setState(() => name = value); 
              },
            ),
              
            /// Spacer
            const SizedBox(height: 16),

            /// Description
            CustomTextFormField(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              hintText: 'The sweetest and softed cakes in the world 🍰',
              errorText: descriptionErrorText,
              initialValue: description,
              labelText: 'Description',
              enabled: !isSubmitting,
              borderRadiusAmount: 16,
              maxLength: 120,
              minLines: 2,
              onChanged: (value) {
                setState(() => description = value); 
              }
            ),
              
            /// Spacer
            const SizedBox(height: 16),
          
            //// Mobile Number Field
            CustomMobileNumberTextFormField(
              supportedMobileNetworkNames: const [
                MobileNetworkName.orange,
                MobileNetworkName.mascom,
                MobileNetworkName.btc,
              ],
              errorText: mobileNumberErrorText,
              initialValue: mobileNumber,
              enabled: !isSubmitting,
              onChanged: (value) {
                setState(() => mobileNumber = value);
              }
            ),

            /// Spacer
            const SizedBox(height: 16,),

            /// Add Button
            CustomElevatedButton(
              width: 120,
              'Create Store',
              isLoading: isSubmitting,
              alignment: Alignment.center,
              onPressed: _requestCreateStore,
              disabled: name.isEmpty || description.isEmpty || mobileNumber.length != 8,
            )

          ]
        )
    );
  }
}