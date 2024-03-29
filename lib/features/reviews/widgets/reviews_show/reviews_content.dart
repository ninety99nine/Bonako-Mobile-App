import '../../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../user/widgets/reviewer_profile/reviewer_profile_avatar.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../../../core/shared_models/user.dart';
import '../../../stores/models/shoppable_store.dart';
import 'reviews_in_vertical_scrollable_content.dart';
import '../review_create/review_create.dart';
import 'package:provider/provider.dart';
import 'reviews_page/reviews_page.dart';
import 'package:flutter/material.dart';
import '../../enums/review_enums.dart';
import '../../models/review.dart';
import 'package:get/get.dart';
import 'review_filters.dart';

class ReviewsContent extends StatefulWidget {
  
  final String? reviewFilter;
  final bool showingFullPage;
  final ShoppableStore? store;
  final void Function()? onCreatedReview;
  final ReviewContentView? reviewContentView;
  final UserReviewAssociation? userReviewAssociation;

  const ReviewsContent({
    super.key,
    this.store,
    this.reviewFilter,
    this.onCreatedReview,
    this.reviewContentView,
    this.userReviewAssociation,
    this.showingFullPage = false,
  });

  @override
  State<ReviewsContent> createState() => _ReviewsContentState();
}

class _ReviewsContentState extends State<ReviewsContent> {

  Review? review;
  String reviewFilter = 'All';
  bool disableFloatingActionButton = false;
  ReviewContentView reviewContentView = ReviewContentView.viewingReviews;

  /// This allows us to access the state of ReviewFilters widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  GlobalKey<ReviewFiltersState>? _reviewFiltersState;

  ShoppableStore? get store => widget.store;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  Function()? get onCreatedReview => widget.onCreatedReview;
  User? get reviewer => review == null ? null : review!.relationships.user;
  UserReviewAssociation? get userReviewAssociation => widget.userReviewAssociation;
  bool get isViewingReview => reviewContentView == ReviewContentView.viewingReview;
  bool get isViewingReviews => reviewContentView == ReviewContentView.viewingReviews;
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingMyReviews => userReviewAssociation == UserReviewAssociation.reviewer;
  
  String get title {
    if(isViewingReviews) {

      /// If the user wants to see reviews from stores where they are a reviewer
      if(userReviewAssociation == UserReviewAssociation.reviewer) {

        return 'My Reviews';

      /// If the user wants to see reviews from stores where they are a team member
      }else if(userReviewAssociation == UserReviewAssociation.teamMember) {

        return 'Customer Reviews';

      /// If the user wants to see reviews from anyone
      }else{
        
        return 'Reviews';
      
      }
    
    }else{
      
      return 'Add Review';
    
    }
  }
  
  String get subtitle {
    if(isViewingReviews) {

      /// If the user wants to see reviews from stores where they are a reviewer
      if(userReviewAssociation == UserReviewAssociation.reviewer) {

        return 'See what your experience has been';

      /// If the user wants to see reviews from stores where they are a team member
      }else if(userReviewAssociation == UserReviewAssociation.teamMember) {

        return 'See what customers have to say';

      /// If the user wants to see reviews from anyone
      }else{

        return 'See what others have to say';
      
      }

    }else{
      
      return 'Share your experience with us';
    
    }
  }
  
  @override
  void initState() {

    super.initState();

    /// If the review filter is provided
    if(widget.reviewFilter != null) {
      
      /// Set the provided review filter
      reviewFilter = widget.reviewFilter!;

    }

    /// If the reviewContentView is provided
    if(widget.reviewContentView != null) {
      
      /// Set the provided reviewContentView
      reviewContentView = widget.reviewContentView!;

    }

    /// Set the "_reviewFiltersState" so that we can access the ReviewFilters widget state
    _reviewFiltersState = GlobalKey<ReviewFiltersState>();

  }

  /// Content to show based on the specified view
  Widget get content {

    /// If we want to view the reviews content
    if(isViewingReviews || isViewingReview) {

      /// Show reviews view
      return ReviewsInVerticalScrollableContent(
        store: store,
        reviewer: reviewer,
        onViewReview: onViewReview,
        reviewFilter: reviewFilter,
        userReviewAssociation: userReviewAssociation
      );

    }else{

      /// Show the add review view
      return ReviewCreate(
        store: store,
        onLoading: onLoading,
        onCreatedReview: _onCreatedReview
      );

    }
    
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return CustomElevatedButton(
      width: 120,
      isViewingReviews ? 'Add Review' : 'Back',
      onPressed: floatingActionButtonOnPressed,
      prefixIcon: isViewingReviews ? Icons.add : Icons.keyboard_double_arrow_left,
    );

  }

  /// Action to be called when the floating action button is pressed 
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return; 

    /// If we are viewing the reviews content
    if(isViewingReviews) {

      /// Change to the add review view
      changeReviewContentView(ReviewContentView.addingReview);

    }else{
      
      /// Unset the review
      review = null;

      /// Change to the show reviews view
      changeReviewContentView(ReviewContentView.viewingReviews);

    }

  }

  /// While creating a review disable the floating action 
  /// button so that it can no longer perform any
  /// actions when clicked
  void onLoading(bool status) => disableFloatingActionButton = status;

  /// Change the view once we are done adding a review
  void _onCreatedReview() {
    if(onCreatedReview != null) onCreatedReview!();
    changeReviewContentView(ReviewContentView.viewingReviews);
  }

  /// Called when the review filter has been changed,
  /// such as changing from "All" to "Product"
  void onSelectedReviewFilter(String reviewFilter) {
    setState(() => this.reviewFilter = reviewFilter);
  }

  /// Make an Api Request to update the review filters so that we 
  /// can acquire the total count of reviews assigned to each 
  /// filter e.g "Customer Serview (30)" or "Product (20)"
  void requestStoreOrderFilters() {
    if(_reviewFiltersState!.currentState != null) _reviewFiltersState!.currentState!.requestReviewFilters();
  }

  /// Called to change the view from viewing reviews of multiple reviewers
  /// to viewing reviews of one specific reviewer
  void onViewReview(Review review) {
    if(!isViewingMyReviews) {
      this.review = review;
      changeReviewContentView(ReviewContentView.viewingReview);
    }
  }

  /// Called to change the view to the specified view
  void changeReviewContentView(ReviewContentView reviewContentView) {
    setState(() => this.reviewContentView = reviewContentView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(reviewContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: (review == null ? 32 : 16), bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      if(review == null) ...[
                
                        /// Title
                        CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                        
                        /// Subtitle
                        AnimatedSwitcher(
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          duration: const Duration(milliseconds: 500),
                          child: Align(
                            key: ValueKey(subtitle),
                            alignment: Alignment.centerLeft,
                            child: CustomBodyText(subtitle),
                          )
                        ),

                      ],

                      /// Reviewers Profile Avatar
                      if(reviewer != null) ReviewerProfileAvatar(review: review!),

                      //  Filters
                      if(isViewingReviews) ReviewFilters(
                        store: store,
                        key: _reviewFiltersState,
                        reviewFilter: reviewFilter,
                        userReviewAssociation: userReviewAssociation,
                        onSelectedReviewFilter: onSelectedReviewFilter
                      ),
                      
                    ],
                  ),
                ),

                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();

                /// Set the store
                if(store != null) storeProvider.setStore(store!);
                
                /// Navigate to the page
                Get.toNamed(ReviewsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingReviews ? 112 : (isViewingReview ? 52 : 64)) + topPadding,
            child: floatingActionButton
          )
        ],
      ),
    );
  }
}