import 'package:bonako_demo/features/notifications/models/notification_types/orders/order_created_notification.dart';
import 'package:bonako_demo/features/notifications/models/notification.dart' as model;
import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class OrderCreatedNotificationContent extends StatelessWidget {

  final model.Notification notification;
  
  const OrderCreatedNotificationContent({
    super.key,
    required this.notification
  });

  DateTime get createdAt => notification.createdAt;
  String get orderNumber => orderProperties.number;
  int get otherTotalFriends => orderForTotalFriends - 1;
  String get customerName => orderProperties.customerProperties.name;
  bool get isAssociatedAsFriend => orderProperties.isAssociatedAsFriend;
  int get orderForTotalFriends => orderProperties.orderForTotalFriends;
  OrderProperties get orderProperties => orderCreatedNotification.orderProperties;
  OrderCreatedNotification get orderCreatedNotification => OrderCreatedNotification.fromJson(notification.data);

  TextStyle style(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      height: 1.4,
      color: color ?? Theme.of(context).primaryColor
    );
  }

  Widget notificationFooter(BuildContext context) {

    if(isAssociatedAsFriend) {

      //  Set the message indicating the user's part in the order
      String activityMessage = 'and tagged you';

      //  Add more details indicating other user's part in the order
      if(otherTotalFriends > 0) activityMessage += ' and $otherTotalFriends ${otherTotalFriends == 1 ? 'other friend' : 'other friends'}';

      //  Get a list of different occasions
      final List<String> occasions = [
        "🥳 Happy Birthday",
        "❤️ Happy Valentines",
        "👨‍🍼 Happy Fathers Day",
        "🎉 New Year's Eve Celebration",
        "🎓 Graduation Day",
        "🎂 Anniversary",
        "🌼 Mother's Day",
        "🎄 Christmas Celebration",
        "🥇 Achievement Celebration",
        "🎈 Surprise Party",
        "🏆 Sports Victory",
        "🎊 Engagement Party",
        "🌺 Wedding Day",
        "🌟 Promotion Celebration",
        "🍾 Housewarming Party",
        "🎁 Gift Exchange",
        "🍫 Valentine's Day Chocolate Exchange",
        "🐰 Easter Celebration",
        "🦃 Thanksgiving Feast",
        "🌸 Baby Shower",
        "🍁 Autumn Get-Together",
        "🌞 Summer Picnic",
        "🌟 New Job Celebration",
        "🏥 Get Well Soon",
      ];

      final String occasion = (occasions..shuffle()).first;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
    
          /// Activity Summary
          Expanded(
            child: RichText(
              text: TextSpan(
                /// Activity
                text: 'Ordered by ',
                style: style(context),
                children: [
                  TextSpan(
                    /// User Name
                    text: customerName,
                    style: style(context),
                  ),
                  TextSpan(
                    /// Activity
                    text: ' $activityMessage ',
                    style: style(context, color: Colors.grey),
                  ),
                  TextSpan(
                    /// Occasion
                    text: occasion,
                    style: style(context, color: Colors.grey),
                  )
                ]
              ),
            ),
          ),

          /// Spacer
          const SizedBox(width: 8,),

          /// Order Number
          CustomBodyText('#$orderNumber', lightShade: true,),

        ],
      );

    }else{

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
    
          /// Activity Summary
          Expanded(
            child: RichText(
              text: TextSpan(
                /// User Name
                text: customerName,
                style: style(context),
                children: [
                  TextSpan(
                    /// Activity
                    text: ' placed an order',
                    style: style(context, color: Colors.grey),
                  )
                ]
              ),
            ),
          ),

          /// Spacer
          const SizedBox(width: 8,),

          /// Order Number
          CustomBodyText('#$orderNumber', lightShade: true,),

        ],
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// Store Name
              CustomTitleSmallText(orderCreatedNotification.storeProperties.name),
              
              /// Notificaiton Date And Time Ago
              CustomBodyText(timeago.format(createdAt, locale: 'en_short')),

            ],
          ),

          /// Spacer
          const SizedBox(height: 4),
          
          /// Notification Content
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              /// Order Summary
              Expanded(
                child: CustomBodyText(orderCreatedNotification.orderProperties.summary)
              ),
          
              /// Spacer
              const SizedBox(width: 8),
          
              /// Icon
              const Icon(Icons.shopping_bag_outlined, size: 16,),
    
            ],
          ),
          
          /// Spacer
          const SizedBox(height: 4),

          /// Notification Footer
          notificationFooter(context)

        ],
      ),
    );
  }
}