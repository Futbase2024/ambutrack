import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../entities/documentacion_vehiculo_entity.dart';
import '../../models/documentacion_vehiculo_supabase_model.dart';
import '../../documentacion_vehiculo_datasource_contract.dart';

/// Implementación de Supabase para Documentación de Vehículos
@immutable
class SupabaseDocumentacionVehiculoDataSource
    implements DocumentacionVehiculoDataSource {
  const SupabaseDocumentacionVehiculoDataSource(this._client);

  final SupabaseClient _client;
  static const String _tableName = 'ambutrack_documentacion_vehiculos';

  @override
  Future<List<DocumentacionVehiculoEntity>> getAll() async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo todos...');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .order('fecha_vencimiento', ascending: true);

    debugPrint('📡 Response: ${response.toString()}');

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<DocumentacionVehiculoEntity?> getById(String id) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo id=$id');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return DocumentacionVehiculoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getByVehiculo(
      String vehiculoId) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo por vehículo=$vehiculoId');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .eq('vehiculo_id', vehiculoId)
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getByTipoDocumento(
      String tipoDocumentoId) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo por tipo=$tipoDocumentoId');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .eq('tipo_documento_id', tipoDocumentoId)
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getByEstado(String estado) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo por estado=$estado');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .eq('estado', estado)
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getProximosAVencer() async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo próximos a vencer...');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .inFilter('estado', ['proxima_vencer', 'vencida'])
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> getVencidos() async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Obteniendo vencidos...');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .eq('estado', 'vencida')
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<DocumentacionVehiculoEntity> create(
      DocumentacionVehiculoEntity entity) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Creando...');

    final model = DocumentacionVehiculoSupabaseModel.fromEntity(entity);
    final response = await _client
        .from(_tableName)
        .insert(model.toJson())
        .select()
        .single();

    return DocumentacionVehiculoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<DocumentacionVehiculoEntity> update(
      DocumentacionVehiculoEntity entity) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Actualizando id=${entity.id}');

    final model = DocumentacionVehiculoSupabaseModel.fromEntity(entity);
    final response = await _client
        .from(_tableName)
        .update(model.toJson())
        .eq('id', entity.id)
        .select()
        .single();

    return DocumentacionVehiculoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Eliminando id=$id');

    await _client.from(_tableName).delete().eq('id', id);
  }

  @override
  Future<DocumentacionVehiculoEntity> actualizarEstado(String id) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Actualizando estado id=$id');

    // Obtener el documento actual
    final current = await getById(id);
    if (current == null) {
      throw Exception('Documento no encontrado');
    }

    // El trigger de Supabase calculará el estado automáticamente
    final response = await _client
        .from(_tableName)
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();

    return DocumentacionVehiculoSupabaseModel.fromJson(response).toEntity();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> buscarPorPoliza(
      String numeroPoliza) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Buscando póliza=$numeroPoliza');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .ilike('numero_poliza', '%$numeroPoliza%')
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<DocumentacionVehiculoEntity>> buscarPorCompania(
      String compania) async {
    debugPrint('📡 SupabaseDocumentacionVehiculo: Buscando compañía=$compania');

    final response = await _client
        .from(_tableName)
        .select('''
          *,
          vehiculo:tvehiculos!inner(id, matricula, marca, modelo),
          tipo_documento:ambutrack_tipos_documento_vehiculo!inner(id, nombre, categoria, codigo)
        ''')
        .ilike('compania', '%$compania%')
        .order('fecha_vencimiento', ascending: true);

    return (response as List)
        .map((json) =>
            DocumentacionVehiculoSupabaseModel.fromJson(json).toEntity())
        .toList();
  }
}
