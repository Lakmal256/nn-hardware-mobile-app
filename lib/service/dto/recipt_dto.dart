import 'dart:convert';

import '../service.dart';

String receiptDtoToJson(List<ReceiptDto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReceiptDto {
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
  bool isAcceptedByHardwareOwner;
  AssignedHardwareOwner assignedHardwareOwner;
  dynamic region;
  List<Promotion> promotions;
  OmsUser omsUser;
  double promotionTotal;

  ReceiptDto({
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
    required this.isAcceptedByHardwareOwner,
    required this.assignedHardwareOwner,
    required this.region,
    required this.promotions,
    required this.promotionTotal,
    required this.omsUser,
  });

  factory ReceiptDto.fromJson(Map<String, dynamic> json) => ReceiptDto(
        lastModifiedDate: DateTime.parse(json["lastModifiedDate"]),
        createdDate: DateTime.parse(json["createdDate"]),
        id: json["id"],
        status: json["status"],
        omsUser: OmsUser.fromJson(json["omsUser"]),
        orderItems: List<OrderItem>.from(json["orderItems"].map((x) => OrderItem.fromJson(x))),
        itemTotal: json["itemTotal"],
        bundleProductTotal: json["bundleProductTotal"],
        generalPromotionTotal: json["generalPromotionTotal"],
        discountTotal: json["discountTotal"],
        limitedTimeOfferTotal: json["limitedTimeOfferTotal"],
        isFreeShippingEligible: json["isFreeShippingEligible"],
        totalPayment: json["totalPayment"]?.toDouble(),
        handlingCharge: HandlingCharge.fromJson(json["handlingCharge"]),
        deliveryCharge: json["deliveryCharge"]?.toDouble(),
        isAcceptedByHardwareOwner: json["isAcceptedByHardwareOwner"],
        assignedHardwareOwner: AssignedHardwareOwner.fromJson(json["assignedHardwareOwner"]),
        region: json["region"],
        promotions: List<Promotion>.from(json["promotions"].map((x) => Promotion.fromJson(x))),
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
        "isAcceptedByHardwareOwner": isAcceptedByHardwareOwner,
        "assignedHardwareOwner": assignedHardwareOwner.toJson(),
        "region": region,
        "promotions": List<dynamic>.from(promotions.map((x) => x.toJson())),
        "promotionTotal": promotionTotal,
      };
}
