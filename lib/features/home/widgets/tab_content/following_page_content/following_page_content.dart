import 'package:bonako_demo/core/utils/debouncer.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/following_page_content/brand_stores_content/brand_stores_content.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/following_page_content/invitations_to_follow_store_banner/invitations_to_follow_store_banner.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/features/home/providers/home_provider.dart';
import 'package:bonako_demo/features/home/widgets/tab_content/following_page_content/my_plug_stores_content/my_plug_stores_content.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/home/services/home_service.dart';
import 'influencer_stores_content/influencer_stores_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class FollowingPageContent extends StatefulWidget {
  const FollowingPageContent({super.key});

  @override
  State<FollowingPageContent> createState() => _FollowingPageContentState();
}

class _FollowingPageContentState extends State<FollowingPageContent> with SingleTickerProviderStateMixin /*, AutomaticKeepAliveClientMixin */ {

  /*
   *  Reason for using AutomaticKeepAliveClientMixin
   * 
   *  We want to preserve the state of this Widget when using the TabBarView()
   *  to swipe between the Profile, Following, My Stores, e.t.c. The natural
   *  Flutter behaviour when swipping between these tabs is to destroy the
   *  current tab content while switching to the new tab content. By using
   *  the AutomaticKeepAliveClientMixin, we can preserve the state so that
   *  the current state data is not destroyed. When switching back to this
   *  tab, the content will be exactly as it was before switching away.
   * 
   *  Reference: https://stackoverflow.com/questions/55850686/why-is-flutter-disposing-my-widget-state-object-in-a-tabbed-interface
   * 
   *  @override
   *  bool wantKeepAlive = true;
  */
  int totalTabs = 3;
  bool canShow = true;
  late final TabController _tabController;
  ScrollController? storeCardsScrollController;
  bool isLoadingTheLastSelectedFollowingTabIndexFromDeviceStorage = true;
  int get selectedFollowingTabIndex => homeProvider.selectedFollowingTabIndex;
  bool get hasStoreCardsScrollController => storeCardsScrollController != null;
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  HomeProvider get homeProvider => Provider.of<HomeProvider>(context, listen: false);

  final GlobalKey<MyPlugStoresContentState> myPlugStoresContentState = GlobalKey<MyPlugStoresContentState>();
  final GlobalKey<BrandStoresContentState> brandStoresContentState = GlobalKey<BrandStoresContentState>();
  final GlobalKey<InfluencerStoresContentState> influencerStoresContentState = GlobalKey<InfluencerStoresContentState>();

  /// The scroll controller used to track the scroll position on the store cards of the My Plug Stores Content
  ScrollController? get myPlugStoreCardsScrollController {
    return myPlugStoresContentState.currentState?.storeCardsState.currentState?.customVerticalListViewInfiniteScrollState.currentState?.scrollController;
  }

  /// The scroll controller used to track the scroll position on the store cards of the Brand Stores Content
  ScrollController? get brandStoreCardsScrollController {
    return brandStoresContentState.currentState?.storeCardsState.currentState?.customVerticalListViewInfiniteScrollState.currentState?.scrollController;
  }

  /// The scroll controller used to track the scroll position on the store cards of the Influencer Stores Content
  ScrollController? get influencerStoreCardsScrollController {
    return influencerStoresContentState.currentState?.storeCardsState.currentState?.customVerticalListViewInfiniteScrollState.currentState?.scrollController;
  }

  @override
  void initState() {
    super.initState();
    setTabControllerListener();
    Future.delayed(Duration.zero).then((value) => getSelectedFollowingTabIndexFromDeviceStorage());
  }

