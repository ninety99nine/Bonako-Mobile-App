import 'package:bonako_demo/features/products/widgets/modifiable_product_cards/edit_product_cards/edit_product_cards.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/profile/profile_right_side/adverts/show_adverts/advert_carousel.dart';
import '../../../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:bonako_demo/core/shared_widgets/checkbox/custom_checkbox.dart';
import '../../../../../shopping_cart/widgets/shopping_cart_content.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatefulWidget {

  final bool canShowAdverts;
  final ShoppableStore store;
  final EdgeInsetsGeometry padding;
  final bool canShowSubscribeCallToAction;
  final Alignment subscribeButtonAlignment;
  final ShoppingCartCurrentView shoppingCartCurrentView;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
    this.canShowAdverts = true,
    required this.shoppingCartCurrentView,
    this.padding = const EdgeInsets.all(0),
    this.canShowSubscribeCallToAction = true,
    this.subscribeButtonAlignment = Alignment.centerRight,
  }) : super(key: key);

  @override
  State<StoreSecondarySectionContent> createState() => _StoreSecondarySectionContentState();
}

class _StoreSecondarySectionContentState extends State<StoreSecondarySectionContent> {

  ShoppableStore get store => widget.store;
  EdgeInsetsGeometry get padding => widget.padding;
  bool get canShowAdverts => widget.canShowAdverts;
  bool get hasProducts => store.relationships.products.isNotEmpty;
  bool get canAccessAsShopper => StoreServices.canAccessAsShopper(store);
  Alignment get subscribeButtonAlignment => widget.subscribeButtonAlignment;
  bool get canShowSubscribeCallToAction => widget.canShowSubscribeCallToAction;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(widget.store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        /// View As Customer Checkbox
        if(canAccessAsTeamMember && hasProducts) ...[

          Padding(
            padding: padding,
            child: CustomCheckbox(
              value: teamMemberWantsToViewAsCustomer,
              text: 'View as customer',
              onChanged: (value) {
                if(value != null) store.updateTeamMemberWantsToViewAsCustomer(value);
              }
            ),
          ),

        ],

        if(canShowAdverts && (canAccessAsShopper || canAccessAsTeamMember)) ...[
        
          /// Store Adverts
          StoreAdvertCarousel(store: store),

          /// Spacer
          const SizedBox(height: 16,),

        ],

        Padding(
          padding: padding,
          child: Column(
            children: [

              /// Shopping Cart
              if((!hasJoinedStoreTeam && canAccessAsShopper) || (hasJoinedStoreTeam && canAccessAsTeamMember && teamMemberWantsToViewAsCustomer)) ShoppingCartContent(
                shoppingCartCurrentView: widget.shoppingCartCurrentView
              ),

              /// Edit Product Cards
              if(hasJoinedStoreTeam && canAccessAsTeamMember && !teamMemberWantsToViewAsCustomer)  ...[

                EditProductCards(
                  shoppingCartCurrentView: widget.shoppingCartCurrentView
                )

              ],

            ],
          ),
        ),

        /// Subscribe Modal Bottom Sheet
        if(hasJoinedStoreTeam && !canAccessAsTeamMember && canShowSubscribeCallToAction) ...[

          SubscribeToStoreModalBottomSheet(
            store: widget.store,
            subscribeButtonAlignment: subscribeButtonAlignment,
          )

        ],

      ],
    );
  }
}