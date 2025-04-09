import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Mock storage service with no real S3 bucket connections
/// Uses temporary file handling for UI development
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
      String fileName = result.files.single.name;

      // Simulate upload delay
      await Future.delayed(Duration(milliseconds: 1500));

      // Generate mock S3 details
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final mockFileUrl = 'https://example.com/mock-files/$timestamp-$fileName';
      final mockFileKey = 'mock-key-$timestamp-$fileName';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Archivo "$fileName" subido correctamente (modo desarrollo)')),
      );

      // Return mock file details
      return {
        'fileUrl': mockFileUrl,
        'fileKey': mockFileKey,
      };
    } catch (e) {
      print('File upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivo: $e')),
      );
      return null;
    }
  }

  static Future<void> deleteFile(String fileKey) async {
    // Mock file deletion
    await Future.delayed(Duration(milliseconds: 800));
    print('File deleted (mock): $fileKey');
    return;
  }
}
