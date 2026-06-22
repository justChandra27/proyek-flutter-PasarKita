import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class EmailServiceAppwrite {
  Future<void> sendReceiptEmail({
    required String orderId,
    required String orderCode,
    required String customerName,
    required String customerEmail,
    required List<Map<String, dynamic>> items,
    required int subtotal,
    int shippingCost = 0,
    required int total,
    required String orderDate,
  }) async {
    try {
      final payload = {
        'to': customerEmail,
        'customerName': customerName,
        'orderId': orderId,
        'orderCode': orderCode,
        'items': items,
        'subtotal': subtotal,
        'shippingCost': shippingCost,
        'total': total,
        'orderDate': orderDate,
      };

      final execution = await AppwriteService.functions.createExecution(
        functionId: AppwriteConfig.emailReceiptFunctionId,
        body: jsonEncode(payload),
        xasync: false,
      );
      debugPrint('[EmailService] Email execution sent: function=${AppwriteConfig.emailReceiptFunctionId}, orderCode=$orderCode, executionId=${execution.$id}');
    } catch (e) {
      debugPrint('[EmailService] Email execution failed: orderCode=$orderCode, error=$e');
      // Email failure must NOT block checkout
    }
  }

  Future<void> sendPaymentVerificationEmail({
    required String customerName,
    required String customerEmail,
    required String orderCode,
    required String uploadDate,
  }) async {
    try {
      final payload = {
        'type': 'payment_verification',
        'to': customerEmail,
        'customerName': customerName,
        'orderCode': orderCode,
        'status': 'Menunggu Verifikasi',
        'uploadDate': uploadDate,
      };

      final execution = await AppwriteService.functions.createExecution(
        functionId: AppwriteConfig.emailReceiptFunctionId,
        body: jsonEncode(payload),
        xasync: false,
      );
      debugPrint('[EmailService] Verification email sent: orderCode=$orderCode, executionId=${execution.$id}');
    } catch (e) {
      debugPrint('[EmailService] Verification email failed: orderCode=$orderCode, error=$e');
    }
  }
}
