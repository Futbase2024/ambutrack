// ignore_for_file: avoid_print

/// Script para completar datos del usuario Jefe Personal en public.usuarios
///
/// El usuario YA FUE CREADO en auth.users con:
/// - Email: personal@ambulanciasbarbate.es
/// - Password: 123456
///
/// Este script solo agrega los datos a public.usuarios
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
/// dart run scripts/complete_jefe_personal_user.dart
/// ```
library;

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('📝 Completando datos de usuario Jefe Personal en public.usuarios...\n');

  // Configuración de Supabase
  const String supabaseUrl = 'https://ycmopmnrhrpnnzkvnihr.supabase.co';

  // ⚠️ REEMPLAZAR CON TU SERVICE_ROLE_KEY
  // Obtenerla en: Dashboard → Settings → API → service_role
  const String supabaseServiceRoleKey = 'TU_SERVICE_ROLE_KEY_AQUI';

  print('📦 Inicializando Supabase...');
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseServiceRoleKey, // Usar service role key para admin
  );

  final SupabaseClient supabase = Supabase.instance.client;

  try {
    print('\n🔍 Buscando usuario en auth.users por email...');

    // Intentar hacer login temporal para obtener el UUID
    // (esto NO es ideal pero funciona si no tenemos acceso directo a auth.users)

    // Alternativa: Buscar primero si ya existe en public.usuarios
    final List<Map<String, dynamic>> existingUsers = await supabase
        .from('usuarios')
        .select('id, email, dni')
        .eq('email', 'personal@ambulanciasbarbate.es');

    if (existingUsers.isNotEmpty) {
      print('⚠️  Usuario YA EXISTE en public.usuarios:');
      print('   UUID: ${existingUsers.first['id']}');
      print('   Email: ${existingUsers.first['email']}');
      print('   DNI: ${existingUsers.first['dni']}');
      print('\n✅ No es necesario crear nada, el usuario ya está completo');
      return;
    }

    print('✅ Usuario NO existe en public.usuarios, procediendo a crearlo...');

    // Como no podemos consultar auth.users directamente, vamos a usar signInWithPassword
    // para obtener el UUID del usuario
    print('\n🔐 Autenticando temporalmente para obtener UUID...');

    final AuthResponse authResponse = await supabase.auth.signInWithPassword(
      email: 'personal@ambulanciasbarbate.es',
      password: '123456',
    );

    if (authResponse.user == null) {
      print('❌ Error: No se pudo autenticar con el usuario');
      print('   Verifica que el usuario existe en auth.users y que la contraseña es correcta');
      return;
    }

    final String userId = authResponse.user!.id;
    print('✅ Usuario autenticado correctamente');
    print('   UUID: $userId');
    print('   Email: ${authResponse.user!.email}');

    // Insertar datos en public.usuarios
    print('\n📝 Insertando datos en public.usuarios...');

    final Map<String, Object> usuarioData = <String, Object>{
      'id': userId,
      'email': 'personal@ambulanciasbarbate.es',
      'dni': '44045224V',
      'nombre': 'Jorge Tomas',
      'apellidos': 'Ruiz Gallardo',
      'rol': 'jefe_personal',
      'activo': true,
      'empresa_id': '00000000-0000-0000-0000-000000000001',
    };

    await supabase.from('usuarios').insert(usuarioData);

    print('✅ Datos insertados en public.usuarios');

    // Cerrar sesión temporal
    await supabase.auth.signOut();
    print('\n🔓 Sesión temporal cerrada');

    // Verificar
    print('\n🔍 Verificando datos...');

    final Map<String, dynamic> verificacion = await supabase
        .from('usuarios')
        .select()
        .eq('id', userId)
        .single();

    print('✅ Verificación exitosa:');
    print('   UUID: ${verificacion['id']}');
    print('   DNI: ${verificacion['dni']}');
    print('   Nombre: ${verificacion['nombre']} ${verificacion['apellidos']}');
    print('   Rol: ${verificacion['rol']}');
    print('   Activo: ${verificacion['activo']}');
    print('   Empresa: ${verificacion['empresa_id']}');

    print('\n✨ Usuario Jefe Personal completado exitosamente!');
    print('\n📋 Credenciales de acceso:');
    print('   Email: personal@ambulanciasbarbate.es');
    print('   DNI: 44045224V');
    print('   Password: 123456');
    print('   UUID: $userId');

    print('\n🎯 Ahora puedes hacer login con:');
    print('   - DNI: 44045224V + password: 123456');
    print('   - Email: personal@ambulanciasbarbate.es + password: 123456');

  } catch (e) {
    print('\n❌ Error al completar usuario:');
    print('   $e');

    if (e.toString().contains('duplicate key')) {
      print('\n💡 El usuario ya existe en public.usuarios');
      print('   Esto está bien, significa que ya fue creado anteriormente');
    }
  }
}
