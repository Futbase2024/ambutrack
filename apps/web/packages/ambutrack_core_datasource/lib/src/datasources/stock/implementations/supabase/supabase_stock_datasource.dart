import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/alerta_stock_entity.dart';
import '../../entities/categoria_equipamiento_entity.dart';
import '../../entities/item_revision_entity.dart';
import '../../entities/movimiento_stock_entity.dart';
import '../../entities/producto_entity.dart';
import '../../entities/revision_mensual_entity.dart';
import '../../entities/stock_minimo_entity.dart';
import '../../entities/stock_vehiculo_entity.dart';
import '../../models/alerta_stock_supabase_model.dart';
import '../../models/categoria_equipamiento_supabase_model.dart';
import '../../models/item_revision_supabase_model.dart';
import '../../models/movimiento_stock_supabase_model.dart';
import '../../models/producto_supabase_model.dart';
import '../../models/revision_mensual_supabase_model.dart';
import '../../models/stock_minimo_supabase_model.dart';
import '../../models/stock_vehiculo_supabase_model.dart';
import '../../stock_contract.dart';

/// Implementación Supabase del datasource de Stock
class SupabaseStockDataSource implements StockDataSource {
  /// Cliente de Supabase
  final SupabaseClient _supabase;

  /// Constructor
  SupabaseStockDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ========================================================================
  // CATEGORÍAS DE EQUIPAMIENTO
  // ========================================================================

