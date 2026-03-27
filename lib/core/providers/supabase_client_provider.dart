import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// Provider para acceder al cliente de Supabase desde cualquier widget.
/// Al ser `keepAlive: true`, la instancia persiste durante toda la sesión.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
