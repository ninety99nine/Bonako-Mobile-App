class OrderUpdatedNotification {
  late StoreProperties storeProperties;
  late OrderProperties orderProperties;
  late CustomerProperties customerProperties;
  late OcassionProperties? ocassionProperties;
  late UpdatedByUserProperties updatedByUserProperties;

  OrderUpdatedNotification.fromJson(Map<String, dynamic> json) {
    storeProperties = StoreProperties.fromJson(json['store']);
    orderProperties = OrderProperties.fromJson(json['order']);
    customerProperties = CustomerProperties.fromJson(json['customer']);
    updatedByUserProperties = UpdatedByUserProperties.fromJson(json['updatedByUser']);
    ocassionProperties = json['occasion'] == null ? null : OcassionProperties.fromJson(json['occasion']);
  }
}

class StoreProperties {
  late int id;
  late String name;

  StoreProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class OrderProperties {
  late int id;
  late String number;
  late String summary;
  late int orderForTotalFriends;
  late bool isAssociatedAsFriend;
  late bool isAssociatedAsCustomer;

  OrderProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    summary = json['summary'];
    orderForTotalFriends = json['orderForTotalFriends'];
    isAssociatedAsFriend = json['isAssociatedAsFriend'];
    isAssociatedAsCustomer = json['isAssociatedAsCustomer'];
  }
}

class CustomerProperties {
  late int id;
  late String name;
  late String firstName;

  CustomerProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}

class UpdatedByUserProperties {
  late int id;
  late String name;
  late String firstName;

  UpdatedByUserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}

class OcassionProperties {
  late String name;

  OcassionProperties.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}