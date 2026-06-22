import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single point of entry for the Supabase client.
///
/// The client itself is created inside [AppInitializer.init] via
/// `Supabase.initialize`. Services must read the client through this provider
/// rather than touching `Supabase.instance` directly.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
