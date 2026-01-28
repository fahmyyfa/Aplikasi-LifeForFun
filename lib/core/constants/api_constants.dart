/// API Constants for Supabase and AI configuration
class ApiConstants {
  ApiConstants._();

  /// Supabase Project URL
  static const String supabaseUrl = 'https://barpmakovqdsdgjlktlp.supabase.co';

  /// Supabase Anonymous Key (Public)
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJhcnBtYWtvdnFkc2RnamxrdGxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1NzkyOTEsImV4cCI6MjA4NTE1NTI5MX0.GU_Boszfq_nJ31Of8j-1szCkPB0kz2eh7xfRSGvu73s';

  /// Supabase Storage Bucket for wishlist images
  static const String wishlistBucket = 'wishlist-images';

  /// Google Gemini API Key
  /// TODO: Replace with your actual Gemini API key from https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  /// Gemini Model for vision tasks
  static const String geminiVisionModel = 'gemini-1.5-flash';
}
