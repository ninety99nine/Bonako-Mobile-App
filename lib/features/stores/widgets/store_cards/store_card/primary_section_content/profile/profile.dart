import 'package:bonako_demo/features/stores/widgets/subscribe_to_store/subscribe_to_store_modal_bottom_sheet/subscribe_to_store_modal_bottom_sheet.dart';
import 'package:bonako_demo/features/stores/services/store_services.dart';
import 'profile_right_side/profile_right_side.dart';
import '../../../../../models/shoppable_store.dart';
import 'profile_left_side/profile_left_side.dart';
import 'package:flutter/material.dart';

class StoreProfile extends StatefulWidget {

  final ShoppableStore store;
  final bool showProfileRightSide;
  final Alignment subscribeButtonAlignment;

  const StoreProfile({
    Key? key,
    required this.store, 
    this.showProfileRightSide = true,
    this.subscribeButtonAlignment = Alignment.centerRight
  }) : super(key: key);

  @override
  State<StoreProfile> createState() => _StoreProfileState();
}

class _StoreProfileState extends State<StoreProfile> {

  ShoppableStore get store => widget.store;
  bool get showProfileRightSide => widget.showProfileRightSide;
  Alignment get subscribeButtonAlignment => widget.subscribeButtonAlignment;
  bool get canAccessAsTeamMember => StoreServices.canAccessAsTeamMember(store);
  bool get teamMemberWantsToViewAsCustomer => store.teamMemberWantsToViewAsCustomer;
  bool get isTeamMemberWhoHasJoined => StoreServices.isTeamMemberWhoHasJoined(store);
  

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            //  Store Profile Left Side (Name, Description, e.t.c)
            Expanded(
              child: StoreProfileLeftSide(store: store)
            ),
              
            //  Spacer
            if(showProfileRightSide) const SizedBox(width: 8,),

            //  Store Profile Right Side (Adverts, Rating, e.t.c)
            if(showProfileRightSide) StoreProfileRightSide(store: store)

          ]
        ),

        /// Access Denied For Team Member
        if(isTeamMemberWhoHasJoined && !canAccessAsTeamMember && !teamMemberWantsToViewAsCustomer) ...[

          /// Subscribe Modal Bottom Sheet
          SubscribeToStoreModalBottomSheet(
            store: widget.store,
            subscribeButtonAlignment: subscribeButtonAlignment,
          )

        ],

      ],
    );
  }
}