import '../text_form_field/custom_search_text_form_field.dart';
import '../Loader/custom_circular_progress_indicator.dart';
import '../../../core/utils/api_conflict_resolver.dart';
import '../message_alert/custom_message_alert.dart';
import '../../../core/utils/debouncer.dart';
import '../checkbox/custom_checkbox.dart';
import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:async';

enum RequestType {
  startRequest,
  continueRequest
}

class CustomVerticalListViewInfiniteScroll extends StatefulWidget {

  final bool disabled;
  final String? searchWord;
  final bool showSearchBar;
  final bool showSeparater;
  final bool debounceSearch;
  final String catchErrorMessage;
  final EdgeInsets? margin;
  final EdgeInsets listPadding;
  final EdgeInsets headerPadding;
  final EdgeInsets multiSelectActionsPadding;
  final Widget? separator;

  /// Indication that we should list the items in reverse order e.g 
  /// The first item goes to the bottom instead of the top, and the
  /// last item goes to the top instead of the bottom
  final bool reverse;

  /// Indication that we can reoder
  final bool canReorder;

  /// Method to call on reorder
  final Function(int, int)? onReorder;

  /// Parent ScrollController
  final ScrollController? scrollController;

  /// Content to show above the search bar
  final Widget Function(bool, int)? contentBeforeSearchBar;

  /// Content to show below the search bar
  final Widget? contentAfterSearchBar;

  /// Method to implement the Api Request
  final Future<dio.Response> Function(int page, String searchWord) onRequest;

  /// Method to implement conversion of the Api Request
  /// data retrieved into the desired Model data output
  /// We feed the data which is a Map of json data and
  /// the method converts it into a properly structured
  /// Model, for instance using Store.fromJson(). This
  /// method must return an output.
  final Function(Map) onParseItem;

  /// Method to implement the build of each list item
  final Widget Function(dynamic item, int index, List<dynamic> items, bool isSelected, List<dynamic> selectedItems, bool hasSelectedItems, int totalSelectedItems) onRenderItem;

  /// Show the no content text when we don't have
  /// initial content
  final bool showNoContent;

  /// Mesage to show when there is no content to show
  final String noContent;

  /// Widget to show when there is no content to show
  final Widget? noContentWidget;

  /// Show the no more content text when we don't have
  /// anymore content to load while scrolling down
  final bool showNoMoreContent;

  /// Mesage to show when there is no more content to show
  final String noMoreContent;

  /// Widget to show when there is no more content to show
  final Widget? noMoreContentWidget;

  /// The margin of the loader that is show when the
  /// showFirstRequestLoader has been set to false
  final EdgeInsets loaderMargin;

  /// Whether to show the loader that hides all the content on
  /// the first request or to hide this loader so that part of
  /// the content can appear e.g the contentBeforeSearchBar
  /// and contentAfterSearchBar can be shown while the
  /// content is still loading
  final bool showFirstRequestLoader;

  /// Condition to determine whether to add or remove an item
  /// from the list of selected items. This allows us to
  /// define the best logical check that insures that we
  /// can either add or remove an item based on whether
  /// it has already been selected on not.
  final bool Function(dynamic selectedItem, dynamic item)? toggleSelectionCondition;

  /// Method to call to notify parent on selected items
  final Function(List)? onSelectedItems; 

  /// Widget to show when we have selected items
  final Widget Function(bool)? selectedAllAction;

  /// Notify the parent widget on the loading status
  final Function(bool)? onLoading;

  /// Notify the parent widget on the loading status after first request
  final Function(bool)? onLoadingAfterFirstRequest;

  /// Notify the parent widget on the loading status
  final Function(bool)? onSearching;

