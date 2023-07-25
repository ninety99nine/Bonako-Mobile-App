import 'package:bonako_demo/core/shared_models/user_order_collection_association.dart';
import 'package:bonako_demo/features/addresses/models/delivery_address.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';

import '../../../core/shared_models/name_and_description.dart';
import '../../../../core/shared_models/mobile_number.dart';
import '../../../../core/shared_models/percentage.dart';
import '../../../../core/shared_models/currency.dart';
import '../../../../core/shared_models/status.dart';
import '../../../../core/shared_models/money.dart';
import '../../../../core/shared_models/link.dart';
import '../../../../core/shared_models/user.dart';
import '../../../../core/shared_models/cart.dart';
import '../../stores/models/shoppable_store.dart';

class Order {
  late int id;
  late Links links;
  late bool anonymous;
  late String summary;
  late String orderFor;
  late Money amountPaid;
  late Currency currency;
  late DateTime createdAt;
  late int? customerUserId;
  late Money amountPending;
  late int totalViewsByTeam;
  late Attributes attributes;
  late int? transactionsCount;
  late int orderForTotalUsers;
  late String? collectionType;
  late Money amountOutstanding;
  late int? collectionByUserId;
  late String customerLastName;
  late String? destinationName;
  late int orderForTotalFriends;
  late String customerFirstName;
  late NameAndDescription status;
  late Status collectionVerified;
  late Relationships relationships;
  late DateTime? lastViewedByTeamAt;
  late DateTime? firstViewedByTeamAt;
  late DateTime? collectionVerifiedAt;
  late int? collectionVerifiedByUserId;
  late Percentage amountPaidPercentage;
  late String? collectionByUserLastName;
  late NameAndDescription paymentStatus;
  late String? collectionByUserFirstName;
  late MobileNumber? customerMobileNumber;
  late Percentage amountPendingPercentage;
  late Percentage amountOutstandingPercentage;
  late String? collectionVerifiedByUserLastName;
  late String? collectionVerifiedByUserFirstName;

  Order.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    summary = json['summary'];
    orderFor = json['orderFor'];
    anonymous = json['anonymous'];
    links = Links.fromJson(json['links']);
    customerUserId = json['customerUserId'];
    collectionType = json['collectionType'];
    destinationName = json['destinationName'];
    totalViewsByTeam = json['totalViewsByTeam'];
    customerLastName = json['customerLastName'];
    transactionsCount = json['transactionsCount'];
    customerFirstName = json['customerFirstName'];
    createdAt = DateTime.parse(json['createdAt']);
    currency = Currency.fromJson(json['currency']);
    amountPaid = Money.fromJson(json['amountPaid']);
    collectionByUserId = json['collectionByUserId'];
    orderForTotalUsers = json['orderForTotalUsers'];
    orderForTotalFriends = json['orderForTotalFriends'];
    status = NameAndDescription.fromJson(json['status']);
    attributes = Attributes.fromJson(json['attributes']);
    amountPending = Money.fromJson(json['amountPending']);
    collectionByUserLastName = json['collectionByUserLastName'];
    collectionByUserFirstName = json['collectionByUserFirstName'];
    amountOutstanding = Money.fromJson(json['amountOutstanding']);
    collectionVerifiedByUserId = json['collectionVerifiedByUserId'];
    collectionVerified = Status.fromJson(json['collectionVerified']);
    paymentStatus = NameAndDescription.fromJson(json['paymentStatus']);
    amountPaidPercentage = Percentage.fromJson(json['amountPaidPercentage']);
    collectionVerifiedByUserLastName = json['collectionVerifiedByUserLastName'];
    collectionVerifiedByUserFirstName = json['collectionVerifiedByUserFirstName'];
    amountPendingPercentage = Percentage.fromJson(json['amountPendingPercentage']);
    amountOutstandingPercentage = Percentage.fromJson(json['amountOutstandingPercentage']);
    lastViewedByTeamAt = json['lastViewedByTeamAt'] == null ? null : DateTime.parse(json['lastViewedByTeamAt']);
    relationships = Relationships.fromJson(json['relationships'].runtimeType == List ? {} : json['relationships']);
    firstViewedByTeamAt = json['firstViewedByTeamAt'] == null ? null : DateTime.parse(json['firstViewedByTeamAt']);
    collectionVerifiedAt = json['collectionVerifiedAt'] == null ? null : DateTime.parse(json['collectionVerifiedAt']);
    customerMobileNumber = json['customerMobileNumber'] == null ? null : MobileNumber.fromJson(json['customerMobileNumber']);
  }
}

