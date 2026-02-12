// ignore_for_file: avoid_print

/// Script temporal para crear usuario Jefe de Personal
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
/// dart run scripts/create_jefe_personal_user.dart
/// ```
library;

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🚀 Iniciando creación de usuario Jefe Personal...\n');

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
    print('\n👤 Creando usuario en Supabase Auth...');

    // Crear usuario usando Admin API
    final UserResponse response = await supabase.auth.admin.createUser(
      AdminUserAttributes(
        email: 'personal@ambulanciasbarbate.es',
        password: '123456',
        emailConfirm: true, // Auto-confirmar email
        userMetadata: <String, dynamic>{
          'nombre': 'Jorge Tomas',
          'apellidos': 'Ruiz Gallardo',
          'dni': '44045224V',
        },
      ),
    );

    if (response.user == null) {
      print('❌ Error: No se pudo crear el usuario');
      return;
    }

    final String userId = response.user!.id;
    print('✅ Usuario creado en auth.users');
    print('   UUID: $userId');
    print('   Email: ${response.user!.email}');

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

    // Verificar
    print('\n🔍 Verificando datos...');

    final Map<String, dynamic> verificacion = await supabase
        .from('usuarios')
        .select()
        .eq('id', userId)
        .single();

    print('✅ Verificación exitosa:');
    print('   DNI: ${verificacion['dni']}');
    print('   Nombre: ${verificacion['nombre']} ${verificacion['apellidos']}');
    print('   Rol: ${verificacion['rol']}');
    print('   Activo: ${verificacion['activo']}');
    print('   Empresa: ${verificacion['empresa_id']}');

    print('\n✨ Usuario Jefe Personal creado exitosamente!');
    print('\n📋 Credenciales de acceso:');
    print('   Email: personal@ambulanciasbarbate.es');
    print('   DNI: 44045224V');
    print('   Password: 123456');
    print('   UUID: $userId');

  } catch (e) {
    print('\n❌ Error al crear usuario:');
    print('   $e');
  }
}
