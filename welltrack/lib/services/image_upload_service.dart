import 'dart:io';
import 'package:flutter/material.dart';
import 'package:welltrack/main.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  // Upload image to Supabase Storage
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '$userId/$fileName';

      // Upload file to Supabase Storage
      await supabase.storage
          .from('profile-images')
          .upload(filePath, imageFile);

      // Get the public URL
      final String imageUrl = supabase.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      debugPrint('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      
      // Provide specific error handling in logs
      if (e.toString().contains('Bucket not found')) {
        debugPrint('Storage bucket "profile-images" not found. Please create it in Supabase Dashboard.');
      } else if (e.toString().contains('NetworkException') || 
                 e.toString().contains('SocketException')) {
        debugPrint('Network error during upload');
      }
      
      return null;
    }
  }

  // Delete image from Supabase Storage
  Future<bool> deleteImage(String filePath) async {
    try {
      await supabase.storage
          .from('profile-images')
          .remove([filePath]);
      debugPrint('Image deleted successfully: $filePath');
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  // Get file path from URL
  String? getFilePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the index where 'profile-images' appears
      int bucketIndex = pathSegments.indexOf('profile-images');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        // Get everything after 'profile-images' as the file path
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing URL for file path: $e');
      return null;
    }
  }
} 