import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../stock/entities/stock_vehiculo_entity.dart';
import '../../../stock/models/stock_vehiculo_supabase_model.dart';
import '../../equipamiento_vehiculo_contract.dart';

/// Implementación Supabase de [EquipamientoVehiculoDataSource]
class SupabaseEquipamientoVehiculoDataSource implements EquipamientoVehiculoDataSource {
  SupabaseEquipamientoVehiculoDataSource(this._client);

  final SupabaseClient _client;

  static const String _tabla = 'stock_vehiculo';
  static const String _vista = 'v_stock_vehiculo_estado';
  static const String _bucket = 'equipamiento-vehiculos';

  @override
  Future<List<StockVehiculoEntity>> getDotacion(String vehiculoId) async {
    try {
      debugPrint('🚑 EquipamientoVehiculo: obteniendo dotación de $vehiculoId...');
      final List<Map<String, dynamic>> response = await _client
          .from(_vista)
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('seccion_orden')
          .order('orden')
          .order('producto_nombre');
      final List<StockVehiculoEntity> lineas = response.map(_toEntity).toList();
      debugPrint('🚑 EquipamientoVehiculo: ✅ ${lineas.length} líneas');
      return lineas;
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error getDotacion: $e');
      rethrow;
    }
  }

  @override
  Future<StockVehiculoEntity?> getLinea(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _client.from(_vista).select().eq('id', id).maybeSingle();
      return response == null ? null : _toEntity(response);
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error getLinea: $e');
      rethrow;
    }
  }

  @override
  Future<StockVehiculoEntity> actualizarLinea({
    required String id,
    required int cantidadActual,
    DateTime? fechaCaducidad,
    bool borrarCaducidad = false,
    String? lote,
    String? observaciones,
  }) {
    return _actualizar(id, <String, dynamic>{
      'cantidad_actual': cantidadActual,
      if (borrarCaducidad) 'fecha_caducidad': null,
      if (!borrarCaducidad && fechaCaducidad != null) 'fecha_caducidad': _soloFecha(fechaCaducidad),
      'lote': _vacioANull(lote),
      'observaciones': _vacioANull(observaciones),
    });
  }

  @override
  Future<StockVehiculoEntity> setExcluido(String id, {required bool excluido}) {
    return _actualizar(id, <String, dynamic>{'excluido': excluido});
  }

  @override
  Future<StockVehiculoEntity> addExtra({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    DateTime? fechaCaducidad,
    String? lote,
    String? observaciones,
  }) async {
    try {
      debugPrint('🚑 EquipamientoVehiculo: añadiendo extra $productoId a $vehiculoId...');
      final Map<String, dynamic> response = await _client
          .from(_tabla)
          .insert(<String, dynamic>{
            'vehiculo_id': vehiculoId,
            'producto_id': productoId,
            'cantidad_actual': cantidad,
            'fecha_caducidad': fechaCaducidad == null ? null : _soloFecha(fechaCaducidad),
            'lote': _vacioANull(lote),
            'observaciones': _vacioANull(observaciones),
            'origen': 'manual',
          })
          .select('id')
          .single();
      return _releer(response['id'] as String);
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error addExtra: $e');
      rethrow;
    }
  }

  @override
  Future<void> eliminarExtra(String id) async {
    try {
      debugPrint('🚑 EquipamientoVehiculo: eliminando extra $id...');
      await _client.from(_tabla).delete().eq('id', id).eq('origen', 'manual');
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error eliminarExtra: $e');
      rethrow;
    }
  }

  @override
  Future<StockVehiculoEntity> subirAdjunto({
    required String id,
    required String vehiculoId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    try {
      final String nombreSeguro = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final String path = '$vehiculoId/$id/${DateTime.now().millisecondsSinceEpoch}_$nombreSeguro';
      debugPrint('🚑 EquipamientoVehiculo: subiendo adjunto $path...');

      final String? anterior = (await getLinea(id))?.documentoPath;
      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );
      final StockVehiculoEntity linea = await _actualizar(id, <String, dynamic>{
        'documento_path': path,
        'documento_nombre': fileName,
      });
      await _borrarArchivo(anterior);
      return linea;
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error subirAdjunto: $e');
      rethrow;
    }
  }

  @override
  Future<StockVehiculoEntity> eliminarAdjunto(String id) async {
    final String? anterior = (await getLinea(id))?.documentoPath;
    final StockVehiculoEntity linea = await _actualizar(id, <String, dynamic>{
      'documento_path': null,
      'documento_nombre': null,
    });
    await _borrarArchivo(anterior);
    return linea;
  }

  @override
  Future<String> getUrlAdjunto(String documentoPath, {int expiresInSeconds = 3600}) async {
    try {
      return await _client.storage.from(_bucket).createSignedUrl(documentoPath, expiresInSeconds);
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error getUrlAdjunto: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------------ Helpers

  Future<StockVehiculoEntity> _actualizar(String id, Map<String, dynamic> cambios) async {
    try {
      await _client.from(_tabla).update(cambios).eq('id', id);
      return _releer(id);
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ❌ Error actualizando $id: $e');
      rethrow;
    }
  }

  Future<StockVehiculoEntity> _releer(String id) async {
    final StockVehiculoEntity? linea = await getLinea(id);
    if (linea == null) {
      throw StateError('Línea de equipamiento $id no encontrada');
    }
    return linea;
  }

  /// El archivo anterior solo lo puede borrar admin/jefe (política de Storage).
  /// Si falla no se interrumpe la operación: el registro ya apunta al nuevo.
  Future<void> _borrarArchivo(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _client.storage.from(_bucket).remove(<String>[path]);
    } catch (e) {
      debugPrint('🚑 EquipamientoVehiculo: ⚠️ No se pudo borrar el archivo anterior: $e');
    }
  }

  StockVehiculoEntity _toEntity(Map<String, dynamic> json) =>
      StockVehiculoSupabaseModel.fromJson(json).toEntity();

  static String? _vacioANull(String? valor) {
    final String? limpio = valor?.trim();
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }

  static String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
