import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:insee_hardware/locator.dart';
import 'package:insee_hardware/service/service.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../ui/ui.dart';

class UserNotFoundException implements Exception {}

class UnauthorizedException implements Exception {}

class BlockedUserException implements Exception {}

class ConflictedUserException implements Exception {}

class PendingApprovalException implements Exception {
  final String message;

  PendingApprovalException(this.message);
}

enum OtpMethod { email, mobile }

class RestServiceConfig {
  RestServiceConfig({
    required this.authority,
    String? pathPrefix,
  }) : pathPrefix = pathPrefix ?? '';

  final String authority;

  final String? pathPrefix;
}

class RestService {
  RestService({required this.config, required this.authService});

  RestServiceConfig config;

  AuthService authService;

  Future<bool> applyRegistration({
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNo,
    String? geoLocation,
    String? language,
    bool socialUser = false,
    String? socialLogin = "",
    String? socialToken,
  }) async {
    final body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobileNo": mobileNo,
      "geoLocation": geoLocation,
      "language": language,
      "socialUser": socialUser,
      "socialLogin": socialLogin,
    });

    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/external/register/apply"),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    } else if (response.statusCode == HttpStatus.conflict) {
      throw ConflictedUserException();
    }

    throw Exception();
  }

  /// Check if user already exist or not
  Future<bool> checkUserRegistrationStatus(String mobile) async {
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/mobile/$mobile/exists"),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return decodedJson;
    }
    return false;
  }

  Future<bool> sendOtp(OtpMethod method, String value, {String type = "rp"}) async {
    switch (method) {
      case OtpMethod.email:
        {
          String email0 = value.toLowerCase();
          final response = await http.post(
            Uri.https(config.authority, "${config.pathPrefix}/utility/sendotp/$email0/$type"),
          );
          return response.statusCode == HttpStatus.accepted;
        }
      case OtpMethod.mobile:
        {
          final response = await http.post(
            Uri.https(config.authority, "${config.pathPrefix}/utility/login/sendotp/$value"),
          );
          return response.statusCode == HttpStatus.accepted;
        }
    }
  }

  Future<String> verifyOtp(String mobile, String otp) async {
    String mobile0 = mobile;
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/utility/login/verifyotp/$mobile0/$otp"),
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      var result = decodedJson["result"];
      return result ?? (throw Exception());
    }

    throw Exception();
  }

  Future<TokenResponse?> loginWithAuthorizationCode({required String authorizationCode}) async {
    final response = await http.post(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/otp/login/$authorizationCode"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return TokenResponse.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<bool> updateDeviceToken(String token) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/device-token/$token"),
      headers: {
        'Content-Type': 'application/json',
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<UserDto?> getUserByMobile(String value) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/mobile/$value"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<UserResponseDto?> getUserByIamId(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/iam/$id"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<UserResponseDto?> getUserById(int id) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/identity/user/$id"),
      headers: {
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return UserResponseDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  /// Vendor

  /// get Vendor ByUserIAmId
  Future<VendorDto?> getVendor() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/hardware/owner"),
      headers: {
        'Content-Type': ContentType.json.mimeType,
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );
    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(response.body);
      return VendorDto.fromJson(decodedJson);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  /// get Vendor ByUserIAmId
  Future<ResutlDto?> putVendor({
    required String mobileNumber,
    required String location,
    required String name,
    required String id,
  }) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/hardware/owners"),
      headers: {
        "Content-Type": "application/json",
        'Authorization': authData.bearerToken,
      },
      body: json.encode({
        "id": id,
        "name": name,
        'location': location,
        'contactNumber': mobileNumber,
        "identityId": authData.identityId,
      }),
    );

    if (response.statusCode == HttpStatus.accepted) {
      return resutlDtoFromJson(response.body);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    } else {
      throw Exception("Unexpected response status code: ${response.statusCode}");
    }
  }

  // get assigned orders for a hardware owner
  Future<List<OrderDto>> getReceivedOrders() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/hardware/owner/orders"),
      headers: {
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      List<OrderDto> orderDto = orderDtoFromJson(response.body);
      orderDto.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      locate<OrdersRepo>().setValue(orderDto);
      return orderDto;
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  // get assigned orders for a hardware owner
  Future<List<ReceiptDto>> getReports({
    required String fromDate,
    required String toDate,
    required int material,
    required int promotion,
    required bool isDaily,
  }) async {
    final authData = await authService.getData();
    String formattedTime = DateFormat('HH:mm:00').format(DateTime.now());
    final response = await http.get(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/hardware/owner/filter-sales",
        {
          'fromDate': '${fromDate}T00:00:00',
          'toDate': '${toDate}T$formattedTime',
          'promotion': promotion.toString(),
          'material': material.toString(),
          'isDaily': isDaily.toString(),
        },
      ),
      headers: {
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return List<ReceiptDto>.from(
        json.decode(response.body).map((v0) => ReceiptDto.fromJson(v0)),
      );
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  Future<Uri?> generateSalesReportUrl({
    required String fromDate,
    required String toDate,
    required String material,
    required String promotion,
    required bool isDaily,
  }) async {
    final authData = await authService.getData();
    String formattedTime = DateFormat('HH:mm:00').format(DateTime.now());
    final response = await http.get(
      Uri.https(
        config.authority,
        "${config.pathPrefix}/hardware/owner/filter-sales/export",
        {
          'fromDate': '${fromDate}T00:00:00',
          'toDate': '${toDate}T$formattedTime',
          'promotion': promotion.toString(),
          'material': material.toString(),
          'isDaily': isDaily.toString(),
        },
      ),
      headers: {
        "user-iam-id": authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final url = Uri.tryParse(response.body);
      if (url == null) throw Exception();

      return url;
    }

    throw Exception();
  }

  // get material list from products
  Future<ProductDto> getMaterialList() async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/product/filter"),
      headers: {'Authorization': authData.bearerToken},
    );

    if (response.statusCode == HttpStatus.ok) {
      return productDtoFromJson(response.body);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  // get material list from products
  Future<List<PromotionDto>> getPromotionList() async {
    final authData = await authService.getData();
    final response = await http.get(Uri.https(config.authority, "${config.pathPrefix}/promotion"),
        headers: {'Authorization': authData.bearerToken});

    if (response.statusCode == HttpStatus.ok) {
      return promotionDtoFromJson(response.body);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      throw UnauthorizedException();
    } else if (response.statusCode == HttpStatus.locked) {
      throw BlockedUserException();
    } else if (response.statusCode == HttpStatus.notFound) {
      throw UserNotFoundException();
    }

    throw Exception();
  }

  /// Notification

  Future<List<NotificationDto>> getAllNotifications({int pageNo = 0, int pageSize = 100}) async {
    final authData = await authService.getData();
    final response = await http.get(
      Uri.https(config.authority, "${config.pathPrefix}/notification/push", {
        "pageNo": pageNo.toString(),
        "pageSize": pageSize.toString(),
      }),
      headers: {
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      final decodedJson = json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      return (decodedJson as List).map((data) => NotificationDto.fromJson(data)).toList();
    } else if (response.statusCode == HttpStatus.notFound) {
      return [];
    }

    throw Exception();
  }

  Future<bool> markNotificationAsRead({required int id}) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, ""),
      headers: {
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }

  Future<bool> updateOrderStatus({required int id, required String status}) async {
    final authData = await authService.getData();
    final response = await http.put(
      Uri.https(config.authority, "${config.pathPrefix}/hardware/order/update-status/$id", {
        "status": status,
      }),
      headers: {
        'user-iam-id': authData.identityId,
        'Authorization': authData.bearerToken,
      },
    );

    return response.statusCode == HttpStatus.ok;
  }
}
