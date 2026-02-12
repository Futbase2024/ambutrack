import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../entities/movimiento_stock_entity.dart';
import '../../models/movimiento_stock_supabase_model.dart';
import '../../movimiento_stock_contract.dart';

/// Implementación de MovimientoStockDataSource usando Supabase
class SupabaseMovimientoStockDataSource implements MovimientoStockDataSource {
  SupabaseMovimientoStockDataSource(this._supabase);

  final SupabaseClient _supabase;
  static const String _tableName = 'movimientos_stock';
  final Uuid _uuid = const Uuid();

  @override
  Future<List<MovimientoStockEntity>> getAll() async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo todos los movimientos...');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(500); // Límite para performance

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos obtenidos');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos: $e');
      rethrow;
    }
  }

  @override
  Future<MovimientoStockEntity?> getById(String id) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimiento con ID: $id');

      final Map<String, dynamic>? data =
          await _supabase.from(_tableName).select().eq('id', id).maybeSingle();

      if (data == null) {
        debugPrint('=æ Movimiento DS:   Movimiento no encontrado');
        return null;
      }

      final MovimientoStockEntity movimiento =
          MovimientoStockSupabaseModel.fromJson(data).toEntity();

      debugPrint('=æ Movimiento DS:  Movimiento obtenido');
      return movimiento;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimiento: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByProducto(String idProducto) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimientos del producto: $idProducto');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_producto', idProducto)
          .order('created_at', ascending: false)
          .limit(100);

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos del producto');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos del producto: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByAlmacenOrigen(String idAlmacenOrigen) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimientos desde almacén: $idAlmacenOrigen');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_almacen_origen', idAlmacenOrigen)
          .order('created_at', ascending: false)
          .limit(100);

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos desde almacén');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos desde almacén: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByAlmacenDestino(String idAlmacenDestino) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimientos hacia almacén: $idAlmacenDestino');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_almacen_destino', idAlmacenDestino)
          .order('created_at', ascending: false)
          .limit(100);

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos hacia almacén');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos hacia almacén: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByTipo(TipoMovimientoStock tipo) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimientos de tipo: ${tipo.label}');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('tipo', tipo.code)
          .order('created_at', ascending: false)
          .limit(100);

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos de ${tipo.label}');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos por tipo: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByServicio(String idServicio) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimientos del servicio: $idServicio');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq('id_servicio', idServicio)
          .order('created_at', ascending: false);

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos del servicio');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos del servicio: $e');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getByFechaRange({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    try {
      debugPrint('=æ Movimiento DS: Obteniendo movimientos entre $desde y $hasta');

      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .gte('created_at', desde.toIso8601String())
          .lte('created_at', hasta.toIso8601String())
          .order('created_at', ascending: false);

      final List<MovimientoStockEntity> movimientos = data
          .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
          .toList();

      debugPrint('=æ Movimiento DS:  ${movimientos.length} movimientos en el rango');
      return movimientos;
    } catch (e) {
      debugPrint('=æ Movimiento DS: L Error al obtener movimientos por rango: $e');
      rethrow;
    }
  }

  /// Helper privado para crear movimiento genérico
  Future<MovimientoStockEntity> _createMovimiento({
    required TipoMovimientoStock tipo,
    required String idProducto,
    required double cantidad,
    String? idAlmacenOrigen,
    String? idAlmacenDestino,
    String? lote,
    String? numeroSerie,
    String? idServicio,
    String? referencia,
    String? motivo,
    String? observaciones,
  }) async {
    final MovimientoStockEntity movimiento = MovimientoStockEntity(
      id: _uuid.v4(),
      tipo: tipo,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      idAlmacenDestino: idAlmacenDestino,
      cantidad: cantidad,
      lote: lote,
      numeroSerie: numeroSerie,
      idServicio: idServicio,
      referencia: referencia,
      motivo: motivo,
      observaciones: observaciones,
      createdAt: DateTime.now(),
    );

    final MovimientoStockSupabaseModel model =
        MovimientoStockSupabaseModel.fromEntity(movimiento);
    final Map<String, dynamic> data =
        await _supabase.from(_tableName).insert(model.toJson()).select().single();

    return MovimientoStockSupabaseModel.fromJson(data).toEntity();
  }

  @override
  Future<MovimientoStockEntity> registrarEntradaCompra({
    required String idProducto,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? referencia,
    String? motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando entrada de compra');
    return _createMovimiento(
      tipo: TipoMovimientoStock.entradaCompra,
      idProducto: idProducto,
      idAlmacenDestino: idAlmacenDestino,
      cantidad: cantidad,
      lote: lote,
      numeroSerie: numeroSerie,
      referencia: referencia,
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarTransferenciaAVehiculo({
    required String idProducto,
    required String idAlmacenOrigen,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando transferencia a vehículo');
    return _createMovimiento(
      tipo: TipoMovimientoStock.transferenciaAVehiculo,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      idAlmacenDestino: idAlmacenDestino,
      cantidad: cantidad,
      lote: lote,
      numeroSerie: numeroSerie,
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarTransferenciaDeVehiculo({
    required String idProducto,
    required String idAlmacenOrigen,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando devolución de vehículo');
    return _createMovimiento(
      tipo: TipoMovimientoStock.transferenciaDeVehiculo,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      idAlmacenDestino: idAlmacenDestino,
      cantidad: cantidad,
      lote: lote,
      numeroSerie: numeroSerie,
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarTransferenciaEntreVehiculos({
    required String idProducto,
    required String idAlmacenOrigen,
    required String idAlmacenDestino,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando transferencia entre vehículos');
    return _createMovimiento(
      tipo: TipoMovimientoStock.transferenciaEntreVehiculos,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      idAlmacenDestino: idAlmacenDestino,
      cantidad: cantidad,
      lote: lote,
      numeroSerie: numeroSerie,
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarConsumoServicio({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    required String idServicio,
    String? lote,
    String? numeroSerie,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando consumo en servicio');
    return _createMovimiento(
      tipo: TipoMovimientoStock.consumoServicio,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      cantidad: cantidad,
      idServicio: idServicio,
      lote: lote,
      numeroSerie: numeroSerie,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarAjusteInventario({
    required String idProducto,
    required String idAlmacen,
    required double cantidad,
    required String motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando ajuste de inventario');

    // Si cantidad es positiva, es entrada (destino); si negativa, es salida (origen)
    final bool esEntrada = cantidad > 0;

    return _createMovimiento(
      tipo: TipoMovimientoStock.ajusteInventario,
      idProducto: idProducto,
      idAlmacenOrigen: esEntrada ? null : idAlmacen,
      idAlmacenDestino: esEntrada ? idAlmacen : null,
      cantidad: cantidad.abs(),
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarBajaCaducidad({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    String? lote,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando baja por caducidad');
    return _createMovimiento(
      tipo: TipoMovimientoStock.bajaCaducidad,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      cantidad: cantidad,
      lote: lote,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarBajaDeterioro({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    String? numeroSerie,
    required String motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando baja por deterioro');
    return _createMovimiento(
      tipo: TipoMovimientoStock.bajaDeterioro,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      cantidad: cantidad,
      numeroSerie: numeroSerie,
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Future<MovimientoStockEntity> registrarDevolucionProveedor({
    required String idProducto,
    required String idAlmacenOrigen,
    required double cantidad,
    String? lote,
    String? numeroSerie,
    String? referencia,
    String? motivo,
    String? observaciones,
  }) async {
    debugPrint('=æ Movimiento DS: Registrando devolución a proveedor');
    return _createMovimiento(
      tipo: TipoMovimientoStock.devolucionProveedor,
      idProducto: idProducto,
      idAlmacenOrigen: idAlmacenOrigen,
      cantidad: cantidad,
      lote: lote,
      numeroSerie: numeroSerie,
      referencia: referencia,
      motivo: motivo,
      observaciones: observaciones,
    );
  }

  @override
  Stream<List<MovimientoStockEntity>> watchAll() {
    debugPrint('=æ Movimiento DS: Observando cambios en movimientos...');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(500)
        .map((data) => data
            .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<List<MovimientoStockEntity>> watchByProducto(String idProducto) {
    debugPrint('=æ Movimiento DS: Observando movimientos del producto: $idProducto');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id_producto', idProducto)
        .order('created_at', ascending: false)
        .limit(100)
        .map((data) => data
            .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
            .toList());
  }

  @override
  Stream<List<MovimientoStockEntity>> watchByAlmacen(String idAlmacen) {
    debugPrint('=æ Movimiento DS: Observando movimientos del almacén: $idAlmacen');

    // Observar tanto movimientos de salida (origen) como de entrada (destino)
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filtrar en memoria ya que stream no soporta .or()
          final filtered = data.where((json) {
            final origen = json['id_almacen_origen'];
            final destino = json['id_almacen_destino'];
            return origen == idAlmacen || destino == idAlmacen;
          }).toList();

          // Ordenar y limitar
          filtered.sort((a, b) {
            final dateA = DateTime.parse(a['created_at'] as String);
            final dateB = DateTime.parse(b['created_at'] as String);
            return dateB.compareTo(dateA); // Descendente
          });

          return filtered
              .take(100)
              .map((json) => MovimientoStockSupabaseModel.fromJson(json).toEntity())
              .toList();
        });
  }
}