  @override
  Future<List<CategoriaEquipamientoEntity>> getCategorias() async {
    try {
      debugPrint('📦 StockDataSource: Obteniendo categorías...');

      final response = await _supabase
          .from('categorias_equipamiento')
          .select()
          .order('orden');

      final List<CategoriaEquipamientoEntity> categorias = (response)
          .map(
            (json) => CategoriaEquipamientoSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();

      debugPrint('📦 StockDataSource: ✅ ${categorias.length} categorías obtenidas');
      return categorias;
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al obtener categorías: $e');
      rethrow;
    }
  }

  @override
  Future<CategoriaEquipamientoEntity?> getCategoriaById(String id) async {
    try {
      final response = await _supabase
          .from('categorias_equipamiento')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return CategoriaEquipamientoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al obtener categoría: $e');
      rethrow;
    }
  }

  // ========================================================================
  // PRODUCTOS
  // ========================================================================

  @override
  Future<List<ProductoEntity>> getProductos() async {
    try {
      debugPrint('📦 StockDataSource: Obteniendo productos...');

      final response = await _supabase
          .from('productos')
          .select()
          .eq('activo', true)
          .order('nombre');

      debugPrint('📦 StockDataSource: Respuesta de Supabase: ${response.length} registros');

      final List<ProductoEntity> productos = [];
      for (int i = 0; i < response.length; i++) {
        try {
          final json = response[i];
          debugPrint('📦 StockDataSource: Procesando producto ${i + 1}: ${json['nombre']}');
          final model = ProductoSupabaseModel.fromJson(json);
          productos.add(model.toEntity());
        } catch (e) {
          debugPrint('📦 StockDataSource: ❌ Error en producto ${i + 1}: $e');
          debugPrint('📦 StockDataSource: JSON problemático: ${response[i]}');
          rethrow;
        }
      }

      debugPrint('📦 StockDataSource: ✅ ${productos.length} productos obtenidos');
      return productos;
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al obtener productos: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductoEntity>> getProductosByCategoria(
    String categoriaId,
  ) async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .eq('categoria_id', categoriaId)
          .eq('activo', true)
          .order('nombre');

      return (response)
          .map(
            (json) => ProductoSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity?> getProductoById(String id) async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return ProductoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity> createProducto(ProductoEntity producto) async {
    try {
      final model = ProductoSupabaseModel.fromEntity(producto);
      final response = await _supabase
          .from('productos')
          .insert(model.toJson())
          .select()
          .single();

      return ProductoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al crear producto: $e');
      rethrow;
    }
  }

  @override
  Future<ProductoEntity> updateProducto(ProductoEntity producto) async {
    try {
      final model = ProductoSupabaseModel.fromEntity(producto);
      final response = await _supabase
          .from('productos')
          .update(model.toJson())
          .eq('id', producto.id)
          .select()
          .single();

      return ProductoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al actualizar producto: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProducto(String id) async {
    try {
      await _supabase.from('productos').delete().eq('id', id);
      debugPrint('📦 StockDataSource: ✅ Producto eliminado');
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al eliminar producto: $e');
      rethrow;
    }
  }

  // ========================================================================
  // STOCK MÍNIMO POR TIPO
  // ========================================================================

  @override
  Future<StockMinimoEntity?> getStockMinimo(
    String productoId,
    String tipoVehiculo,
  ) async {
    try {
      final response = await _supabase
          .from('stock_minimo_por_tipo')
          .select()
          .eq('producto_id', productoId)
          .eq('tipo_vehiculo', tipoVehiculo)
          .maybeSingle();

      if (response == null) return null;

      return StockMinimoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<StockMinimoEntity>> getStockMinimoByTipo(
    String tipoVehiculo,
  ) async {
    try {
      final response = await _supabase
          .from('stock_minimo_por_tipo')
          .select()
          .eq('tipo_vehiculo', tipoVehiculo);

      return (response)
          .map(
            (json) => StockMinimoSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<StockMinimoEntity> upsertStockMinimo(
    StockMinimoEntity stockMinimo,
  ) async {
    try {
      final model = StockMinimoSupabaseModel.fromEntity(stockMinimo);
      final response = await _supabase
          .from('stock_minimo_por_tipo')
          .upsert(model.toJson())
          .select()
          .single();

      return StockMinimoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  // ========================================================================
  // STOCK DE VEHÍCULO
  // ========================================================================

  @override
  Future<List<StockVehiculoEntity>> getStockVehiculo(String vehiculoId) async {
    try {
      debugPrint('📦 StockDataSource (LEGACY): Obteniendo stock del vehículo $vehiculoId...');
      debugPrint('📦 Consultando tabla: stock_vehiculo');

      // Consulta simple sin joins - solo campos de stock_vehiculo
      final response = await _supabase
          .from('stock_vehiculo')
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('updated_at', ascending: false);

      debugPrint('📦 Response raw: ${response.length} registros encontrados');

      if (response.isEmpty) {
        debugPrint('⚠️ No se encontraron registros en stock_vehiculo para vehiculo_id: $vehiculoId');
        return [];
      }

      // Cargar productos para enriquecer los datos (solo nombre y nombre comercial)
      final productosResponse = await _supabase
          .from('productos')
          .select('id, nombre, nombre_comercial');

      final productosMap = {
        for (var p in productosResponse) p['id'] as String: p
      };

      final List<StockVehiculoEntity> items = (response)
          .map(
            (json) {
              debugPrint('📦 Processing item: ${json['id']} - Producto ID: ${json['producto_id']}');

              // Enriquecer con datos del producto
              final productoId = json['producto_id'] as String;
              final producto = productosMap[productoId];

              if (producto != null) {
                json['producto_nombre'] = producto['nombre'];
                json['nombre_comercial'] = producto['nombre_comercial'];
                debugPrint('   ✅ Producto: ${producto['nombre']}');
              } else {
                debugPrint('   ⚠️ Producto no encontrado en mapa');
              }

              return StockVehiculoSupabaseModel.fromJson(json).toEntity();
            },
          )
          .toList();

      debugPrint('📦 StockDataSource: ✅ ${items.length} items de stock procesados');
      for (final item in items) {
        debugPrint('   - ${item.productoNombre ?? 'Sin nombre'}: ${item.cantidadActual} unidades');
      }

      return items;
    } catch (e, stackTrace) {
      debugPrint('📦 StockDataSource: ❌ Error al obtener stock: $e');
      debugPrint('📦 StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<StockVehiculoEntity?> getStockById(String id) async {
    try {
      final response = await _supabase
          .from('v_stock_vehiculo_estado')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return StockVehiculoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<StockVehiculoEntity> updateStock(StockVehiculoEntity stock) async {
    try {
      final model = StockVehiculoSupabaseModel.fromEntity(stock);
      final response = await _supabase
          .from('stock_vehiculo')
          .update(model.toJson())
          .eq('id', stock.id)
          .select()
          .single();

      return StockVehiculoSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al actualizar stock: $e');
      rethrow;
    }
  }

  // ========================================================================
  // MOVIMIENTOS DE STOCK
  // ========================================================================

  @override
  Future<Map<String, dynamic>> registrarMovimiento({
    required String vehiculoId,
    required String productoId,
    required String tipo,
    required int cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    String? motivo,
    String? usuarioId,
  }) async {
    try {
      debugPrint('📦 StockDataSource: Registrando movimiento de stock...');

      final response = await _supabase.rpc(
        'registrar_movimiento_stock',
        params: <String, dynamic>{
          'p_vehiculo_id': vehiculoId,
          'p_producto_id': productoId,
          'p_tipo': tipo,
          'p_cantidad': cantidad,
          'p_lote': lote,
          'p_fecha_caducidad': fechaCaducidad?.toIso8601String(),
          'p_motivo': motivo,
          'p_usuario_id': usuarioId ?? _supabase.auth.currentUser?.id,
        },
      );

      debugPrint('📦 StockDataSource: ✅ Movimiento registrado');
      return response;
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al registrar movimiento: $e');
      rethrow;
    }
  }

  /// Registra stock manual directamente en vehículo (sin pasar por almacén)
  ///
  /// Este método NO usa la función RPC, hace INSERT/UPDATE directo en stock_vehiculo.
  /// Útil para añadir stock que ya existe en la ambulancia o proviene de fuente externa.
  @override
  Future<Map<String, dynamic>> registrarStockManual({
    required String vehiculoId,
    required String productoId,
    required int cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    String? motivo,
    String? usuarioId,
  }) async {
    try {
      debugPrint('📦 StockDataSource: Registrando stock manual directo...');
      debugPrint('   - Vehículo: $vehiculoId');
      debugPrint('   - Producto: $productoId');
      debugPrint('   - Cantidad: $cantidad');
      debugPrint('   - Lote: $lote');

      // Obtener usuario actual si no se proporciona
      final userId = usuarioId ?? _supabase.auth.currentUser?.id;

      // Buscar si ya existe el producto en el vehículo con ese lote
      var query = _supabase
          .from('stock_vehiculo')
          .select('id, cantidad_actual')
          .eq('vehiculo_id', vehiculoId)
          .eq('producto_id', productoId);

      // Filtrar por lote si existe
      if (lote != null && lote.isNotEmpty) {
        query = query.eq('lote', lote);
      } else {
        query = query.isFilter('lote', null);
      }

      final existingStock = await query.maybeSingle();

      if (existingStock != null) {
        // Actualizar cantidad existente (sumar)
        final stockId = existingStock['id'] as String;
        final cantidadActual = existingStock['cantidad_actual'] as int;
        final cantidadNueva = cantidadActual + cantidad;

        debugPrint('   📝 Stock existente encontrado (ID: $stockId)');
        debugPrint('   📊 Cantidad actual: $cantidadActual → Nueva: $cantidadNueva');

        await _supabase.from('stock_vehiculo').update(<String, dynamic>{
          'cantidad_actual': cantidadNueva,
          if (fechaCaducidad != null)
            'fecha_caducidad': fechaCaducidad.toIso8601String().split('T')[0],
          'updated_at': DateTime.now().toIso8601String(),
          'updated_by': userId,
        }).eq('id', stockId);

        debugPrint('📦 StockDataSource: ✅ Stock actualizado exitosamente');

        return <String, dynamic>{
          'success': true,
          'stock_id': stockId,
          'cantidad_anterior': cantidadActual,
          'cantidad_nueva': cantidadNueva,
          'action': 'updated',
        };
      } else {
        // Crear nuevo registro
        debugPrint('   ➕ Creando nuevo registro de stock...');

        final response = await _supabase.from('stock_vehiculo').insert(<String, dynamic>{
          'vehiculo_id': vehiculoId,
          'producto_id': productoId,
          'cantidad_actual': cantidad,
          if (lote != null && lote.isNotEmpty) 'lote': lote,
          if (fechaCaducidad != null)
            'fecha_caducidad': fechaCaducidad.toIso8601String().split('T')[0],
          'updated_by': userId,
        }).select('id').single();

        final stockId = response['id'] as String;

        debugPrint('📦 StockDataSource: ✅ Stock creado exitosamente (ID: $stockId)');

        return <String, dynamic>{
          'success': true,
          'stock_id': stockId,
          'cantidad_anterior': 0,
          'cantidad_nueva': cantidad,
          'action': 'created',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('📦 StockDataSource: ❌ Error al registrar stock manual: $e');
      debugPrint('📦 StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<MovimientoStockEntity>> getHistorialMovimientos({
    String? vehiculoId,
    String? productoId,
    DateTime? desde,
    DateTime? hasta,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('movimientos_stock')
          .select('*, productos(nombre), tvehiculos(matricula)');

      if (vehiculoId != null) {
        query = query.eq('vehiculo_id', vehiculoId);
      }
      if (productoId != null) {
        query = query.eq('producto_id', productoId);
      }
      if (desde != null) {
        query = query.gte('created_at', desde.toIso8601String());
      }
      if (hasta != null) {
        query = query.lte('created_at', hasta.toIso8601String());
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return (response)
          .map(
            (json) => MovimientoStockSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  // ========================================================================
  // ALERTAS
  // ========================================================================

  @override
  Future<List<AlertaStockEntity>> getAlertasVehiculo(String vehiculoId) async {
    try {
      final response = await _supabase
          .from('alertas_stock')
          .select('*, productos(nombre), tvehiculos(matricula)')
          .eq('vehiculo_id', vehiculoId)
          .eq('resuelta', false)
          .order('nivel', ascending: false)
          .order('created_at', ascending: false);

      return (response)
          .map(
            (json) => AlertaStockSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AlertaStockEntity>> getAlertasActivas() async {
    try {
      final response = await _supabase
          .from('alertas_stock')
          .select('*, productos(nombre), tvehiculos(matricula)')
          .eq('resuelta', false)
          .order('nivel', ascending: false)
          .order('created_at', ascending: false);

      return (response)
          .map(
            (json) => AlertaStockSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resolverAlerta(String alertaId, String usuarioId) async {
    try {
      await _supabase.from('alertas_stock').update(<String, dynamic>{
        'resuelta': true,
        'resuelta_por': usuarioId,
        'resuelta_at': DateTime.now().toIso8601String(),
      }).eq('id', alertaId);

      debugPrint('📦 StockDataSource: ✅ Alerta resuelta');
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al resolver alerta: $e');
      rethrow;
    }
  }

  @override
  Future<void> generarAlertas() async {
    try {
      debugPrint('📦 StockDataSource: Generando alertas automáticas...');
      await _supabase.rpc('generar_alertas_stock');
      debugPrint('📦 StockDataSource: ✅ Alertas generadas');
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al generar alertas: $e');
      rethrow;
    }
  }

  // ========================================================================
  // REVISIONES MENSUALES
  // ========================================================================

  @override
  Future<List<RevisionMensualEntity>> getRevisionesVehiculo(
    String vehiculoId,
  ) async {
    try {
      final response = await _supabase
          .from('revisiones_mensuales')
          .select()
          .eq('vehiculo_id', vehiculoId)
          .order('fecha', ascending: false);

      return (response)
          .map(
            (json) => RevisionMensualSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<RevisionMensualEntity?> getRevisionById(String id) async {
    try {
      final response = await _supabase
          .from('revisiones_mensuales')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return RevisionMensualSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<RevisionMensualEntity> createRevision(
    RevisionMensualEntity revision,
  ) async {
    try {
      final model = RevisionMensualSupabaseModel.fromEntity(revision);
      final response = await _supabase
          .from('revisiones_mensuales')
          .insert(model.toJson())
          .select()
          .single();

      return RevisionMensualSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al crear revisión: $e');
      rethrow;
    }
  }

  @override
  Future<RevisionMensualEntity> updateRevision(
    RevisionMensualEntity revision,
  ) async {
    try {
      final model = RevisionMensualSupabaseModel.fromEntity(revision);
      final response = await _supabase
          .from('revisiones_mensuales')
          .update(model.toJson())
          .eq('id', revision.id)
          .select()
          .single();

      return RevisionMensualSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al actualizar revisión: $e');
      rethrow;
    }
  }

  @override
  Future<RevisionMensualEntity> completarRevision(
    String revisionId,
    String? firmaBase64,
    String? observaciones,
  ) async {
    try {
      final response = await _supabase
          .from('revisiones_mensuales')
          .update(<String, dynamic>{
        'completada': true,
        'firma_base64': firmaBase64,
        'observaciones_generales': observaciones,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', revisionId).select().single();

      return RevisionMensualSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error al completar revisión: $e');
      rethrow;
    }
  }

  // ========================================================================
  // ITEMS DE REVISIÓN
  // ========================================================================

  @override
  Future<List<ItemRevisionEntity>> getItemsRevision(String revisionId) async {
    try {
      final response = await _supabase
          .from('items_revision')
          .select()
          .eq('revision_id', revisionId)
          .order('created_at');

      return (response)
          .map(
            (json) => ItemRevisionSupabaseModel.fromJson(
              json,
            ).toEntity(),
          )
          .toList();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ItemRevisionEntity> updateItemRevision(ItemRevisionEntity item) async {
    try {
      final model = ItemRevisionSupabaseModel.fromEntity(item);
      final response = await _supabase
          .from('items_revision')
          .update(model.toJson())
          .eq('id', item.id)
          .select()
          .single();

      return ItemRevisionSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }

  @override
  Future<ItemRevisionEntity> verificarItem(
    String itemId,
    int cantidadEncontrada,
    bool caducidadOk,
    String estado,
    String? observacion,
  ) async {
    try {
      final response = await _supabase.from('items_revision').update(<String, dynamic>{
        'verificado': true,
        'cantidad_encontrada': cantidadEncontrada,
        'caducidad_ok': caducidadOk,
        'estado': estado,
        'observacion': observacion,
      }).eq('id', itemId).select().single();

      return ItemRevisionSupabaseModel.fromJson(
        response,
      ).toEntity();
    } catch (e) {
      debugPrint('📦 StockDataSource: ❌ Error: $e');
      rethrow;
    }
  }
}
