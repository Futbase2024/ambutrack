import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../users/entities/users_entity.dart';
import '../../../usuarios/implementations/supabase/supabase_usuarios_datasource.dart';
import '../../cuentas_usuario_contract.dart';

/// Implementación de [CuentasUsuarioDataSource] sobre la Edge Function `admin-users`
class SupabaseCuentasUsuarioDataSource implements CuentasUsuarioDataSource {
  SupabaseCuentasUsuarioDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _funcion = 'admin-users';

  @override
  Future<String> crear(UserEntity usuario, String claveProvisional) async {
    debugPrint('🚀 CuentasUsuario: Creando cuenta ${usuario.email}');
    final Map<String, dynamic> data = await _invocar(<String, dynamic>{
      'action': 'create',
      'email': usuario.email,
      'password': claveProvisional,
      ..._datosPerfil(usuario),
    });
    final String id = data['user_id'] as String;
    debugPrint('✅ CuentasUsuario: Cuenta creada con ID $id');
    return id;
  }

  @override
  Future<void> actualizar(UserEntity usuario) async {
    debugPrint('📝 CuentasUsuario: Actualizando ${usuario.id}');
    await _invocar(<String, dynamic>{
      'action': 'update',
      'user_id': usuario.id,
      ..._datosPerfil(usuario),
    });
  }

  @override
  Future<void> restablecerClave(String usuarioId, String claveProvisional) async {
    debugPrint('🔒 CuentasUsuario: Restableciendo clave de $usuarioId');
    await _invocar(<String, dynamic>{
      'action': 'reset_password',
      'user_id': usuarioId,
      'password': claveProvisional,
    });
  }

  @override
  Future<void> cambiarEstado(String usuarioId, {required bool activo}) async {
    debugPrint('🔄 CuentasUsuario: ${activo ? 'Activando' : 'Desactivando'} $usuarioId');
    await _invocar(<String, dynamic>{'action': 'set_active', 'user_id': usuarioId, 'activo': activo});
  }

  @override
  Future<void> eliminar(String usuarioId) async {
    debugPrint('🗑️ CuentasUsuario: Eliminando $usuarioId');
    await _invocar(<String, dynamic>{'action': 'delete', 'user_id': usuarioId});
  }

  @override
  Future<void> cambiarMiClave(String nuevaClave) async {
    debugPrint('🔑 CuentasUsuario: Cambiando la clave propia');
    await _invocar(<String, dynamic>{'action': 'change_own_password', 'password': nuevaClave});
  }

  @override
  Future<bool> debeCambiarClave() async {
    final String? uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      return false;
    }
    final Map<String, dynamic>? fila = await _supabase
        .from('usuarios')
        .select('debe_cambiar_password')
        .eq('id', uid)
        .maybeSingle();
    return fila?['debe_cambiar_password'] == true;
  }

  /// Campos de perfil comunes a alta y edición.
  ///
  /// Nombre y apellidos van en metadata cuando el formulario los separa;
  /// si no, se parte el displayName (primera palabra = nombre).
  Map<String, dynamic> _datosPerfil(UserEntity u) {
    final Map<String, dynamic> meta = u.metadata ?? const <String, dynamic>{};
    final List<String> partes = (u.displayName ?? '').trim().split(RegExp(r'\s+'));
    return <String, dynamic>{
      'nombre': meta['nombre'] ?? (partes.isNotEmpty ? partes.first : ''),
      'apellidos': meta['apellidos'] ?? (partes.length > 1 ? partes.sublist(1).join(' ') : null),
      'dni': u.dni,
      'telefono': u.phoneNumber,
      'rol': u.rol,
      'empresa_id': u.empresaId,
      if (meta.containsKey('personalId')) 'personal_id': u.personalId,
      'activo': u.isActive,
    };
  }

  /// Llama a la Edge Function y traduce sus errores a [CuentaUsuarioException]
  Future<Map<String, dynamic>> _invocar(Map<String, dynamic> body) async {
    try {
      final FunctionResponse res = await _supabase.functions.invoke(_funcion, body: body);
      SupabaseUsuarioDataSource.invalidarCache();
      final Object? data = res.data;
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on FunctionException catch (e) {
      final Object? details = e.details;
      final String mensaje = details is Map && details['error'] is String
          ? details['error'] as String
          : 'No se pudo completar la operación (${e.status})';
      debugPrint('❌ CuentasUsuario: $mensaje');
      throw CuentaUsuarioException(mensaje);
    }
  }
}
