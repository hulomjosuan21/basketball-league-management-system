import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void checkSupabaseStatus() {
  if (Supabase.instance.client != null) {
    debugPrint("✅ Supabase initialized successfully!");
  } else {
    debugPrint("❌ Supabase failed to initialize.");
  }
}
