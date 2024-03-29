import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import '../../../../../core/shared_widgets/button/custom_text_button.dart';
import '../../../../friend_groups/models/friend_group.dart';
import '../../../../../core/shared_models/user.dart';
import '../../../enums/friend_enums.dart';
import 'package:flutter/material.dart';
import '../friends_content.dart';

class FriendsModalBottomSheet extends StatefulWidget {

  final Purpose purpose;
  final Function()? onClose;
  final Widget Function(Function())? trigger;
  final Function(List<User>)? onSelectedFriends;
  final Function(List<User>)? onDoneSelectingFriends;
  final Function(List<FriendGroup>)? onSelectedFriendGroups;
  final Function(List<FriendGroup>)? onDoneSelectingFriendGroups;

  const FriendsModalBottomSheet({
    super.key,
    this.onClose,
    this.trigger,
    required this.purpose,
    this.onSelectedFriends,
    this.onSelectedFriendGroups,
    this.onDoneSelectingFriends,
    this.onDoneSelectingFriendGroups,
  });

  @override
  State<FriendsModalBottomSheet> createState() => FriendsModalBottomSheetState();
}

class FriendsModalBottomSheetState extends State<FriendsModalBottomSheet> {

  Purpose get purpose => widget.purpose;
  Function()? get onClose => widget.onClose;
  Widget Function(Function())? get trigger => widget.trigger;
  Function(List<User>)? get onSelectedFriends => widget.onSelectedFriends;
  Function(List<User>)? get onDoneSelectingFriends => widget.onDoneSelectingFriends;
  Function(List<FriendGroup>)? get onSelectedFriendGroups => widget.onSelectedFriendGroups;
  Function(List<FriendGroup>)? get onDoneSelectingFriendGroups => widget.onDoneSelectingFriendGroups;
  

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  Widget get _trigger {

    Widget defaultTrigger;

    /// If the purpose is to select friends for an order
    if(purpose == Purpose.addFriendsToOrder) {
      
      defaultTrigger = Container();

    /// If the purpose is to select friends for a group
    }else{

      defaultTrigger = CustomTextButton(
        'Add Friends',
        prefixIcon: Icons.add,
        alignment: Alignment.center,
        onPressed: openBottomModalSheet,
      );

    }

    return trigger == null ? defaultTrigger : trigger!(openBottomModalSheet);
  
  }

  /// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      onClose: onClose,
      /// Content of the bottom modal sheet
      content: FriendsContent(
        purpose: purpose,
        onSelectedFriends: onSelectedFriends,
        onDoneSelectingFriends: onDoneSelectingFriends,
        onSelectedFriendGroups: onSelectedFriendGroups,
        onDoneSelectingFriendGroups: onDoneSelectingFriendGroups
      ),
    );
  }
}