  const CustomVerticalListViewInfiniteScroll({
    Key? key,
    this.margin,
    this.separator,
    this.onReorder,
    this.onLoading,
    this.searchWord,
    this.onSearching,
    this.reverse = false,
    this.noContentWidget,
    this.onSelectedItems,
    this.scrollController,
    this.disabled = false,
    this.selectedAllAction,
    this.canReorder = false,
    required this.onRequest,
    this.noMoreContentWidget,
    this.showNoContent = true,
    this.showSearchBar = true,
    this.showSeparater = true,
    required this.onParseItem,
    required this.onRenderItem,
    this.contentAfterSearchBar,
    this.contentBeforeSearchBar,
    this.debounceSearch = false,
    this.showNoMoreContent = true,
    this.toggleSelectionCondition,
    this.onLoadingAfterFirstRequest,
    required this.catchErrorMessage,
    this.showFirstRequestLoader = true,
    this.noContent = 'No results found',
    this.noMoreContent = 'No more results found',
    this.loaderMargin = const EdgeInsets.symmetric(vertical: 16),
    this.listPadding = const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
    this.headerPadding = const EdgeInsets.only(top: 20, bottom: 0, left: 16, right: 16),
    this.multiSelectActionsPadding = const EdgeInsets.only(top: 16, bottom: 16, left: 0, right: 16),
  }) : super(key: key);

  @override
  State<CustomVerticalListViewInfiniteScroll> createState() => CustomVerticalListViewInfiniteScrollState();
}

class CustomVerticalListViewInfiniteScrollState extends State<CustomVerticalListViewInfiniteScroll> {

  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  RequestType requestType = RequestType.startRequest;
  late ScrollController scrollController;
  
  bool hasShownSearchBarBefore = false;
  bool sentFirstRequest = false;
  bool isLoading = false;
  String searchWord = '';
  bool hasError = false;
  List data = [];
  int? lastPage;
  int page = 1;

  int forceRenderListView = 0;
  int get totalItems => data.length;
  bool get reverse => widget.reverse;
  bool get disabled => widget.disabled;
  String get noContent => widget.noContent;
  bool get canReorder => widget.canReorder;
  Widget? get separator => widget.separator;
  bool get showNoContent => widget.showNoContent;
  bool get showSearchBar => widget.showSearchBar;
  bool get showSeparater => widget.showSeparater;
  bool get debounceSearch => widget.debounceSearch;
  String get noMoreContent => widget.noMoreContent;
  Function(bool)? get onLoading => widget.onLoading;
  EdgeInsets get loaderMargin => widget.loaderMargin;
  Function(Map) get onParseItem => widget.onParseItem;
  Widget? get noContentWidget => widget.noContentWidget;
  Function(bool)? get onSearching => widget.onSearching;
  Function(int, int)? get onReorder => widget.onReorder;
  bool get showNoMoreContent => widget.showNoMoreContent;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  String get catchErrorMessage => widget.catchErrorMessage;
  Widget? get noMoreContentWidget => widget.noMoreContentWidget;
  bool get showFirstRequestLoader => widget.showFirstRequestLoader;
  Widget? get contentAfterSearchBar => widget.contentAfterSearchBar;
  bool get isStartingRequest => requestType == RequestType.startRequest;
  bool get loadedLastPage => lastPage == null ? false : page > lastPage!;
  bool get isUsingParentScrollController => widget.scrollController != null;
  bool get isContinuingRequest => requestType == RequestType.continueRequest;
  Future<dio.Response> Function(int, String) get onRequest => widget.onRequest;
  EdgeInsets get multiSelectActionsPadding => widget.multiSelectActionsPadding;
  bool get isSearching => isStartingRequest && isLoading && searchWord.isNotEmpty;
  Function(bool)? get onLoadingAfterFirstRequest => widget.onLoadingAfterFirstRequest;
  Widget Function(bool, int)? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  Widget Function(dynamic item, int index, List<dynamic> items, bool isSelected, List<dynamic> selectedItems, bool hasSelectedItems, int totalSelectedItems) get onRenderItem => widget.onRenderItem;

