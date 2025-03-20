import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/notice_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NoticesService {
  // Notice loading logic
  static Future<Map<String, dynamic>> loadNotices({
    int page = 1,
    int limit = 5,
    String? category,
    bool? hasFiles,
  }) async {
    try {
      return await ApiService.getNotices(
        page: page,
        limit: limit,
        category: category,
        hasFiles: hasFiles,
      );
    } catch (e) {
      print('Error loading notices: $e');
      rethrow;
    }
  }

  // Notice creation logic
  static Future<void> createNotice(
    BuildContext context, {
    required String title,
    required String content,
    required String category,
    required bool hasFile,
    String? fileUrl,
    String? fileKey,
  }) async {
    try {
      // Get user ID, defaulting to 1 if not available
      final userId = AuthService.currentUser?.id ?? ApiService.userId;
      // final userId = AuthService.currentUser?.id ?? ApiService.userId ?? 1;

      // Use null-safe fallback for userId (with debug info)
      print(
          'Creating notice with userID: $userId (from auth: ${AuthService.currentUser?.id}, from API: ${ApiService.userId})');

      final response = await ApiService.authenticatedRequest(
        '/notices',
        'POST',
        body: {
          'title': title,
          'content': content,
          'userId': userId, // Get from current user if available
          // 1, // Hardcoded user ID for now
          'category': category,
          'hasFile': hasFile,
          'fileUrl': fileUrl,
          'fileKey': fileKey,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Error creating announcement: ${response.body}');
      }

      return;
    } catch (e) {
      print('Error creating announcement: $e');
      rethrow;
    }
  }

  // Sorting function
  static List<Map<String, dynamic>> sortNotices(
    List<Map<String, dynamic>> notices,
    String? sortOption,
  ) {
    List<Map<String, dynamic>> sorted = List.from(notices);
    if (sortOption == 'Más recientes') {
      sorted.sort(
          (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
    } else if (sortOption == 'Más antiguos') {
      sorted.sort(
          (a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));
    }
    return sorted;
  }

  static Future<List<Notice>> convertApiResponseToNotices(
      dynamic apiResponse) async {
    try {
      if (apiResponse == null || !apiResponse.containsKey('data')) {
        return [];
      }

      List<dynamic> noticesData = apiResponse['data'];

      return noticesData.map((data) => Notice.fromJson(data)).toList();
    } catch (e) {
      print('Error converting API response to notices: $e');
      return [];
    }
  }
}
