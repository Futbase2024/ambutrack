// ignore_for_file: avoid_print

/// Script para eliminar usuario Jefe Personal
///
/// PASO 1: Obtener SERVICE_ROLE_KEY
/// - Ir a: https://supabase.com/dashboard/project/ycmopmnrhrpnnzkvnihr
/// - Navegar a: Settings → API → Project API keys
/// - Copiar la clave "service_role" (⚠️ NUNCA compartir esta clave)
///
/// PASO 2: Reemplazar SERVICE_ROLE_KEY abajo
///
/// PASO 3: Ejecutar con:
/// ```bash
/// dart run scripts/delete_jefe_personal_user.dart
/// ```
library;

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🗑️  Iniciando eliminación de usuario personal@ambulanciasbarbate.es...\n');

  // Configuración de Supabase
  const String supabaseUrl = 'https://ycmopmnrhrpnnzkvnihr.supabase.co';

  // ⚠️ REEMPLAZAR CON TU SERVICE_ROLE_KEY
  // Obtenerla en: Dashboard → Settings → API → service_role
  const String supabaseServiceRoleKey = 'TU_SERVICE_ROLE_KEY_AQUI';

  print('📦 Inicializando Supabase...');
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseServiceRoleKey, // Usar service role key para admin
  );

  final SupabaseClient supabase = Supabase.instance.client;

  try {
    // Buscar el usuario por email
    print('\n🔍 Buscando usuario personal@ambulanciasbarbate.es...');

    final List<Map<String, dynamic>> usuarios = await supabase
        .from('usuarios')
        .select('id, email, dni, nombre, apellidos')
        .eq('email', 'personal@ambulanciasbarbate.es');

    if (usuarios.isEmpty) {
      print('⚠️  Usuario no encontrado en public.usuarios');
    } else {
      final String userId = usuarios.first['id'] as String;
      print('✅ Usuario encontrado:');
      print('   UUID: $userId');
      print('   Email: ${usuarios.first['email']}');
      print('   DNI: ${usuarios.first['dni']}');
      print('   Nombre: ${usuarios.first['nombre']} ${usuarios.first['apellidos']}');

      // Eliminar de public.usuarios
      print('\n🗑️  Eliminando de public.usuarios...');
      await supabase.from('usuarios').delete().eq('id', userId);
      print('✅ Eliminado de public.usuarios');

      // Eliminar de auth.users usando Admin API
      print('\n🗑️  Eliminando de auth.users...');
      await supabase.auth.admin.deleteUser(userId);
      print('✅ Eliminado de auth.users');

      print('\n✨ Usuario eliminado completamente!');
    }

    // Buscar directamente en auth.users por si quedó huérfano
    print('\n🔍 Verificando si existe en auth.users...');

    // Note: No podemos consultar auth.users directamente con select,
    // pero podemos intentar eliminar usando el Admin API si tenemos un ID

    print('✅ Proceso de eliminación completado');

  } catch (e) {
    print('\n❌ Error al eliminar usuario:');
    print('   $e');
  }
}