  /// Multiple select item properties
  bool selectedAll = false;
  List selectedItems = [];  
  int get totalSelectedItems => selectedItems.length;
  bool get hasSelectedItems => selectedItems.isNotEmpty;
  Function(List)? get onSelectedItems => widget.onSelectedItems;
  Widget Function(bool)? get selectedAllAction => widget.selectedAllAction;
  bool Function(dynamic selectedItem, dynamic item)? get toggleSelectionCondition => widget.toggleSelectionCondition;

  bool get canLoadMore {
    /**
     *  We can load more if:
     * 
     *  1) We are not currently loading
     *  2) We want to load a page before the last page or the last page itself
     */
    return !isLoading && page <= lastPage!;
  }

  @override
  void initState() {
    
    super.initState();

    /// If the scroll controller is provided
    if(isUsingParentScrollController) {

      /// Use the provided scroll controller
      scrollController = widget.scrollController!;

    }else{
      
      /// Create a new scroll controller
      scrollController = ScrollController();
      
    }

    /// Set the local state searchWord using the widget searchWord (if provided)
    if(widget.searchWord != null) searchWord = widget.searchWord!; 

    /// Load initial content (page 1)
    startRequest();
    
    /**
     *  This scrollController is used to check if we have scrolled to the
     *  bottom of the scroll view so that we can load more content 
     */
    scrollController.addListener(() {

      /// Get the screen height and divide by two
      final double halfScreenHeight = MediaQuery.of(context).size.height;

      /// Get the available scroll height
      final double availableScrollableHeight = scrollController.position.maxScrollExtent;

      /// Check if we are half the screen height from the bottom of the scrollable area
      final bool isHalfScreenHeightFromTheBottom = scrollController.offset > (availableScrollableHeight - halfScreenHeight);
      
      /// If we have scrolled half the screen size from the bottom, 
      /// then check if we can start loading more content
      if( isHalfScreenHeightFromTheBottom ) {

        /// Check if we can load anymore more content
        if(!canLoadMore) return;

        /// Load additional content (page 2, 3, 4, e.t.c)
        continueRequest();

      }

    });

  }

  @override
  void dispose() {
    super.dispose();

    /// If we created the scroll controller on this widget, then let us dispose of it
    if(!isUsingParentScrollController) scrollController.dispose();
  }
  
  @override
  void didUpdateWidget(covariant CustomVerticalListViewInfiniteScroll oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the search word changed
    if(widget.searchWord != oldWidget.searchWord && oldWidget.searchWord != null) {

      /// Set the search word
      searchWord = widget.searchWord!;
          
      /// Start search
      onSearch(searchWord);

    }

  }

  void setHasError(bool status) {
    if(!mounted) return;
    setState(() => hasError = status);
  }

  setData(data) {
    setState(() {
      this.data = data;
    });
  }

  getItemAt(int index) {
    return data[index];
  }

  int removeItemAt(int index) {
    setState(() => data.removeAt(index));
    return totalItems;
  }

  int removeAllItems() {
    setState(() => data = []);
    return 0;
  }

  int insetItemAt(int index, item) {
    setState(() => data.insert(index, item));
    return totalItems;
  }

  void updateItemAt(int index, item) {
    setState(() => data[index] = item);
  }

  Future<dio.Response> startRequest() {
    return makeApiRequest(RequestType.startRequest);
  }

  Future<dio.Response> continueRequest() {
    return makeApiRequest(RequestType.continueRequest);
  }