class Attributes {
  late String number;
  late bool isPaid;
  late bool isUnpaid;
  late bool isPartiallyPaid;
  late bool isPendingPayment;
  late bool isWaiting;
  late bool isOnItsWay;
  late bool isReadyForPickup;
  late bool isCancelled;
  late bool isCompleted;
  late String customerName;
  late String? collectionByUserName;
  late String? collectionVerifiedByUserName;
  late List<NameAndDescription> followUpStatuses;
  late UserOrderCollectionAssociation? userOrderCollectionAssociation;
  late DialToShowCollectionCode dialToShowCollectionCode;

  Attributes.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    isPaid = json['isPaid'];
    isUnpaid = json['isUnpaid'];
    isPartiallyPaid = json['isPartiallyPaid'];
    isPendingPayment = json['isPendingPayment'];
    isWaiting = json['isWaiting'];
    isOnItsWay = json['isOnItsWay'];
    isReadyForPickup = json['isReadyForPickup'];
    isCancelled = json['isCancelled'];
    isCompleted = json['isCompleted'];
    customerName = json['customerName'];
    collectionByUserName = json['collectionByUserName'];
    collectionVerifiedByUserName = json['collectionVerifiedByUserName'];
    followUpStatuses = List<NameAndDescription>.from(json['followUpStatuses'].map((followUpStatus) {
      return NameAndDescription.fromJson(followUpStatus);
    })).toList();
    dialToShowCollectionCode = DialToShowCollectionCode.fromJson(json['dialToShowCollectionCode']);
    userOrderCollectionAssociation = json['userOrderCollectionAssociation'] == null ? null : UserOrderCollectionAssociation.fromJson(json['userOrderCollectionAssociation']);
  }
}

class DialToShowCollectionCode {
  late String code;
  late String instruction;

  DialToShowCollectionCode.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    instruction = json['instruction'];
  }
}

class Relationships {
  late Cart? cart;
  late User? customer;
  late ShoppableStore? store;
  late List<Transaction>? transactions;
  late DeliveryAddress? deliveryAddress;

  Relationships.fromJson(Map<String, dynamic> json) {
    cart = json['cart'] == null ? null : Cart.fromJson(json['cart']);
    customer = json['customer'] == null ? null : User.fromJson(json['customer']);
    store = json['store'] == null ? null : ShoppableStore.fromJson(json['store']);
    deliveryAddress = json['deliveryAddress'] == null ? null : DeliveryAddress.fromJson(json['deliveryAddress']);
    transactions = json['transactions'] == null ? null : (json['transactions'] as List).map((transaction) => Transaction.fromJson(transaction)).toList();
  }
}

class Links {
  late Link self;
  late Link showViewers;
  late Link updateStatus;
  late Link requestPayment;
  late Link showTransactions;
  late Link revokeCollectionCode;
  late Link generateCollectionCode;
  late Link showTransactionFilters;

  Links.fromJson(Map<String, dynamic> json) {
    self = Link.fromJson(json['self']);
    showViewers = Link.fromJson(json['showViewers']);
    updateStatus = Link.fromJson(json['updateStatus']);
    requestPayment = Link.fromJson(json['requestPayment']);
    showTransactions = Link.fromJson(json['showTransactions']);
    revokeCollectionCode = Link.fromJson(json['revokeCollectionCode']);
    generateCollectionCode = Link.fromJson(json['generateCollectionCode']);
    showTransactionFilters = Link.fromJson(json['showTransactionFilters']);
  }
}