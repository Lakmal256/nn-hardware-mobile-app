import 'dart:convert';

class TokenResponse {
  String? token;
  String? refreshToken;
  String? identityId;
  UserResponseDto? user;

  TokenResponse.fromJson(Map<String, dynamic> value)
      : identityId = value["loggedUser"]["identityId"],
        token = value["accessToken"],
        user = UserResponseDto.fromJson(value["loggedUser"]),
        refreshToken = value["refreshToken"];
}

class UserResponseDto {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  bool? internal;
  bool? status;
  String? expiryDate;
  String? defaultLanguage;
  String? lastModifiedDate;
  String? sapEmployeeCode;
  String? geoLocation;
  String? profileImageUrl;
  String? profileImage;

  UserResponseDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        internal = value["internal"],
        status = value["status"],
        expiryDate = value["expiryDate"],
        defaultLanguage = value["defaultLanguage"],
        lastModifiedDate = value["lastModifiedDate"],
        sapEmployeeCode = value["sapEmployeeCode"],
        geoLocation = value["geoLocation"],
        profileImage = value["profileImage"],
        // profileImageUrl = value["profileImageUrl"] ??
        profileImageUrl = value["displayProfileImageUrl"] ??

            /// Service currently not supporting any default image
            /// this is a public image service that provides a name based
            /// profile image
            "https://ui-avatars.com/api/?background=random&name=${value["firstName"]}+${value["lastName"]}";

  String get displayName => "$firstName $lastName".replaceAll(RegExp('\\s+'), ' ');
}

class UserDto {
  int? id;
  String? identityId;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  bool? internal;
  String? status;
  String? expiryDate;
  String? defaultLanguage;
  String? lastModifiedDate;
  String? sapEmployeeCode;

  UserDto.fromJson(Map<String, dynamic> value)
      : id = value["id"],
        identityId = value["identityId"],
        firstName = value["firstName"],
        lastName = value["lastName"],
        email = value["email"],
        mobileNo = value["mobileNo"],
        internal = value["internal"],
        status = value["status"],
        expiryDate = value["expiryDate"],
        defaultLanguage = value["defaultLanguage"],
        lastModifiedDate = value["lastModifiedDate"],
        sapEmployeeCode = value["sapEmployeeCode"];
}

class VendorDto {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int? id;
  String name;
  String contactNumber;
  String identityId;
  String location;
  dynamic currentLatitude;
  dynamic currentLongitude;
  String status;

  VendorDto.fromJson(Map<String, dynamic> value)
      : lastModifiedDate = DateTime.parse(value['lastModifiedDate']),
        createdDate = DateTime.parse(value['createdDate']),
        id = value['id'],
        name = value['name'],
        contactNumber = value['contactNumber'],
        identityId = value['identityId'],
        location = value['location'],
        currentLatitude = value['currentLatitude'],
        currentLongitude = value['currentLongitude'],
        status = value['status'];