  Future<dio.Response> makeApiRequest(RequestType requestType) async {

    /// Disable showing any errors
    if(hasError) setHasError(false);

    //  Capture the request type
    this.requestType = requestType;
    
    /// Reset the page to 1 if we are starting a request
    if(isStartingRequest) page = 1;

    /// The apiConflictResolverUtility resoloves the comflict of 
    /// retrieving data returned by the wrong request. Whenever
    /// we make multiple requests, we only ever want the data 
    /// of the last request and not any other request.
    return apiConflictResolverUtility.addRequest(
      
      /// The request we are making
      onRequest: () => onRequest(page, searchWord), 
      
      /// The response returned by the last request
      onCompleted: (response) {

        if(mounted) {

          if( response.statusCode == 200) {

            setState(() {
              
              /// Add the list of items to the existing data items
              final requestData = (response.data['data'] as List).map((item) {

                /// Convert the json data into a structured Model
                return onParseItem(item);

              }).toList();

              if(isStartingRequest) {
                
                /// Overide existing data
                data = requestData;

                /// Force Re-render so that we do not have a confusion of item keys in the case
                /// that we have made an initial request before and loaded content, but then 
                /// decided to make another "startRequest" to replace this current data 
                /// instead of making a "continueRequest" to prepend data. In such a
                /// situation Flutter might want to keep some widgets that seem to
                /// be the same, but usually the widgets are the same in structure
                /// but containing different data. To be on the safe side, we want
                /// to force a re-render so that we don't have to worry about this
                forceRenderListView++;

              }else if(isContinuingRequest) {
                
                /// Append to existing data
                data.addAll(requestData);

              }

              /// Set the last page
              lastPage = response.data['lastPage'];

              /// Increment the page to load the next batch of data items
              if(page <= lastPage!) page++;

              /// Indicate that we have made the first request
              sentFirstRequest = true;
              
              determineSelectAll();

            });

          }
          
          if( response.statusCode! >= 400 ) {

            /// We have a server side error
            setHasError(true);

          }

        }

      }, 
      
      /// What to do while the request is loading
      onStartLoader: () {
        if(mounted) _startLoader();
        if(onLoading != null) onLoading!(true);
        if(onLoadingAfterFirstRequest != null && sentFirstRequest) onLoadingAfterFirstRequest!(true);

        /// Note that the onSearching() must be declared after the 
        /// _startLoader() because it depends on the isLoading property
        if(onSearching != null && isSearching) onSearching!(true);
      },
      
      /// What to do when the request completes
      onStopLoader: () {
        if(mounted) _stopLoader();
        if(onLoading != null) onLoading!(false);
        if(onLoadingAfterFirstRequest != null && sentFirstRequest) onLoadingAfterFirstRequest!(false);

        /// Note that the onSearching() must be declared after the 
        /// _startLoader() because it depends on the isLoading property
        if(onSearching != null && !isSearching) onSearching!(false);
      },

    /// On Error
    );

  }

  void onSearch(String searchWord) {
    if(debounceSearch) {
      debouncerUtility.run(() {
        startRequest();
      });
    }else{
      startRequest();
    }
  }

  void scrollToTop({ milliseconds = 500 }) {
    Future.delayed(const Duration(milliseconds: 500)).then((_) {

      if(milliseconds == 0) {
        
        scrollController.jumpTo(0);

      }else{

        scrollController.animateTo( 
          0,
          curve: Curves.easeOut,
          duration: Duration(milliseconds: milliseconds),
        );

      }

    });
  }

