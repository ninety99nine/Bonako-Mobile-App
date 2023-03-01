import '../../../subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import '../../../../../shopping_cart/widgets/shopping_cart_content.dart';
import '../../../../services/store_services.dart';
import '../../../../models/shoppable_store.dart';
import 'package:flutter/material.dart';

class StoreSecondarySectionContent extends StatelessWidget {

  final ShoppableStore store;
  final bool canShowSubscribeCallToAction;
  final ShoppingCartCurrentView shoppingCartCurrentView;

  const StoreSecondarySectionContent({
    Key? key,
    required this.store,
    required this.shoppingCartCurrentView,
    this.canShowSubscribeCallToAction = true
  }) : super(key: key);

  bool get isOpen => StoreServices.isOpen(store);
  bool get hasJoinedStoreTeam => StoreServices.hasJoinedStoreTeam(store);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        if(!isOpen && hasJoinedStoreTeam && canShowSubscribeCallToAction) ...[

          /// Subscribe Modal Bottom Sheet
          SubscribeToStoreModalBottomSheet(store: store)

        ],

        /// Shopping Cart
        if(isOpen) ShoppingCartContent(
          shoppingCartCurrentView: shoppingCartCurrentView
        ),

      ],
    );
  }
}