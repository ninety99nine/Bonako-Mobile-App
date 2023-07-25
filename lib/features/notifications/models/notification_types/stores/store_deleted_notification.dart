class StoreDeletedNotification {
  late UserProperties userProperties;
  late StoreProperties storeProperties;

  StoreDeletedNotification.fromJson(Map<String, dynamic> json) {
    userProperties = UserProperties.fromJson(json['user']);
    storeProperties = StoreProperties.fromJson(json['store']);
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

class UserProperties {
  late int id;
  late String name;
  late String firstName;

  UserProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstName = json['firstName'];
  }
}