  ///  The setTabControllerListener() method is used to setup the TabController
  ///  as well as add a listener on the TabController so that we can track
  ///  when the TabController switches from one tab to another by either
  ///  tapping on the navigation tabs of swipping through the content.
  void setTabControllerListener() {    

    /// Initialise the TabController so that we can track the tab navigation
    _tabController = TabController(initialIndex: selectedFollowingTabIndex, length: totalTabs, vsync: this);
    
    /// Add a listener to this _tabController so that we can track if we have navigated
    /// to a different tab by swipping between the navigation content or by tapping on
    /// the navigation tabs
    _tabController.addListener(() {

      /// If we are done loading the last selected tab
      if(isLoadingTheLastSelectedFollowingTabIndexFromDeviceStorage == false) {

        /// Check if the selected tab is the same as the current selected tab
        final bool theSelectedTabIsTheSameAsTheCurrentSelectedTab = selectedFollowingTabIndex == _tabController.index;

        /// If the selected tab is not the same as the current selected tab
        if(theSelectedTabIsTheSameAsTheCurrentSelectedTab == false) {
        
          /// Then save the current selected tab so that we can automatically
          /// load this same tab whenever that app is reloaded. This will be
          /// handled by the getSelectedFollowingTabIndexFromDeviceStorage()
          /// method.
          homeProvider.setSelectedFollowingTabIndex(_tabController.index);

        }

      }

      setStoreCardsScrollController();

    });
  }


  ///  The getSelectedFollowingTabIndexFromDeviceStorage method is used to 
  ///  get the last selected tab so that we can set this last selected tab 
  ///  as the initial active tab. This way we can always show the content 
  ///  of the last selected tab, making it convenient for the user.
  void getSelectedFollowingTabIndexFromDeviceStorage() {

    /// Check the device storage for the last selected tab index
    HomeService.getSelectedFollowingTabIndexFromDeviceStorage().then((lastSelectedFollowingTabIndex) {

      /// Check if the last selected tab is the same as the current selected tab
      final bool theLastSelectedTabIsTheSameAsTheCurrentSelectedTab = lastSelectedFollowingTabIndex == _tabController.index;

      /// If the last selected tab is not the same as the current selected tab
      if(theLastSelectedTabIsTheSameAsTheCurrentSelectedTab == false) {

        /// Set the HomeProvider tab to match the last selected tab
        homeProvider.setSelectedFollowingTabIndex(lastSelectedFollowingTabIndex, saveOnLocalStorage: false);

        /// Automatically navigate to the last selected tab
        _tabController.animateTo(lastSelectedFollowingTabIndex);

      }
      
      setState(() {
        
        /// Indicate that we are done loading the last selected tab
        isLoadingTheLastSelectedFollowingTabIndexFromDeviceStorage = false;

      });
      
    });

  }

  void setStoreCardsScrollController() {

    //  Set canShow to true by default
    setState(() => canShow = true);

    /**
     *  Since the following widgets: MyPlugStoresContent(), BrandStoresContent() and InfluencerStoresContent()
     *  take time to build, its not possible to immediately access the state of either one of the widgets. We
     *  need to set a delay that allows the widget so build and the state to be resolved before we can
     *  attempt to access that state. Any attempt to access the state before the widget is fully built
     *  will return null as a value instead of the widget's state. In this case we set the delay to
     *  1 second so that we can give the widget enough time to build. We used to use the Future()
     *  method like this:
     * 
     *  Future.delayed(const Duration(seconds: 1)).then((value) { ... }
     * 
     *  But now i prefer that we use the debouncerUtility class to take care of the delay.
     * 
     *  debouncerUtility.run(() { ... }
     * 
     *  This can also avoid any clashes caused by calling this setStoreCardsScrollController()
     *  method multiple times before one second elapses.
     */
    debouncerUtility.run(() {
      setState(() {

        //  If the scroll controller was previously set
        if(hasStoreCardsScrollController) {

          // Stop listening to the previously set scroll controller
          storeCardsScrollController!.removeListener(updateCanShow);

        }

        if(homeProvider.hasSelectedMyPlugStores) {
          storeCardsScrollController = myPlugStoreCardsScrollController;
        }else if(homeProvider.hasSelectedBrandStores) {
          storeCardsScrollController = brandStoreCardsScrollController;
        }else {
          storeCardsScrollController = influencerStoreCardsScrollController;
        }

        // Start listening to the newly set scroll controller
        storeCardsScrollController?.addListener(updateCanShow);

      });
    });
  }

