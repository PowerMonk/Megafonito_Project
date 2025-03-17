import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class StorageService {
  static Future<Map<String, String>?> pickAndUploadFile(
      BuildContext context) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se seleccionó ningún archivo')),
        );
        return null;
      }

      // Get file details
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // Debug logging
      print('Uploading file: $fileName');
      print('File size: ${file.lengthSync()} bytes');

      // Create form data for upload
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/upload/s3'));

      // Set authorization header - DON'T manually set Content-Type for multipart requests
      request.headers['Authorization'] = 'Bearer ${ApiService.token}';

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This must match the field name expected by the server
          file.path,
          filename: fileName,
        ),
      );

      // Send request and get response
      print('Sending S3 upload request to ${request.url}');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('S3 upload response status: ${response.statusCode}');
      print('S3 upload response body: ${response.body}');

      // Parse response
      Map<String, dynamic> parsedResponse = jsonDecode(response.body);

      // Check status
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo "$fileName" subido correctamente')),
        );

        // Return the file URL and key
        return {
          'fileUrl': parsedResponse['fileUrl'] as String,
          'fileKey': parsedResponse['fileKey'] as String,
        };
      } else {
        var errorMsg = parsedResponse['error'] ?? 'Unknown error';
        throw Exception('Error al subir archivo: $errorMsg');
      }
    } catch (e) {
      print('File upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivo: $e')),
      );
      return null;
    }
  }

  static Future<void> deleteFile(String fileKey) async {
    try {
      final response = await ApiService.authenticatedRequest(
        '/s3/files/$fileKey',
        'DELETE',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete file: ${response.body}');
      }
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}
