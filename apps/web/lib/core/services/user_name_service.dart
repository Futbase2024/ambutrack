import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para obtener nombres de usuarios desde Supabase
///
/// Este servicio usa un patrón singleton simple sin inyección de dependencias
/// para evitar problemas con la inicialización de Supabase
class UserNameService {
  UserNameService._();

  static final UserNameService _instance = UserNameService._();

  /// Obtiene la instancia única del servicio
  static UserNameService get instance => _instance;

  // Obtener cliente de Supabase de forma estática
  SupabaseClient get _supabase => Supabase.instance.client;

  // Cache de nombres de usuarios
  final Map<String, String> _nameCache = <String, String>{};

  /// Obtiene el nombre completo de un usuario desde su ID o email
  Future<String> getUserName(String userIdentifier) async {
    // Verificar cache primero
    if (_nameCache.containsKey(userIdentifier)) {
      return _nameCache[userIdentifier]!;
    }

    try {
      // Intento 1: Buscar en tabla usuarios (si existe)
      final String userName = await _fetchFromUsuariosTable(userIdentifier);
      if (userName.isNotEmpty) {
        _nameCache[userIdentifier] = userName;
        return userName;
      }
    } catch (e) {
      debugPrint('⚠️ Error buscando en tabla usuarios: $e');
    }

    try {
      // Intento 2: Buscar en tabla personal (staff/empleados)
      final String userName = await _fetchFromPersonalTable(userIdentifier);
      if (userName.isNotEmpty) {
        _nameCache[userIdentifier] = userName;
        return userName;
      }
    } catch (e) {
      debugPrint('⚠️ Error buscando en tabla personal: $e');
    }

    // Fallback: Formatear desde email
    final String fallbackName = _formatEmailAsName(userIdentifier);
    _nameCache[userIdentifier] = fallbackName;
    return fallbackName;
  }

  /// Busca el nombre en la tabla usuarios
  Future<String> _fetchFromUsuariosTable(String userIdentifier) async {
    try {
      // Primero intentar buscar por UUID (ID)
      dynamic response = await _supabase
          .from('usuarios')
          .select('nombre, apellidos')
          .eq('id', userIdentifier)
          .maybeSingle();

      // Si no encuentra por ID, intentar por email
      if (response == null && userIdentifier.contains('@')) {
        response = await _supabase
            .from('usuarios')
            .select('nombre, apellidos')
            .eq('email', userIdentifier)
            .maybeSingle();
      }

      if (response != null) {
        final String nombre = response['nombre'] as String? ?? '';
        final String apellidos = response['apellidos'] as String? ?? '';
        if (nombre.isNotEmpty || apellidos.isNotEmpty) {
          return '$nombre $apellidos'.trim();
        }
      }
    } catch (e) {
      debugPrint('Error en _fetchFromUsuariosTable: $e');
    }
    return '';
  }

  /// Busca el nombre en la tabla personal
  Future<String> _fetchFromPersonalTable(String userIdentifier) async {
    try {
      // Primero intentar buscar por ID (si es UUID)
      dynamic response;

      if (_isValidUuid(userIdentifier)) {
        response = await _supabase
            .from('tpersonal')
            .select('nombre, apellidos')
            .eq('id', userIdentifier)
            .maybeSingle();
      }

      // Si no encuentra por ID o no es UUID, buscar por email
      if (response == null && userIdentifier.contains('@')) {
        response = await _supabase
            .from('tpersonal')
            .select('nombre, apellidos')
            .eq('email', userIdentifier)
            .maybeSingle();
      }

      if (response != null) {
        final String nombre = response['nombre'] as String? ?? '';
        final String apellidos = response['apellidos'] as String? ?? '';
        if (nombre.isNotEmpty || apellidos.isNotEmpty) {
          return '$nombre $apellidos'.trim();
        }
      }
    } catch (e) {
      debugPrint('Error en _fetchFromPersonalTable: $e');
    }
    return '';
  }

  /// Verifica si una cadena es un UUID válido
  bool _isValidUuid(String value) {
    final RegExp uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
  }

  /// Formatea un email como nombre (fallback)
  String _formatEmailAsName(String userIdentifier) {
    // Si es un UUID, devolver "Usuario"
    if (_isValidUuid(userIdentifier)) {
      return 'Usuario ${userIdentifier.substring(0, 8)}';
    }

    // Si es un email, extraer la parte antes del @
    if (userIdentifier.contains('@')) {
      final String emailName = userIdentifier.split('@').first;
      // Capitalizar y formatear (ej: "juan.perez" -> "Juan Perez")
      return emailName
          .split('.')
          .map((String part) => part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1))
          .join(' ');
    }

    // Si es otro formato, devolverlo tal cual
    return userIdentifier;
  }

  /// Limpia el cache de nombres
  void clearCache() {
    _nameCache.clear();
  }

  /// Pre-carga múltiples nombres de usuarios de una vez
  Future<void> preloadUserNames(List<String> userIdentifiers) async {
    final List<String> uncachedUsers =
        userIdentifiers.where((String id) => !_nameCache.containsKey(id)).toList();

    if (uncachedUsers.isEmpty) {
      return;
    }

    try {
      // Cargar desde usuarios
      final dynamic usuariosResponse = await _supabase
          .from('usuarios')
          .select('id, email, nombre, apellidos')
          .or(uncachedUsers.map((String id) => 'id.eq.$id,email.eq.$id').join(','));

      if (usuariosResponse != null && usuariosResponse is List) {
        for (final dynamic user in usuariosResponse) {
          final String id = user['id'] as String? ?? user['email'] as String;
          final String nombre = user['nombre'] as String? ?? '';
          final String apellidos = user['apellidos'] as String? ?? '';
          if (nombre.isNotEmpty || apellidos.isNotEmpty) {
            _nameCache[id] = '$nombre $apellidos'.trim();
          }
        }
      }

      // Cargar desde personal para los que aún no tienen nombre
      final List<String> stillUncached =
          uncachedUsers.where((String id) => !_nameCache.containsKey(id)).toList();

      if (stillUncached.isNotEmpty) {
        final dynamic personalResponse = await _supabase
            .from('tpersonal')
            .select('email, nombre, apellidos')
            .or(stillUncached.map((String email) => 'email.eq.$email').join(','));

        if (personalResponse != null && personalResponse is List) {
          for (final dynamic person in personalResponse) {
            final String email = person['email'] as String;
            final String nombre = person['nombre'] as String? ?? '';
            final String apellidos = person['apellidos'] as String? ?? '';
            if (nombre.isNotEmpty || apellidos.isNotEmpty) {
              _nameCache[email] = '$nombre $apellidos'.trim();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error en preloadUserNames: $e');
    }
  }
}