  void scrollToBottom({ milliseconds = 500 }) {

    /**
     *  We use the Future.delayed() method to wait until the 500 milliseconds
     *  duration required to animated the widgets whenever the UI is updated.
     *  This gives the scrollController time to know the maxScrollExtent
     *  before we actually start scrolling.
     */
    Future.delayed(const Duration(milliseconds: 500)).then((_) {

      if(milliseconds == 0) {
        
        scrollController.jumpTo(scrollController.position.maxScrollExtent);

      }else{

        scrollController.animateTo( 
          curve: Curves.easeOut,
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: milliseconds),
        );

      }

    });

  }

  /// Determine if we have selected all items by setting the 
  /// "selectedAll" property equal to "true" if we have 
  /// selected all items
  void determineSelectAll() => setState(() => selectedAll = data.length == selectedItems.length);

  /// Toggle selection
  void toggleSelection(item) {

    /// If the toggleSelectionCondition is provided
    if(toggleSelectionCondition != null) {

      /// Check if this item has already been selected
      final alreadySelected = hasAlreadySelectedItem(item);
      
      /// If the item is already selected
      if( alreadySelected ) {

        /// Remove the item
        removeSelectedItemWhere(item);

      /// Otherwise if the item has not already been selected
      }else{

        /// Add the item
        addSelectedItem(item);

      }
    
      /// Determine if we have selected all items
      determineSelectAll();

      /// If the onSelectedItems is provided
      if(onSelectedItems != null) {
        
        /// Notify the parent widget of the selected items
        onSelectedItems!(selectedItems);

      }

    }

  }

  /// Check if the selected item is already selected based on the given condition
  bool hasAlreadySelectedItem(selectedItem) {
    if(toggleSelectionCondition == null) return false; 
    return selectedItems.any((alreadySelectedItem) => toggleSelectionCondition!(alreadySelectedItem, selectedItem));
  }

  /// Add the selected item to the list of selected items
  void addSelectedItem(item) {
    selectedItems.add(item);
  }

  /// Remove the selected item from the list of selected items based on the given condition
  void removeSelectedItemWhere(selectedItem) {
    if(toggleSelectionCondition == null) return; 
    selectedItems.removeWhere((alreadySelectedItem) => toggleSelectionCondition!(alreadySelectedItem, selectedItem));
  }

  /// Unselect team members
  void unselectSelectedItems() {
    setState(() {
      selectedItems = [];
      selectedAll = false;

      /// If the onSelectedItems is provided
      if(onSelectedItems != null) {
        
        /// Notify the parent widget of the selected items
        onSelectedItems!(selectedItems);

      }
    });
  }

  Widget buildItem(int index) {

    final item = data[index];

    /// Check if this item is selected
    final isSelected = hasAlreadySelectedItem(item);

    /// Build the custom Item Widget
    return onRenderItem(item, index, data, isSelected, selectedItems, hasSelectedItems, totalSelectedItems);
  
  }

  /// Show the multi select actions
  Widget get multiSelectActions {

    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: hasSelectedItems ? Container(
            margin: multiSelectActionsPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: selectAllCheckbox
                ),
                if(selectedAllAction != null) selectedAllAction!(isLoading)
              ],
            ),
          ) : null,
        ),
      ),
    );
  }

  /// Show the select all checkbox
  Widget get selectAllCheckbox {
    return CustomCheckbox(
      text: CustomBodyText([
        totalSelectedItems.toString(),
        ' selected'
      ]),
      value: selectedAll,
      disabled: disabled,
      onChanged: (status) {

        unselectSelectedItems();
        
        if(status == true) {

          /// Select every permission available
          for (var i = 0; i < data.length; i++) {
            
            final item = data[i];

            /// Select each team member
            toggleSelection(item);
          
          }

        }
        
      }
    );
  }
  bool get canShowSearchBar {
    /**
     *  Show the search bar if
     * 
     *  1) We made it clear that we want to enable search
     *  2) We made our first request with a search term or we made 
     *     our first request without a search term and the entire 
     *     dataset is separated into more than one page or we
     *     have shown the search bar at least once before
     *     
     */
    final bool hasSearchTerm = searchWord.isNotEmpty;
    final bool hasNoSearchTermButHasManyPages = searchWord.isEmpty && (lastPage == null ? false : lastPage! > 1);
    
    if(showSearchBar && sentFirstRequest && (hasSearchTerm || hasNoSearchTermButHasManyPages || hasShownSearchBarBefore)) {
      return hasShownSearchBarBefore = true;
    }else{
      return false;
    }
  }

  Widget get _noContentWidget {
    return noContentWidget == null ? Center(
      child: CustomBodyText(
        noContent, 
        textAlign: TextAlign.center, 
        margin: const EdgeInsets.only(top: 20, bottom: 100),
      ),
    ) : noContentWidget!;
  }

  Widget get searchInputField {  
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: CustomSearchTextFormField(
        initialValue: searchWord,
        isLoading: isSearching,
        enabled: !disabled,
        onChanged: (searchWord) {
        
          if(!mounted) return;

          /// Update local state
          setState(() => this.searchWord = searchWord);
          
          /// Start search
          onSearch(this.searchWord);

        }
      ),
    );
  }
  
  Widget get contentListWidget {
    /**
     * SingleChildScrollView is required to show other widgets in a Column along with the
     * ListView widget. Setting the "shrinkWrap=true" forces ListView to take only the required space, 
     * and not the entire screen. Setting "physics=NeverScrollableScrollPhysics()" disables scrolling 
     * functionality of ListView, which means now we have only SingleChildScrollView who provide the 
     * scrolling functionality.
     * 
     * Reference: https://stackoverflow.com/questions/56131101/how-to-place-a-listview-inside-a-singlechildscrollview-but-prevent-them-from-scr
     * 
     * The scrollController helps us to track the scrolling e.g how much we scrolled up or down.
     * We can use this information to decide whether to load more content or not.
     */
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        /**
         *  Check if the widget.scrollController is provided. If it is provided then we know that the scrollController is provided
         *  by the parent widget and therefore has already been assigned to the parent widget's SingleChildScrollView() controller.
         *  This means we should avoid re-assigning the same widget.scrollController to this SingleChildScrollView() and we should
         *  disable the scrolling functionality using NeverScrollableScrollPhysics() so that we are only listening to the scroll
         *  activity on the parent widget's SingleChildScrollView() widget.
         */
        reverse: reverse,
        controller: isUsingParentScrollController ? null : scrollController,
        physics: isUsingParentScrollController ? const NeverScrollableScrollPhysics() : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// On Error
            if(hasError) Column(
              children: [
                
                /// Show Catch Error Message
                CustomMessageAlert(
                  catchErrorMessage,
                  margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16)
                ),

                /// Warning Icon
                Icon(Icons.warning_amber_rounded, size: 100, color: Colors.grey.shade200),

              ],
            ),
      
            if(hasError == false) Container(
              padding: widget.headerPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
      
                  /// Content Before Search Bar Widget
                  if(contentBeforeSearchBar != null) contentBeforeSearchBar!(isLoading, totalItems),
      
                  /// Search Input Field Widget
                  if(canShowSearchBar) searchInputField,
      
                  /// Content After Search Bar Widget
                  if(contentAfterSearchBar != null) contentAfterSearchBar!,

                  multiSelectActions,
      
                  /// No content (Show after sending first request)
                  if(sentFirstRequest && showNoContent) AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: isLoading ? 0.3 : 1,
                    child: data.isEmpty ? _noContentWidget : null,
                  ),
      
                ],
              ),
            ),

            /// Loader (Show while loading and when we haven't sent our first request)
            if(isLoading && !sentFirstRequest) CustomCircularProgressIndicator(
              margin: loaderMargin,
            ),

            /// ListView
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isStartingRequest && isLoading ? 0.3 : 1,
              child: canReorder ? reorderableListView() : listView(),
            ),
          
          ],
        ),
      ),
    );
  }

  Widget listView() {

    return ListView.separated(
      key: ValueKey(forceRenderListView),
      reverse: reverse,
      shrinkWrap: true,
      itemCount: totalItems,
      padding: widget.listPadding,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (BuildContext context, int index) => showSeparater ? (separator ?? const Divider()) : const SizedBox(),
      itemBuilder: ((context, index) {
        
        final Widget singleItem = buildItem(index);

        final Widget singleItemAndNoMoreContent = Column(
          children: [

            /// No more content widget
            if(reverse == true) noMoreContentWidget == null ? CustomBodyText(
              textAlign: TextAlign.center,
              showNoMoreContent ? noMoreContent : '',
              margin: const EdgeInsets.only(top: 20, bottom: 20),
            ) : noMoreContentWidget!,

            /// Single Item
            singleItem,

            /// No more content widget
            if(reverse == false) noMoreContentWidget == null ? CustomBodyText(
              textAlign: TextAlign.center,
              showNoMoreContent ? noMoreContent : '',
              margin: const EdgeInsets.only(top: 20, bottom: 100),
            ) : noMoreContentWidget!,

          ],
        );

        final Widget singleItemAndLoader = Column(
          children: [

            /// Loader (Shows up when more content is loading)
            if(reverse == true) const CustomCircularProgressIndicator(size: 20, margin: EdgeInsets.only(top: 32, bottom: 32),),

            /// Single Item
            singleItem,

            /// Loader (Shows up when more content is loading)
            if(reverse == false) const CustomCircularProgressIndicator(size: 20, margin: EdgeInsets.only(top: 32, bottom: 60),)
          
          ],
        );

        if(index == 0) {

          /// If this is the first and only item
          if(totalItems == 1) {

            /// Return the single Item Widget
            return singleItemAndNoMoreContent;

          /// If this is the first item, but not the only item
          }else{
    
            /// Build Custom Item Widget
            return singleItem;

          }
  
        }else{
          
          /// If this is the last item and we are loading on a continuing request
          if(isLoading && (index == totalItems - 1) && isContinuingRequest) {
            
            /// Return the item widget and loader
            return singleItemAndLoader;
      
          /// If this is the last item and have loaded every store
          }else if(loadedLastPage && (index == totalItems - 1)) {
            
            /// Return the single Item Widget
            return singleItemAndNoMoreContent;
    
          }else{
    
            /// Return the built item widget
            return singleItem;
    
          }
    
        }
    
      })
    );

  }

  Widget reorderableListView() {

    return ReorderableListView.builder(
      key: ValueKey(forceRenderListView),
      reverse: reverse,
      shrinkWrap: true,
      onReorder: onReorder!,
      itemCount: totalItems,
      padding: widget.listPadding,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: ((context, index) {

        Key itemKey = ValueKey<int>(data[index].id);

        final Widget singleItem = Column(
          key: itemKey,
          children: [

            /// Build Custom Item Widget
            buildItem(index),

          ],
        );

        final Widget singleItemAndDivider = Column(
          key: itemKey,
          children: [

            if(reverse == true) ...[

              /// Divider
              const Divider(height: 0,),

              /// Spacer
              const SizedBox(height: 8),
              
            ],

            /// Build Custom Item Widget
            buildItem(index),

            if(reverse == false) ...[

              /// Spacer
              const SizedBox(height: 8),

              /// Divider
              const Divider(height: 0,)
              
            ]

          ],
        );

        final Widget singleItemAndLoader = Column(
          key: itemKey,
          children: [

            /// Loader (Shows up when more content is loading)
            if(reverse == true) const CustomCircularProgressIndicator(size: 20, margin: EdgeInsets.only(top: 32, bottom: 32),),

            /// Build Custom Item Widget
            buildItem(index),

            /// Loader (Shows up when more content is loading)
            if(reverse == false) const CustomCircularProgressIndicator(size: 20, margin: EdgeInsets.only(top: 32, bottom: 60),)
          
          ],
        );
        
        if(index == 0) {

          /// If this is the first and only item
          if(totalItems == 1) {

            /// Return the single Item Widget
            return singleItem;

          /// If this is the first item, but not the only item
          }else{
    
            /// Return the Custom Item Widget and Divider
            return singleItemAndDivider;

          }
  
        }else{
          
          /// If this is the last item and we are loading on a continuing request
          if(isLoading && (index == totalItems - 1) && isContinuingRequest) {
            
            /// Return the item widget and loader
            return singleItemAndLoader;
      
          /// If this is the last item and have loaded every store
          }else if(loadedLastPage && (index == totalItems - 1)) {
            
            /// Return the single Item Widget
            return singleItem;
    
          }else{
    
            /// Return the Custom Item Widget and Divider
            return singleItemAndDivider;
    
          }
    
        }
    
      })
    );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: RefreshIndicator(
        onRefresh: startRequest,
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: (showFirstRequestLoader && isLoading && !sentFirstRequest) 
            ? const CustomCircularProgressIndicator()
            : contentListWidget,
        )
      ),
    );
  }
}