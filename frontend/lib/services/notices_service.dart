import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/notice_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Mock notices service with no real backend connections
/// Uses in-memory storage for temporary notices data
class NoticesService {
  // Mock in-memory notices storage
  static List<Notice> _cachedNotices = [];

  // Notice loading logic (using mock data)
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

  // Notice creation logic (using mock data)
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
      await Future.delayed(
          Duration(milliseconds: 800)); // Simulate network delay

      // Temporarily store the notice in memory
      final mockNotice = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'content': content,
        'category': category,
        'author_name': AuthService.currentUser?.name ?? 'Anonymous',
        'created_at': DateTime.now().toIso8601String(),
        'has_attachment': hasFile,
        'attachment_url': fileUrl,
        'attachment_key': fileKey,
      };

      // Update the mock data at the beginning of the list
      final notices = ApiService.getMockNotices();
      (notices['data'] as List).insert(0, mockNotice);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anuncio creado con éxito (modo desarrollo)')),
      );

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
