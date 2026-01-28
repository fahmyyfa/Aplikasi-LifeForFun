import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/api_constants.dart';

/// Model for extracted schedule item from AI
class ExtractedScheduleItem {
  final String title;
  final DateTime date;
  final String? description;
  final bool isFasting;

  const ExtractedScheduleItem({
    required this.title,
    required this.date,
    this.description,
    this.isFasting = false,
  });

  factory ExtractedScheduleItem.fromJson(Map<String, dynamic> json) {
    // Parse date from YYYY-MM-DD format
    final dateStr = json['date'] as String;
    final dateParts = dateStr.split('-');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    // Check if it's a fasting event based on title keywords
    final title = json['title'] as String;
    final isFasting = _isFastingEvent(title);

    return ExtractedScheduleItem(
      title: title,
      date: date,
      description: json['description'] as String?,
      isFasting: isFasting,
    );
  }

  /// Check if the title indicates a fasting event
  static bool _isFastingEvent(String title) {
    final lowerTitle = title.toLowerCase();
    return lowerTitle.contains('puasa') ||
        lowerTitle.contains('fasting') ||
        lowerTitle.contains('senin kamis') ||
        lowerTitle.contains('ayyamul bidh') ||
        lowerTitle.contains('daud');
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'description': description,
      'is_fasting': isFasting,
    };
  }
}

/// Service for Google Gemini AI integration
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize the Gemini model
  void _initializeModel() {
    if (_model != null) return;

    _model = GenerativeModel(
      model: ApiConstants.geminiVisionModel,
      apiKey: ApiConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
    );
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Analyze schedule image using Gemini AI
  /// Returns list of extracted schedule items
  Future<List<ExtractedScheduleItem>> analyzeScheduleImage(File image) async {
    _initializeModel();

    // Read image bytes
    final Uint8List imageBytes = await image.readAsBytes();

    // Determine mime type
    final String mimeType = _getMimeType(image.path);

    // Create the prompt for schedule extraction
    const String prompt = '''
Ekstrak jadwal kegiatan dan tanggal dari gambar ini.
Kembalikan HANYA dalam format JSON array dengan struktur berikut:
[
  {
    "title": "Nama kegiatan",
    "date": "YYYY-MM-DD",
    "description": "Deskripsi singkat (optional)"
  }
]

Aturan:
1. Gunakan format tanggal YYYY-MM-DD
2. Jika tahun tidak disebutkan, gunakan tahun 2026
3. Jika ada kegiatan puasa, tulis dengan jelas (misal: "Puasa Senin Kamis")
4. Kembalikan array kosong [] jika tidak ada jadwal ditemukan
5. HANYA kembalikan JSON, tanpa teks tambahan
''';

    try {
      // Create content with image
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ];

      // Generate response
      final response = await _model!.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return [];
      }

      // Parse JSON response
      return _parseScheduleResponse(responseText);
    } catch (e) {
      throw Exception('Gagal menganalisis gambar: ${e.toString()}');
    }
  }

  /// Parse the AI response to extract schedule items
  List<ExtractedScheduleItem> _parseScheduleResponse(String responseText) {
    try {
      // Clean response - remove markdown code blocks if present
      String cleanedResponse = responseText.trim();
      
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      } else if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }

      cleanedResponse = cleanedResponse.trim();

      // Parse JSON
      final List<dynamic> jsonList = json.decode(cleanedResponse);

      return jsonList
          .map((item) => ExtractedScheduleItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Get mime type from file path
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
