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

      // Upload the picked file
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // Create form data for upload
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/upload/s3'));

      // Add authorization header
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = 'Bearer ${ApiService.token}';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ),
      );

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var parsedResponse = jsonDecode(responseData);

      // Check status
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo "$fileName" subido correctamente')),
        );

        // Return the file URL and key
        return {
          'fileUrl': parsedResponse['fileUrl'],
          'fileKey': parsedResponse['fileKey'],
        };
      } else {
        throw Exception(
            'Failed to upload file: ${parsedResponse['error'] ?? response.statusCode}');
      }
    } catch (e) {
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