  VendorDto copyWith({
    DateTime? lastModifiedDate,
    DateTime? createdDate,
    int? id,
    String? name,
    String? contactNumber,
    String? identityId,
    String? location,
    dynamic currentLatitude,
    dynamic currentLongitude,
    String? status,
  }) {
    return VendorDto.fromJson({
      'lastModifiedDate': lastModifiedDate?.toIso8601String() ?? this.lastModifiedDate.toIso8601String(),
      'createdDate': createdDate?.toIso8601String() ?? this.createdDate.toIso8601String(),
      'id': id ?? this.id,
      'name': name ?? this.name,
      'contactNumber': contactNumber ?? this.contactNumber,
      'identityId': identityId ?? this.identityId,
      'location': location ?? this.location,
      'currentLatitude': currentLatitude ?? this.currentLatitude,
      'currentLongitude': currentLongitude ?? this.currentLongitude,
      'status': status ?? this.status,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'lastModifiedDate': lastModifiedDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'id': id,
      'name': name,
      'contactNumber': contactNumber,
      'identityId': identityId,
      'location': location,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'status': status,
    };
  }
}

// recived order dto

List<OrderDto> orderDtoFromJson(String str) => List<OrderDto>.from(json.decode(str).map((x) => OrderDto.fromJson(x)));

String orderDtoToJson(List<OrderDto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderDto {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String status;
  List<OrderItem> orderItems;
  double itemTotal;
  double bundleProductTotal;
  double generalPromotionTotal;
  double discountTotal;
  double limitedTimeOfferTotal;
  bool isFreeShippingEligible;
  double totalPayment;
  HandlingCharge handlingCharge;
  double deliveryCharge;
  double handlingChargeAmount;
  bool isAcceptedByHardwareOwner;
  AssignedHardwareOwner assignedHardwareOwner;
  dynamic region;
  dynamic orderedRegion;
  dynamic currentAddress;
  List<dynamic> promotions;
  OmsUser omsUser;
  double promotionTotal;

  OrderDto({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.status,
    required this.orderItems,
    required this.itemTotal,
    required this.bundleProductTotal,
    required this.generalPromotionTotal,
    required this.discountTotal,
    required this.limitedTimeOfferTotal,
    required this.isFreeShippingEligible,
    required this.totalPayment,
    required this.handlingCharge,
    required this.deliveryCharge,
    required this.handlingChargeAmount,
    required this.isAcceptedByHardwareOwner,
    required this.assignedHardwareOwner,
    required this.region,
    required this.orderedRegion,
    required this.currentAddress,
    required this.promotions,
    required this.omsUser,
    required this.promotionTotal,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) => OrderDto(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        status: json["status"],
        orderItems: List<OrderItem>.from(json["orderItems"].map((x) => OrderItem.fromJson(x))),
        itemTotal: json["itemTotal"],
        bundleProductTotal: json["bundleProductTotal"],
        generalPromotionTotal: json["generalPromotionTotal"],
        discountTotal: json["discountTotal"],
        limitedTimeOfferTotal: json["limitedTimeOfferTotal"],
        isFreeShippingEligible: json["isFreeShippingEligible"],
        totalPayment: json["totalPayment"],
        handlingCharge: HandlingCharge.fromJson(json["handlingCharge"]),
        deliveryCharge: json["deliveryCharge"],
        handlingChargeAmount: json["handlingChargeAmount"],
        isAcceptedByHardwareOwner: json["isAcceptedByHardwareOwner"],
        assignedHardwareOwner: AssignedHardwareOwner.fromJson(json["assignedHardwareOwner"]),
        region: json["region"],
        orderedRegion: json["orderedRegion"],
        currentAddress: json["currentAddress"] ?? "N/A",
        promotions: List<dynamic>.from(json["promotions"].map((x) => x)),
        omsUser: OmsUser.fromJson(json["omsUser"]),
        promotionTotal: json["promotionTotal"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "status": status,
        "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        "itemTotal": itemTotal,
        "bundleProductTotal": bundleProductTotal,
        "generalPromotionTotal": generalPromotionTotal,
        "discountTotal": discountTotal,
        "limitedTimeOfferTotal": limitedTimeOfferTotal,
        "isFreeShippingEligible": isFreeShippingEligible,
        "totalPayment": totalPayment,
        "handlingCharge": handlingCharge.toJson(),
        "deliveryCharge": deliveryCharge,
        "handlingChargeAmount": handlingChargeAmount,
        "isAcceptedByHardwareOwner": isAcceptedByHardwareOwner,
        "assignedHardwareOwner": assignedHardwareOwner.toJson(),
        "region": region,
        "orderedRegion": orderedRegion,
        "currentAddress": currentAddress,
        "promotions": List<dynamic>.from(promotions.map((x) => x)),
        "omsUser": omsUser.toJson(),
        "promotionTotal": promotionTotal,
      };
}

class AssignedHardwareOwner {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String name;
  String contactNumber;
  String identityId;
  String location;
  double? currentLatitude;
  double? currentLongitude;
  String status;
  dynamic delRate0To5;
  dynamic delRate5To10;
  dynamic delRate10To15;
  dynamic delRate15To20;
  dynamic delRate20To25;
  dynamic delRate25To30;
  dynamic delRate30To35;
  dynamic delRate35To40;
  dynamic delRate40To45;
  dynamic delRate45To50;
  dynamic distanceWithCustomer;

  AssignedHardwareOwner({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.identityId,
    required this.location,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.status,
    required this.delRate0To5,
    required this.delRate5To10,
    required this.delRate10To15,
    required this.delRate15To20,
    required this.delRate20To25,
    required this.delRate25To30,
    required this.delRate30To35,
    required this.delRate35To40,
    required this.delRate40To45,
    required this.delRate45To50,
    required this.distanceWithCustomer,
  });

  factory AssignedHardwareOwner.fromJson(Map<String, dynamic> json) => AssignedHardwareOwner(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        name: json["name"] ?? '',
        contactNumber: json["contactNumber"] ?? '',
        identityId: json["identityId"] ?? '',
        location: json["location"] ?? '',
        currentLatitude: json["currentLatitude"]?.toDouble(),
        currentLongitude: json["currentLongitude"]?.toDouble(),
        status: json["status"] ?? '',
        delRate0To5: json["delRate0To5"],
        delRate5To10: json["delRate5To10"],
        delRate10To15: json["delRate10To15"],
        delRate15To20: json["delRate15To20"],
        delRate20To25: json["delRate20To25"],
        delRate25To30: json["delRate25To30"],
        delRate30To35: json["delRate30To35"],
        delRate35To40: json["delRate35To40"],
        delRate40To45: json["delRate40To45"],
        delRate45To50: json["delRate45To50"],
        distanceWithCustomer: json["distanceWithCustomer"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "name": name,
        "contactNumber": contactNumber,
        "identityId": identityId,
        "location": location,
        "currentLatitude": currentLatitude,
        "currentLongitude": currentLongitude,
        "status": status,
        "delRate0To5": delRate0To5,
        "delRate5To10": delRate5To10,
        "delRate10To15": delRate10To15,
        "delRate15To20": delRate15To20,
        "delRate20To25": delRate20To25,
        "delRate25To30": delRate25To30,
        "delRate30To35": delRate30To35,
        "delRate35To40": delRate35To40,
        "delRate40To45": delRate40To45,
        "delRate45To50": delRate45To50,
        "distanceWithCustomer": distanceWithCustomer,
      };
}

class HandlingCharge {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  double price;

  HandlingCharge({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.price,
  });

  factory HandlingCharge.fromJson(Map<String, dynamic> json) => HandlingCharge(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "price": price,
      };
}

class OmsUser {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String identityId;
  String firstName;
  String lastName;
  String email;
  String mobileNo;
  dynamic password;
  bool internal;
  dynamic roles;
  bool status;
  dynamic expiryDate;
  DateTime? lastLoginTimeStamp;
  DateTime? dataModifyTimeStamp;
  String defaultLanguage;
  dynamic socialLoginType;
  String geoLocation;
  dynamic deviceToken;
  String profileImage;
  dynamic profileImageUrl;
  dynamic currentLatitude;
  dynamic currentLongitude;
  String referralCode;
  dynamic referralLink;
  int referralCount;
  bool socialLogin;

  OmsUser({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.identityId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.password,
    required this.internal,
    required this.roles,
    required this.status,
    required this.expiryDate,
    required this.lastLoginTimeStamp,
    required this.dataModifyTimeStamp,
    required this.defaultLanguage,
    required this.socialLoginType,
    required this.geoLocation,
    required this.deviceToken,
    required this.profileImage,
    required this.profileImageUrl,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.referralCode,
    required this.referralLink,
    required this.referralCount,
    required this.socialLogin,
  });

  factory OmsUser.fromJson(Map<String, dynamic> json) => OmsUser(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        identityId: json["identityId"] ?? '',
        firstName: json["firstName"] ?? '',
        lastName: json["lastName"] ?? '',
        email: json["email"] ?? '',
        mobileNo: json["mobileNo"] ?? '',
        password: json["password"] ?? '',
        internal: json["internal"] ?? '',
        roles: json["roles"],
        status: json["status"],
        expiryDate: json["expiryDate"],
        lastLoginTimeStamp: DateTime.tryParse(json["lastLoginTimeStamp"] ?? ''),
        dataModifyTimeStamp: DateTime.tryParse(json["dataModifyTimeStamp"] ?? ''),
        defaultLanguage: json["defaultLanguage"],
        socialLoginType: json["socialLoginType"],
        geoLocation: json["geoLocation"] ?? '',
        deviceToken: json["deviceToken"],
        profileImage: json["profileImage"] ?? '',
        // profileImageUrl: json["profileImageUrl"] ?? '',
        profileImageUrl: json["displayProfileImageUrl"] ?? '',
        currentLatitude: json["currentLatitude"],
        currentLongitude: json["currentLongitude"],
        referralCode: json["referralCode"],
        referralLink: json["referralLink"],
        referralCount: json["referralCount"],
        socialLogin: json["socialLogin"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "identityId": identityId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "mobileNo": mobileNo,
        "password": password,
        "internal": internal,
        "roles": roles,
        "status": status,
        "expiryDate": expiryDate,
        "lastLoginTimeStamp":lastLoginTimeStamp?.toIso8601String(),
        "dataModifyTimeStamp":dataModifyTimeStamp?.toIso8601String(),
        "defaultLanguage": defaultLanguage,
        "socialLoginType": socialLoginType,
        "geoLocation": geoLocation,
        "deviceToken": deviceToken,
        "profileImage": profileImage,
        "profileImageUrl": profileImageUrl,
        "currentLatitude": currentLatitude,
        "currentLongitude": currentLongitude,
        "referralCode": referralCode,
        "referralLink": referralLink,
        "referralCount": referralCount,
        "socialLogin": socialLogin,
      };

  String get displayName => '$firstName $lastName';
}

class OrderItem {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  int quantity;
  double regionPrice;
  dynamic address;
  Product product;
  double flashSaleAmount;
  int freeQuantity;

  OrderItem({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.quantity,
    required this.regionPrice,
    required this.address,
    required this.product,
    required this.flashSaleAmount,
    required this.freeQuantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        quantity: json["quantity"],
        regionPrice: json["regionPrice"] ?? 0,
        address: json["address"] ?? '',
        product: Product.fromJson(json["product"]),
        flashSaleAmount: json["flashSaleAmount"],
        freeQuantity: json["freeQuantity"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "quantity": quantity,
        "regionPrice": regionPrice,
        "address": address,
        "product": product.toJson(),
        "flashSaleAmount": flashSaleAmount,
        "freeQuantity": freeQuantity,
      };
}

class Product {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String name;
  ProductCategory? productCategory;
  ProductSubCategory productSubCategory;
  double price;
  dynamic description;
  String productDescription;
  List<dynamic> regionalPrices;
  dynamic detailsFile;
  String webImage;
  String mobileImage;
  String status;
  dynamic factFile;
  dynamic properties;
  dynamic compatibility;
  dynamic applications;
  dynamic fixedValue;

  Product({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.name,
    required this.productCategory,
    required this.productSubCategory,
    required this.price,
    required this.description,
    required this.productDescription,
    required this.regionalPrices,
    required this.detailsFile,
    required this.webImage,
    required this.mobileImage,
    required this.status,
    required this.factFile,
    required this.properties,
    required this.compatibility,
    required this.applications,
    required this.fixedValue,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        name: json["name"],
        productCategory: json["productCategory"] == null ? null : ProductCategory.fromJson(json["productCategory"]),
        productSubCategory: ProductSubCategory.fromJson(json["productSubCategory"]),
        price: json["price"],
        description: json["description"],
        productDescription: json["productDescription"],
        regionalPrices: List<dynamic>.from(json["regionalPrices"].map((x) => x)),
        detailsFile: json["detailsFile"],
        webImage: json["webImage"],
        // mobileImage: json["mobileImage"],
        mobileImage: json["displayMobileImageUrl"] ?? '',
        status: json["status"],
        factFile: json["factFile"],
        properties: json["properties"],
        compatibility: json["compatibility"],
        applications: json["applications"],
        fixedValue: json["fixedValue"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "name": name,
        "productCategory": productCategory!.toJson(),
        "productSubCategory": productSubCategory.toJson(),
        "price": price,
        "description": description,
        "productDescription": productDescription,
        "regionalPrices": List<dynamic>.from(regionalPrices.map((x) => x)),
        "detailsFile": detailsFile,
        "webImage": webImage,
        "mobileImage": mobileImage,
        "status": status,
        "factFile": factFile,
        "properties": properties,
        "compatibility": compatibility,
        "applications": applications,
        "fixedValue": fixedValue,
      };
}

class ProductCategory {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String name;
  String imageUrl;
  List<dynamic> assignees;

  ProductCategory({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.assignees,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        name: json["name"],
        // imageUrl: json["imageUrl"] ?? '',
        imageUrl: json["displayImageUrl"] ?? '',
        assignees: List<dynamic>.from(json["assignees"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "name": name,
        "imageUrl": imageUrl,
        "assignees": List<dynamic>.from(assignees.map((x) => x)),
      };
}

class ProductSubCategory {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String name;
  ProductCategory productCategory;

  ProductSubCategory({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.name,
    required this.productCategory,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) => ProductSubCategory(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        name: json["name"],
        productCategory: ProductCategory.fromJson(json["productCategory"]),
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "name": name,
        "productCategory": productCategory.toJson(),
      };
}

class Assignee {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String identityId;
  String firstName;
  String lastName;
  String email;
  String mobileNo;
  dynamic password;
  bool internal;
  dynamic roles;
  bool status;
  dynamic expiryDate;
  DateTime? lastLoginTimeStamp;
  DateTime? dataModifyTimeStamp;
  String defaultLanguage;
  dynamic socialLoginType;
  String geoLocation;
  dynamic deviceToken;
  String profileImage;
  dynamic profileImageUrl;
  dynamic currentLatitude;
  dynamic currentLongitude;
  dynamic referralCode;
  dynamic referralLink;
  dynamic referralDiscount;
  bool socialLogin;

  Assignee({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.identityId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.password,
    required this.internal,
    required this.roles,
    required this.status,
    required this.expiryDate,
    required this.lastLoginTimeStamp,
    required this.dataModifyTimeStamp,
    required this.defaultLanguage,
    required this.socialLoginType,
    required this.geoLocation,
    required this.deviceToken,
    required this.profileImage,
    required this.profileImageUrl,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.referralCode,
    required this.referralLink,
    required this.referralDiscount,
    required this.socialLogin,
  });

  factory Assignee.fromJson(Map<String, dynamic> json) => Assignee(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        identityId: json["identityId"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        mobileNo: json["mobileNo"],
        password: json["password"],
        internal: json["internal"],
        roles: json["roles"],
        status: json["status"],
        expiryDate: json["expiryDate"],
        lastLoginTimeStamp: DateTime.tryParse(json["lastLoginTimeStamp"]),
        dataModifyTimeStamp: DateTime.tryParse(json["dataModifyTimeStamp"]),
        defaultLanguage: json["defaultLanguage"],
        socialLoginType: json["socialLoginType"],
        geoLocation: json["geoLocation"],
        deviceToken: json["deviceToken"],
        profileImage: json["profileImage"],
        // profileImageUrl: json["profileImageUrl"],
        profileImageUrl: json["displayProfileImageUrl"],
        currentLatitude: json["currentLatitude"],
        currentLongitude: json["currentLongitude"],
        referralCode: json["referralCode"],
        referralLink: json["referralLink"],
        referralDiscount: json["referralDiscount"],
        socialLogin: json["socialLogin"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "identityId": identityId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "mobileNo": mobileNo,
        "password": password,
        "internal": internal,
        "roles": roles,
        "status": status,
        "expiryDate": expiryDate,
        "lastLoginTimeStamp": lastLoginTimeStamp?.toIso8601String(),
        "dataModifyTimeStamp": dataModifyTimeStamp?.toIso8601String(),
        "defaultLanguage": defaultLanguage,
        "socialLoginType": socialLoginType,
        "geoLocation": geoLocation,
        "deviceToken": deviceToken,
        "profileImage": profileImage,
        "profileImageUrl": profileImageUrl,
        "currentLatitude": currentLatitude,
        "currentLongitude": currentLongitude,
        "referralCode": referralCode,
        "referralLink": referralLink,
        "referralDiscount": referralDiscount,
        "socialLogin": socialLogin,
      };
}

class Promotion {
  DateTime lastModifiedDate;
  DateTime createdDate;
  int id;
  String mainType;
  dynamic type;
  dynamic discountType;
  dynamic title;
  dynamic promoCode;
  double threshold;
  dynamic percentageValue;
  dynamic period;
  dynamic discountAmount;
  DateTime? startDate;
  DateTime? expiryDate;
  String status;
  List<dynamic> products;

  Promotion({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.id,
    required this.mainType,
    required this.type,
    required this.discountType,
    required this.title,
    required this.promoCode,
    required this.threshold,
    required this.percentageValue,
    required this.period,
    required this.discountAmount,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.products,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        mainType: json["mainType"],
        type: json["type"],
        discountType: json["discountType"],
        title: json["title"],
        promoCode: json["promoCode"],
        threshold: json["threshold"] ?? 0,
        percentageValue: json["percentageValue"],
        period: json["period"],
        discountAmount: json["discountAmount"],
        startDate: DateTime.tryParse(json["startDate"]),
        expiryDate: DateTime.tryParse(json["expiryDate"]),
        status: json["status"],
        products: List<dynamic>.from(json["products"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
        "createdDate": createdDate.toIso8601String(),
        "id": id,
        "mainType": mainType,
        "type": type,
        "discountType": discountType,
        "title": title,
        "promoCode": promoCode,
        "threshold": threshold,
        "percentageValue": percentageValue,
        "period": period,
        "discountAmount": discountAmount,
        "startDate": startDate?.toIso8601String(),
        "expiryDate": expiryDate?.toIso8601String(),
        "status": status,
        "products": List<dynamic>.from(products.map((x) => x)),
      };
}

ResutlDto resutlDtoFromJson(String str) => ResutlDto.fromJson(json.decode(str));

String resutlDtoToJson(ResutlDto data) => json.encode(data.toJson());

class ResutlDto {
  String result;

  ResutlDto({
    required this.result,
  });

  factory ResutlDto.fromJson(Map<String, dynamic> json) => ResutlDto(
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
      };
}

ProductDto productDtoFromJson(String str) => ProductDto.fromJson(json.decode(str));

String productDtoToJson(ProductDto data) => json.encode(data.toJson());

class ProductDto {
  dynamic totalRecords;
  dynamic currentPage;
  dynamic pageSize;
  List<ProductItemDto> productList;

  ProductDto({
    required this.totalRecords,
    required this.currentPage,
    required this.pageSize,
    required this.productList,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        totalRecords: json["totalRecords"],
        currentPage: json["currentPage"],
        pageSize: json["pageSize"],
        productList: List<ProductItemDto>.from(json["productList"].map((x) => ProductItemDto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalRecords": totalRecords,
        "currentPage": currentPage,
        "pageSize": pageSize,
        "productList": List<dynamic>.from(productList.map((x) => x.toJson())),
      };
}

/// Using in reports
class ProductItemDto {
  int id;
  String name;
  ProductSubCategory productSubCategory;
  ProductCategory productCategory;
  double price;
  List<RegionalPrice> regionalPrices;
  String productDescription;
  String description;
  String detailsFile;
  String webImage;
  String mobileImage;
  String status;
  String factFile;
  String properties;
  String compatibility;
  String applications;
  dynamic fixedValue;
  DateTime createdDate;
  DateTime lastModifiedDate;

  ProductItemDto({
    required this.id,
    required this.name,
    required this.productSubCategory,
    required this.productCategory,
    required this.price,
    required this.regionalPrices,
    required this.productDescription,
    required this.description,
    required this.detailsFile,
    required this.webImage,
    required this.mobileImage,
    required this.status,
    required this.factFile,
    required this.properties,
    required this.compatibility,
    required this.applications,
    required this.fixedValue,
    required this.createdDate,
    required this.lastModifiedDate,
  });

  factory ProductItemDto.fromJson(Map<String, dynamic> json) => ProductItemDto(
        id: json["id"],
        name: json["name"],
        productSubCategory: ProductSubCategory.fromJson(json["productSubCategory"]),
        productCategory: ProductCategory.fromJson(json["productCategory"]),
        price: json["price"],
        regionalPrices: json["regionalPrices"] == null
            ? []
            : List<RegionalPrice>.from(json["regionalPrices"].map((x) => RegionalPrice.fromJson(x))),
        productDescription: json["productDescription"] ?? '',
        description: json["description"] ?? '',
        detailsFile: json["detailsFile"] ?? '',
        webImage: json["webImage"],
        // mobileImage: json["mobileImage"],
        mobileImage: json["displayMobileImageUrl"] ?? '',
        status: json["status"],
        factFile: json["factFile"] ?? '',
        properties: json["properties"] ?? '',
        compatibility: json["compatibility"] ?? '',
        applications: json["applications"] ?? '',
        fixedValue: json["fixedValue"],
        createdDate: DateTime.parse(json["createdDate"]),
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "productSubCategory": productSubCategory.toJson(),
        "productCategory": productCategory.toJson(),
        "price": price,
        "regionalPrices": List<dynamic>.from(regionalPrices.map((x) => x.toJson())),
        "productDescription": productDescription,
        "description": description,
        "detailsFile": detailsFile,
        "webImage": webImage,
        "mobileImage": mobileImage,
        "status": status,
        "factFile": factFile,
        "properties": properties,
        "compatibility": compatibility,
        "applications": applications,
        "fixedValue": fixedValue,
        "createdDate": createdDate.toIso8601String(),
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
      };
}

class RegionalPrice {
  dynamic lastModifiedDate;
  dynamic createdDate;
  String region;
  double price;

  RegionalPrice({
    required this.lastModifiedDate,
    required this.createdDate,
    required this.region,
    required this.price,
  });

  factory RegionalPrice.fromJson(Map<String, dynamic> json) => RegionalPrice(
        lastModifiedDate: json["lastModifiedDate"],
        createdDate: json["createdDate"],
        region: json["region"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "lastModifiedDate": lastModifiedDate,
        "createdDate": createdDate,
        "region": region,
        "price": price,
      };
}

List<PromotionDto> promotionDtoFromJson(String str) =>
    List<PromotionDto>.from(json.decode(str).map((x) => PromotionDto.fromJson(x)));

String promotionDtoToJson(List<PromotionDto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PromotionDto {
  int id;
  String mainPromotionType;
  String type;
  String discountType;
  String title;
  String promoCode;
  double threshold;
  double percentageValue;
  String period;
  List<Product> products;
  DateTime? startDate;
  DateTime? expiryDate;
  double discountAmount;
  String status;
  DateTime createdDate;
  DateTime lastModifiedDate;

  PromotionDto({
    required this.id,
    required this.mainPromotionType,
    required this.type,
    required this.discountType,
    required this.title,
    required this.promoCode,
    required this.threshold,
    required this.percentageValue,
    required this.period,
    required this.products,
    required this.startDate,
    required this.expiryDate,
    required this.discountAmount,
    required this.status,
    required this.createdDate,
    required this.lastModifiedDate,
  });

  factory PromotionDto.fromJson(Map<String, dynamic> json) => PromotionDto(
        id: json["id"],
        mainPromotionType: json["mainPromotionType"],
        type: json["type"] ?? '',
        discountType: json["discountType"] ?? '',
        title: json["title"] ?? '',
        promoCode: json["promoCode"] ?? '',
        threshold: json["threshold"] ?? 0,
        percentageValue: json["percentageValue"] ?? 0,
        period: json["period"] ?? '',
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
        startDate: DateTime.tryParse(json["startDate"] ?? ''),
        expiryDate: DateTime.tryParse(json["expiryDate"] ?? ''),
        discountAmount: json["discountAmount"] ?? 0,
        status: json["status"],
        createdDate: DateTime.parse(json["createdDate"]),
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mainPromotionType": mainPromotionType,
        "type": type,
        "discountType": discountType,
        "title": title,
        "promoCode": promoCode,
        "threshold": threshold,
        "percentageValue": percentageValue,
        "period": period,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "startDate": startDate!.toIso8601String(),
        "expiryDate": expiryDate!.toIso8601String(),
        "discountAmount": discountAmount,
        "status": status,
        "createdDate": createdDate.toIso8601String(),
        "lastModifiedDate": lastModifiedDate.toIso8601String(),
      };
}

class NotificationDto {
  int id;
  String? status;
  String? topic;
  String? title;
  String? body;
  bool read;

  NotificationDto.fromJson(Map<String, dynamic> value)
      : id = 0,
        status = value["main"],
        topic = value["topic"],
        title = value["title"],
        body = value["body"],
        read = value["read"];
}
