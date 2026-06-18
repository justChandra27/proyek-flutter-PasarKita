import 'dart:convert';

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

      await AppwriteService.functions.createExecution(
        functionId: AppwriteConfig.emailReceiptFunctionId,
        body: jsonEncode(payload),
        xasync: false,
      );
    } catch (e) {
      // Email failure must NOT block checkout
    }
  }
}
