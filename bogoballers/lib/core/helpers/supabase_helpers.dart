import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void checkSupabaseStatus() {
  try {
    Supabase.instance.client;
    debugPrint("✅ Supabase initialized successfully!");
  } catch (_) {
    rethrow;
  }
}
