import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../dispositivos_push_contract.dart';

/// Implementación Supabase de [DispositivosPushDataSource] (vía RPC SECURITY DEFINER)
class SupabaseDispositivosPushDataSource implements DispositivosPushDataSource {
  SupabaseDispositivosPushDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<void> registrar({required String token, required String plataforma, String? appVersion}) async {
    debugPrint('📲 DispositivosPush: Registrando dispositivo ($plataforma)');
    await _supabase.rpc<void>(
      'fn_registrar_dispositivo_push',
      params: <String, dynamic>{'p_token': token, 'p_plataforma': plataforma, 'p_app_version': appVersion},
    );
  }

  @override
  Future<void> eliminar(String token) async {
    debugPrint('📲 DispositivosPush: Dando de baja el dispositivo');
    await _supabase.rpc<void>('fn_eliminar_dispositivo_push', params: <String, dynamic>{'p_token': token});
  }
}
