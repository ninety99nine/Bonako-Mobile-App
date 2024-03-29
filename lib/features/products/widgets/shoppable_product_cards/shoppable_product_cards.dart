import '../../../../core/shared_widgets/message_alert/custom_message_alert.dart';
import '../../../../core/shared_widgets/button/show_more_or_less_button.dart';
import '../../../../../../core/constants/constants.dart' as constants;
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'shoppable_product_card.dart';
import '../../models/product.dart';

class ShoppableProductCards extends StatefulWidget {

  final ShoppingCartCurrentView shoppingCartCurrentView;

  const ShoppableProductCards({
    super.key,
    required this.shoppingCartCurrentView,
  });

  @override
  State<ShoppableProductCards> createState() => _ShoppableProductCardsState();
}

class _ShoppableProductCardsState extends State<ShoppableProductCards> {
  
  ShoppableStore? store;
  bool showAllProducts = false;
  List<int> selectedProductIds = [];

  bool get doesntHaveSelectedProducts => !hasSelectedProducts;
  List<Product> get products => store == null ? [] : store!.relationships.products;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  ShoppingCartCurrentView get shoppingCartCurrentView => widget.shoppingCartCurrentView;
  bool get isShowingStorePage => Provider.of<StoreProvider>(context, listen: true).isShowingStorePage;
  bool get hasMoreProductsThanMinimumProductsToShow => products.length > constants.minimumProductsPerStoreOnPreview;
  List<Product> get selectedProducts => products.where((product) => selectedProductIds.contains(product.id) ).toList();
  bool get isShoppingOnStorePage => (shoppingCartCurrentView == ShoppingCartCurrentView.storePage && isShowingStorePage);
  bool get isShoppingOnStoreCard => (shoppingCartCurrentView == ShoppingCartCurrentView.storeCard && !isShowingStorePage);
  bool get canShowMoreOrLessButton => isShoppingOnStoreCard && doesntHaveSelectedProducts && hasMoreProductsThanMinimumProductsToShow;
  bool get isShoppingOnStoreOrdersModalBottomSheet => (shoppingCartCurrentView == ShoppingCartCurrentView.storeOrdersModalBottomSheet);
  List<Product> get filteredProducts => showAllProducts ? products : products.take(constants.minimumProductsPerStoreOnPreview).toList();

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /**
     *  When selecting a product, changing quantity, e.t.c, the Shoppable
     *  Store Model will be updated, which will then notify listeners, 
     *  and since we are listening for changes on this Store Model
     *  because of the property set on the build() method:
     * 
     *  Provider.of<ShoppableStore>(context, listen: true);
     * 
     *  This build() method will therefore be triggered to rebuild, thereby 
     *  causing the didChangeDependencies() to run as well. Once this
     *  happens we can execute the following updates:
     * 
     *  1) setSelectedProductIds(): Update the list of selected product ids, 
     *     so that the changes can be picked up by each ShoppableProductCard widget 
     *     to update on whether that ShoppableProductCard is selected or not, and 
     *     therefore update the UI accordingly
     * 
     *  2) autoToggleShowAllProducts(): Automatically show all products if 
     *     we selected one of the products while other products where 
     *     hidden. This will allow the hidden products to be displayed
     */
    if(isShoppingOnStoreCard || isShoppingOnStorePage || isShoppingOnStoreOrdersModalBottomSheet) {

      setState(() {
        setSelectedProductIds();
        autoToggleShowAllProducts();
      });

    }
    
  }

  void setSelectedProductIds() {
    selectedProductIds = store == null ? [] : store!.selectedProducts.map((product) => product.id).toList();
  }

  void autoToggleShowAllProducts() {
    showAllProducts = hasSelectedProducts || isShoppingOnStorePage;
  }
  
  void toggleShowAllProducts() => setState(() {   
    showAllProducts = !showAllProducts;
  });

  Widget content() {
    return Column(
      key: ValueKey('$showAllProducts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// More Information Message
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: hasSelectedProducts ? const CustomMessageAlert(
                'Swipe to the right for more information',
                margin: EdgeInsets.only(bottom: 8),
              ) : null
            ),
          ),
        ),

        //  Product Cards
        ...filteredProducts.mapIndexed((index, product) {
          
          return ShoppableProductCard(
            product: product,
            showAllProducts: showAllProducts,
            selected: selectedProductIds.contains(product.id),
            margin: EdgeInsets.only(bottom: (index == filteredProducts.length - 1) ? 0 : 5)
          );
          
        }).toList(),

        //  Spacer
        if(canShowMoreOrLessButton) const SizedBox(height: 8,),

        /// Show More Or Less Button
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: canShowMoreOrLessButton ? ShowMoreOrLessButton(
                showAll: showAllProducts,
                toggleShowAll: toggleShowAllProducts
              ) : null
            ),
          ),
        ),

      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    /// Listen to changes on the Shoppable Store Model that was passed on 
    /// ListenableProvider.value() of the StoreCard. Once these changes
    /// occur, the didChangeDependencies() change will be notified
    /// first so that we can capture the store and its changes. We 
    /// can then run any other logic after the updated store is 
    /// retrieved. After the didChangeDependencies() completes
    /// its logic, this build() method will be called to
    /// rebuild the UI and implement any new changes.
    Provider.of<ShoppableStore>(context, listen: true);

    /**
     *  AnimatedSize helps to animate the sizing from a bigger height
     *  to a smaller height. When changing the content height, the 
     *  transition will be jumpy since the height is not the same.
     *  This helps animate those height differences.
     * 
     *  AnimatedSwitcher helps to animate the change of widgets
     *  by using an smooth opacity transition.
     */
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              child: content()
            )
          ),
        ],
      ),
    );
  }
}