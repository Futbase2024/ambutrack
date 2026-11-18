import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/inicio_turno_entity.dart';
import '../../inicio_turno_contract.dart';
import '../../models/inicio_turno_supabase_model.dart';

/// Implementación Supabase del datasource de entrada en turno
class SupabaseInicioTurnoDataSource implements InicioTurnoDataSource {
  SupabaseInicioTurnoDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _tabla = 'inicios_turno';
  static const String _bucketFotos = 'fotos-km';

  @override
  Future<InicioTurnoEntity> create(InicioTurnoEntity entity) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_tabla)
          .insert(InicioTurnoSupabaseModel.toInsertJson(entity))
          .select()
          .single();
      return InicioTurnoSupabaseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al registrar el inicio de turno: $e');
    }
  }

  @override
  Future<List<String>> getPlantillaChecklist() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from('plantilla_checklist_inicio_turno')
          .select('item_nombre')
          .eq('activo', true)
          .order('orden');
      return response.map((Map<String, dynamic> r) => r['item_nombre'] as String).toList();
    } catch (e) {
      throw Exception('Error al obtener el checklist de inicio de turno: $e');
    }
  }

  @override
  Future<List<OcupanteVehiculoEntity>> getOcupacionVehiculo(String vehiculoId) async {
    try {
      final dynamic response = await _supabase.rpc<dynamic>(
        'fn_ocupacion_vehiculo',
        params: <String, dynamic>{'p_vehiculo_id': vehiculoId},
      );
      final List<dynamic> filas = response is List ? response : const <dynamic>[];
      return filas.whereType<Map<String, dynamic>>().map((Map<String, dynamic> r) {
        final String? desde = r['desde'] as String?;
        return OcupanteVehiculoEntity(
          personalId: r['personal_id'] as String,
          personalNombre: r['personal_nombre'] as String?,
          desde: desde == null ? null : DateTime.parse(desde),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al consultar la ocupación del vehículo: $e');
    }
  }

  @override
  Future<UbicacionBaseEntity?> getUbicacionBase(String baseId) async {
    try {
      final Map<String, dynamic>? r = await _supabase
          .from('bases')
          .select('id, nombre, latitud, longitud')
          .eq('id', baseId)
          .maybeSingle();
      if (r == null || r['latitud'] == null || r['longitud'] == null) {
        return null;
      }
      return UbicacionBaseEntity(
        id: r['id'] as String,
        nombre: r['nombre'] as String? ?? '',
        latitud: (r['latitud'] as num).toDouble(),
        longitud: (r['longitud'] as num).toDouble(),
      );
    } catch (e) {
      throw Exception('Error al obtener la ubicación de la base: $e');
    }
  }

  @override
  Future<String> subirFotoKm({required Uint8List bytes, required String extension}) async {
    final String? uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw Exception('No hay sesión activa');
    }
    final String ruta = '$uid/${DateTime.now().millisecondsSinceEpoch}.$extension';
    try {
      await _supabase.storage.from(_bucketFotos).uploadBinary(
            ruta,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$extension'),
          );
      return ruta;
    } catch (e) {
      throw Exception('Error al subir la foto del cuentakilómetros: $e');
    }
  }

  @override
  Future<String> getUrlFotoKm(String ruta) async {
    try {
      return await _supabase.storage.from(_bucketFotos).createSignedUrl(ruta, 3600);
    } catch (e) {
      throw Exception('Error al obtener la foto del cuentakilómetros: $e');
    }
  }

  @override
  Future<String?> getRolUsuarioActual() async {
    final String? uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      return null;
    }
    try {
      final Map<String, dynamic>? r =
          await _supabase.from('usuarios').select('rol').eq('id', uid).maybeSingle();
      return r?['rol'] as String?;
    } catch (e) {
      throw Exception('Error al obtener el rol del usuario: $e');
    }
  }

  @override
  Future<List<InicioTurnoEntity>> getPendientesValidacion() async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tabla)
          .select()
          .eq('estado_validacion', EstadoValidacionInicio.pendiente.value)
          .order('created_at', ascending: false);
      return response.map(InicioTurnoSupabaseModel.fromJson).toList();
    } catch (e) {
      throw Exception('Error al obtener inicios de turno pendientes: $e');
    }
  }

  @override
  Future<List<InicioTurnoEntity>> getByRango({required DateTime desde, required DateTime hasta}) async {
    try {
      final List<Map<String, dynamic>> response = await _supabase
          .from(_tabla)
          .select()
          .gte('created_at', desde.toUtc().toIso8601String())
          .lt('created_at', hasta.toUtc().toIso8601String())
          .order('created_at', ascending: false);
      return response.map(InicioTurnoSupabaseModel.fromJson).toList();
    } catch (e) {
      throw Exception('Error al obtener inicios de turno: $e');
    }
  }

  @override
  Future<InicioTurnoEntity> validar({
    required String id,
    required bool aprobado,
    String? motivoRechazo,
  }) async {
    try {
      final Map<String, dynamic> response = await _supabase
          .from(_tabla)
          .update(<String, dynamic>{
            'estado_validacion':
                aprobado ? EstadoValidacionInicio.aprobado.value : EstadoValidacionInicio.rechazado.value,
            'motivo_rechazo': aprobado ? null : motivoRechazo,
          })
          .eq('id', id)
          .select()
          .single();
      return InicioTurnoSupabaseModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al validar el inicio de turno: $e');
    }
  }
}
