import 'secondary_section_content/secondary_section_content.dart';
import '../../../../core/shared_widgets/cards/custom_card.dart';
import 'primary_section_content/primary_section_content.dart';
import '../../models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class StoreCard extends StatefulWidget {

  final ShoppableStore store;
  final Function onRefreshStores;
  
  const StoreCard({
    Key? key, 
    required this.store,
    required this.onRefreshStores,
  }) : super(key: key);

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  
  ShoppableStore? store;

  @override
  void initState() {
    super.initState();

    /// Set the store on this widget state
    store = widget.store;

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Set the StoreCard as the current view of the Shoppable Store Modal
    store!.shoppingCartCurrentView = ShoppingCartCurrentView.storeCard;

  }

  @override
  Widget build(BuildContext context) {
    /**
     * Notice the ListenableProvider.value() passes the store
     * as a value so that we can listen to changes on the 
     * store and update the widget tree as soon as those 
     * changes occur e.g
     * 
     * Starting shopping activity
     * Incrementing the total number of received orders after swipping to indicate
     * Incrementing the total number of reviews after adding a review
     * Incrementing the total number of followers after following
     * Incrementing the total number of reviews after reviewing
     * e.t.c
     */
    return ListenableProvider.value(
      value: store,
      child: Content(
        onRefreshStores: widget.onRefreshStores
      ),
    );
  }
}

class Content extends StatelessWidget {

  final Function onRefreshStores;

  const Content({
    super.key,
    required this.onRefreshStores,
  });

  @override
  Widget build(BuildContext context) {
    
    /**
     *  Capture the store that was passed on ListenableProvider.value()
     *  
     *  Set listen to "true'" to catch changes at this level of the
     *  widget tree. For now i have disabled listening as this
     *  level because i can listen to the store changes from
     *  directly on the ProductCards widget level, which is
     *  a descendant widget of this widget.
     */
    ShoppableStore store = Provider.of<ShoppableStore>(context, listen: true);
    bool hasProducts = store.relationships.products.isNotEmpty;

    return CustomCard(
      key: ValueKey<int>(store.id),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          //  Store Logo, Profile, Adverts, Rating, e.t.c
          StorePrimarySectionContent(
            store: store,
            onRefreshStores: onRefreshStores
          ),
          
          //  Spacer
          if(hasProducts) const SizedBox(height: 20),
    
          //  Store Products, Shopping Cart, e.t.c
          StoreSecondarySectionContent(store: store),
          
        ],
      ),
    );
  }
}

