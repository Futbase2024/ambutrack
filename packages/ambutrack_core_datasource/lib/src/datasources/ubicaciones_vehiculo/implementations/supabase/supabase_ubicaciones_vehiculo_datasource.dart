import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/ubicacion_vehiculo_entity.dart';
import '../../models/ubicacion_vehiculo_supabase_model.dart';
import '../../ubicaciones_vehiculo_contract.dart';

/// Implementación Supabase del seguimiento GPS
class SupabaseUbicacionesVehiculoDataSource implements UbicacionesVehiculoDataSource {
  SupabaseUbicacionesVehiculoDataSource({SupabaseClient? supabase}) : _client = supabase ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _tabla = 'thistorial_ubicaciones';

  List<UbicacionVehiculoEntity> _map(dynamic rows) => (rows as List<dynamic>)
      .map((dynamic r) => UbicacionVehiculoSupabaseModel(r as Map<String, dynamic>).toEntity())
      .toList();

  @override
  Future<List<UbicacionVehiculoEntity>> getUltimas() async {
    try {
      return _map(await _client.rpc<dynamic>('fn_ultimas_ubicaciones'));
    } catch (e) {
      throw Exception('Error al obtener las últimas posiciones: $e');
    }
  }

  @override
  Future<List<UbicacionVehiculoEntity>> getRecorrido(String vehiculoId,
      {required DateTime desde, DateTime? hasta}) async {
    try {
      final List<Map<String, dynamic>> rows = await _client
          .from(_tabla)
          .select('vehiculo_id, timestamp, latitud, longitud, velocidad_kmh, en_servicio')
          .eq('vehiculo_id', vehiculoId)
          .gte('timestamp', desde.toUtc().toIso8601String())
          .lte('timestamp', (hasta ?? DateTime.now()).toUtc().toIso8601String())
          .order('timestamp')
          .limit(5000);
      return _map(rows);
    } catch (e) {
      throw Exception('Error al obtener el recorrido: $e');
    }
  }

  @override
  Stream<UbicacionVehiculoEntity> watchNuevas() {
    RealtimeChannel? channel;
    late final StreamController<UbicacionVehiculoEntity> controller;
    controller = StreamController<UbicacionVehiculoEntity>(
      onListen: () {
        debugPrint('📍 Ubicaciones: 📡 escuchando nuevas posiciones');
        channel = _client
            .channel('ubicaciones_flota')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: _tabla,
              callback: (PostgresChangePayload payload) {
                try {
                  if (!controller.isClosed) {
                    controller.add(UbicacionVehiculoSupabaseModel(payload.newRecord).toEntity());
                  }
                } catch (e) {
                  debugPrint('📍 Ubicaciones: ⚠️ posición no válida: $e');
                }
              },
            )
            .subscribe();
      },
      onCancel: () async {
        debugPrint('📍 Ubicaciones: 📴 fin de escucha');
        final RealtimeChannel? canal = channel;
        if (canal != null) {
          await _client.removeChannel(canal);
        }
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> registrar({
    required double latitud,
    required double longitud,
    double? velocidadKmh,
    double? precisionMetros,
    double? direccionGrados,
    String? servicioId,
  }) async {
    try {
      await _client.rpc<dynamic>(
        'fn_registrar_ubicacion',
        params: <String, dynamic>{
          'p_latitud': latitud,
          'p_longitud': longitud,
          'p_velocidad_kmh': velocidadKmh,
          'p_precision_metros': precisionMetros,
          'p_direccion_grados': direccionGrados,
          'p_servicio_id': servicioId,
        },
      );
    } catch (e) {
      throw Exception('Error al registrar la posición: $e');
    }
  }
}