  void updateCanShow() {
    /// This scrollController is used to check if we are scrolling so
    /// that we can dynamically hide or show the invitation banner
    setState(() => canShow = storeCardsScrollController!.offset <= 100);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    storeCardsScrollController?.dispose();
  }
  
  Widget get followingNavigationTabs => TabBar(
    controller: _tabController,
    unselectedLabelColor: Colors.grey,
    labelColor: Theme.of(context).primaryColor,
    indicatorColor: Theme.of(context).primaryColor,
    labelStyle: Theme.of(context).textTheme.titleSmall,
    padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
    tabs: [

      /// My Plugs
      CircleAvatarTab(
        title: 'My Plugs',
        canShow: canShow,
        image: 'assets/images/following/my-plugs-icon.png'
      ),

      /// Brands
      CircleAvatarTab(
        title: 'Brands',
        canShow: canShow,
        image: 'assets/images/following/brands-icon.png'
      ),

      /// Influencers
      CircleAvatarTab(
        title: 'Influencers',
        canShow: canShow,
        image: 'assets/images/following/influencers-icon.png'
      ),

    ] 
  );

  Widget get followingTabContent => TabBarView(
    controller: _tabController,
    children: [
      MyPlugStoresContent(
        key: myPlugStoresContentState
      ),
      BrandStoresContent(
        key: brandStoresContentState
      ),
      InfluencerStoresContent(
        key: influencerStoresContentState
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          
          SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  key: ValueKey(isLoadingTheLastSelectedFollowingTabIndexFromDeviceStorage),
                  children: isLoadingTheLastSelectedFollowingTabIndexFromDeviceStorage
                  ? [] 
                  : [

                      /// Tab Navigation
                      followingNavigationTabs,

                      /// Collapsable Banner To Follow Stores
                      InvitationsToFollowStoreBanner(
                        key: ValueKey(_tabController.index),
                        canShow: canShow
                      ),

                    ],
                  )
              )
            ),
          ),

          /// Tab Content
          Expanded(
            child: isLoadingTheLastSelectedFollowingTabIndexFromDeviceStorage
              /// Progress indicator while loading the last selected tab
              ? const Center(child: CustomCircularProgressIndicator())
              /// The following tab content
              : followingTabContent,
          )

        ],
      ),
    );
  }
}

class CircleAvatarTab extends StatefulWidget {

  final String image;
  final String title;
  final bool canShow;
  final EdgeInsets padding;

  const CircleAvatarTab ({
    super.key,
    required this.image,
    required this.title,
    required this.canShow,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  State<CircleAvatarTab> createState() => _CircleAvatarTabState();
}

class _CircleAvatarTabState extends State<CircleAvatarTab> with SingleTickerProviderStateMixin {

  bool get canShow => widget.canShow;
  late AnimationController _animationController;
  final Tween<double> _radiusTween = Tween<double>(begin: 0, end: 20);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      value: 1,
    );
  }
  
  @override
  void didUpdateWidget(covariant CircleAvatarTab oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the search word changed
    if(oldWidget.canShow != canShow) {

      setState(() {
        if (canShow) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });

    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      
        /// Circle Avatar
        AnimatedOpacity(
          opacity: canShow ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final radius = _radiusTween.evaluate(_animationController);
              return CircleAvatar(
                radius: radius,
                child: Padding(
                  padding: widget.padding,
                  child: Image.asset(widget.image),
                ),
              );
            },
          ),
        ),
      
        /// Title
        CustomBodyText(widget.title, margin: EdgeInsets.only(top: widget.canShow ? 16 : 0, bottom: 16),),
      
      ],
    );
  }
}