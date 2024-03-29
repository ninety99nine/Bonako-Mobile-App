import '../../../core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import '../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../core/shared_widgets/text/custom_title_large_text.dart';
import '../../../core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../core/constants/constants.dart' as constants;
import '../repositories/auth_repository.dart';
import '../models/terms_and_conditions.dart';
import '../../../core/utils/snackbar.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndConditionsPage extends StatelessWidget {

  final Function onUpdatedTermsAndConditions;

  const TermsAndConditionsPage({
    super.key,
    required this.onUpdatedTermsAndConditions
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Content(
            onUpdatedTermsAndConditions: onUpdatedTermsAndConditions
          )
        )
      ),
    );
  }

}

class Content extends StatefulWidget {

  final Function onUpdatedTermsAndConditions;

  const Content({
    super.key,
    required this.onUpdatedTermsAndConditions
  });

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {

  String? title;
  bool isLoading = false;
  bool isSubmitting = false;
  List<String> acceptedItems = [];
  TermsAndConditions? termsAndConditions;
  
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  void _startSubmittionLoader() => setState(() => isSubmitting = true);
  void _stopSubmittionLoader() => setState(() => isSubmitting = false);

  AuthRepository get authRepository => authProvider.authRepository;
  Function get onUpdatedTermsAndConditions => widget.onUpdatedTermsAndConditions;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  bool get acceptedTermsAndConditions {
    if(termsAndConditions == null) return false; 
    return acceptedItems.length == termsAndConditions!.items.length;
  }
  
  @override
  void initState() {
    super.initState();
    _requestShowTermsAndConditions();
  }

  Future<void> _requestShowTermsAndConditions() async {

    if(isLoading) return;

    _startLoader();
    
    await authRepository.showTermsAndConditions().then((response) async {

      if( response.statusCode == 200 ) {

        setState(() {
          
          termsAndConditions = TermsAndConditions.fromJson(response.data);

        });

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Can\'t show the terms and conditions');

    }).whenComplete(() {

      _stopLoader();

    });

  }

  Future<void> _requestAcceptTermsAndConditions() async {

    if(isSubmitting) return;

    if(acceptedTermsAndConditions == false) return;

    _startSubmittionLoader();
    
    await authRepository.acceptTermsAndConditions().then((response) async {

      if( response.statusCode == 200 ) {
        
        SnackbarUtility.showSuccessMessage(message: response.data['message']);
        onUpdatedTermsAndConditions();

      }

    }).catchError((error) {

      printError(info: error.toString());

      SnackbarUtility.showErrorMessage(message: 'Can\'t accept the terms and conditions');

    }).whenComplete(() {

      _stopSubmittionLoader();

    });

  }

  Widget getContent() {

    if(isLoading && termsAndConditions == null) {

      return const Center(
        child: CustomCircularProgressIndicator()
      );

    }else if(!isLoading && termsAndConditions != null) {

      return getTermsAndConditionsContent();

    }else{

      return getFallBackContent();

    }
  }

  Widget getTermsAndConditionsContent() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        //  Spacer
        const SizedBox(height: 50),

        //  Loader
        if(isLoading) const CustomCircularProgressIndicator(),

        if( termsAndConditions != null ) ...[

          //  Title
          CustomTitleLargeText(termsAndConditions!.title),
        
          //  Spacer
          const SizedBox(height: 30),

          //  Instruction
          CustomBodyText(
            termsAndConditions!.instruction,
            height: 1.6,
          ),

          //  Divider
          const Divider(height: 50),

          Stack(
            alignment: AlignmentDirectional.center,
            children: [

              //  Get Acceptable Items
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isSubmitting ? 0.25 : 1,
                child: Wrap(
                  runSpacing: 16,
                  children: [
              
                    ...getAcceptableItems(),

                  ],
                ),
              ),

              //  Loader
              if(isSubmitting) const CustomCircularProgressIndicator()

            ]
          ),

          SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                child: acceptedTermsAndConditions 
                  ? CustomBodyText(termsAndConditions!.confirmation, margin: const EdgeInsets.only(top: 24),)
                  : null 
              ),
            ),
          ),
                
          //  Divider
          const Divider(height: 50),
                
          //  Button
          CustomElevatedButton(
            termsAndConditions!.button,
            suffixIcon: Icons.arrow_forward_rounded,
            onPressed: _requestAcceptTermsAndConditions,
            disabled: isSubmitting || !acceptedTermsAndConditions,
          ),
        
          //  Spacer
          const SizedBox(height: 100),

        ]
    
      ],
    );

  }

  Widget getFallBackContent() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        //  Spacer
        const SizedBox(height: 50),

        //  Title
        const CustomTitleLargeText('Terms & Conditions Issue'),
      
        //  Spacer
        const Divider(height: 50),

        //  Instruction
        const CustomBodyText(
          'Sorry, we can\'t access the terms and conditions that must be accepted before continuing to use services.',
          
          height: 1.6,
        ),
      
        //  Spacer
        const SizedBox(height: 30),

        //  Instruction
        const CustomBodyText(
          constants.errorDebugMessage,
          height: 1.6,
        ),

        const Divider(height: 50),
              
        //  Button
        CustomElevatedButton(
          'Try Again',
          disabled: isLoading,
          suffixIcon: Icons.refresh,
          alignment: Alignment.center,
          onPressed: _requestShowTermsAndConditions,
        ),
    
      ],
    );

  }

  List<Widget> getAcceptableItems(){
    return [
      if( !isLoading && termsAndConditions != null ) ...termsAndConditions!.items.map((item) => checkboxToAccept(
        link: item.href,
        name: item.name, 
      ))
    ];
  }

  Widget checkboxToAccept({ required String name, required String link }){
    return CustomCheckbox(
      link: link,
      linkText: name,
      disabled: isSubmitting,
      value: acceptedItems.contains(name), 
      onChanged: (value) {
        if(value != null) {
          setState(() {
            if(value == true){
              acceptedItems.add(name);
            }else{
              acceptedItems.remove(name);
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return getContent();
  }
}