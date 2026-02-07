import 'package:flutter/foundation.dart';

import 'package:ambutrack_core/ambutrack_core.dart';
import '../../domain/repositories/ambulancias_repository.dart';

/// Implementación del repositorio de ambulancias y revisiones
/// Patrón pass-through: delega directamente al datasource sin conversiones
class AmbulanciasRepositoryImpl implements AmbulanciasRepository {
  AmbulanciasRepositoryImpl()
      : _dataSource = AmbulanciasRevisionesDataSourceFactory.createSupabase();

  final AmbulanciasRevisionesDataSource _dataSource;

  // ==========================================
  // TIPOS DE AMBULANCIA
  // ==========================================

  @override
  Future<List<TipoAmbulanciaEntity>> getTiposAmbulancia() async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando tipos de ambulancia');
    return await _dataSource.getTiposAmbulancia();
  }

  @override
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaById(String id) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando tipo de ambulancia: $id');
    return await _dataSource.getTipoAmbulanciaById(id);
  }

  @override
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaByCodigo(String codigo) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando tipo de ambulancia por código: $codigo');
    return await _dataSource.getTipoAmbulanciaByCodigo(codigo);
  }

  // ==========================================
  // AMBULANCIAS
  // ==========================================

  @override
  Future<List<AmbulanciaEntity>> getAll() async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando todas las ambulancias');
    return await _dataSource.getAll();
  }

  @override
  Future<AmbulanciaEntity?> getById(String id) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando ambulancia: $id');
    return await _dataSource.getById(id);
  }

  @override
  Future<List<AmbulanciaEntity>> searchByMatricula(String matricula) async {
    debugPrint('📦 [AmbulanciasRepository] Buscando ambulancias por matrícula: $matricula');
    return await _dataSource.searchByMatricula(matricula);
  }

  @override
  Future<List<AmbulanciaEntity>> getAmbulanciasByEstado(
      EstadoAmbulancia estado) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando ambulancias por estado: ${estado.nombre}');
    return await _dataSource.getAmbulanciasByEstado(estado);
  }

  @override
  Future<List<AmbulanciaEntity>> getAmbulanciasByEmpresa(
    String empresaId, {
    bool incluirTipo = true,
  }) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando ambulancias de empresa: $empresaId');
    return await _dataSource.getAmbulanciasByEmpresa(
      empresaId,
      incluirTipo: incluirTipo,
    );
  }

  @override
  Future<AmbulanciaEntity?> getAmbulanciaWithRelations(
    String id, {
    bool incluirTipo = true,
  }) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando ambulancia con relaciones: $id');
    return await _dataSource.getAmbulanciaWithRelations(
      id,
      incluirTipo: incluirTipo,
    );
  }

  @override
  Future<AmbulanciaEntity> create(AmbulanciaEntity ambulancia) async {
    debugPrint('📦 [AmbulanciasRepository] Creando ambulancia: ${ambulancia.matricula}');
    return await _dataSource.create(ambulancia);
  }

  @override
  Future<AmbulanciaEntity> update(AmbulanciaEntity ambulancia) async {
    debugPrint('📦 [AmbulanciasRepository] Actualizando ambulancia: ${ambulancia.id}');
    return await _dataSource.update(ambulancia);
  }

  @override
  Future<void> delete(String id) async {
    debugPrint('📦 [AmbulanciasRepository] Eliminando ambulancia: $id');
    return await _dataSource.delete(id);
  }

  // ==========================================
  // REVISIONES
  // ==========================================

  @override
  Future<List<RevisionEntity>> getRevisionesByAmbulancia(
    String ambulanciaId, {
    EstadoRevision? estado,
    bool incluirItems = false,
  }) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando revisiones de ambulancia: $ambulanciaId');
    return await _dataSource.getRevisionesByAmbulancia(
      ambulanciaId,
      estado: estado,
      incluirItems: incluirItems,
    );
  }

  @override
  Future<RevisionEntity?> getRevisionWithRelations(
    String id, {
    bool incluirAmbulancia = true,
    bool incluirItems = true,
  }) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando revisión con relaciones: $id');
    return await _dataSource.getRevisionWithRelations(
      id,
      incluirAmbulancia: incluirAmbulancia,
      incluirItems: incluirItems,
    );
  }

  @override
  Future<RevisionEntity> createRevision(RevisionEntity revision) async {
    debugPrint('📦 [AmbulanciasRepository] Creando revisión: ${revision.periodo}');
    return await _dataSource.createRevision(revision);
  }

  @override
  Future<RevisionEntity> updateRevision(RevisionEntity revision) async {
    debugPrint('📦 [AmbulanciasRepository] Actualizando revisión: ${revision.id}');
    return await _dataSource.updateRevision(revision);
  }

  @override
  Future<RevisionEntity> completarRevision(
    String revisionId, {
    String? observaciones,
  }) async {
    debugPrint('📦 [AmbulanciasRepository] Completando revisión: $revisionId');
    return await _dataSource.completarRevision(
      revisionId,
      observaciones: observaciones,
    );
  }

  @override
  Future<List<RevisionEntity>> getRevisionesPendientes(
      String ambulanciaId) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando revisiones pendientes: $ambulanciaId');
    return await _dataSource.getRevisionesPendientes(ambulanciaId);
  }

  // ==========================================
  // ITEMS DE REVISIÓN
  // ==========================================

  @override
  Future<List<ItemRevisionEntity>> getItemsByRevision(String revisionId) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando items de revisión: $revisionId');
    return await _dataSource.getItemsByRevision(revisionId);
  }

  @override
  Future<ItemRevisionEntity?> getItemRevisionById(String id) async {
    debugPrint('📦 [AmbulanciasRepository] Solicitando item de revisión: $id');
    return await _dataSource.getItemRevisionById(id);
  }

  @override
  Future<ItemRevisionEntity> updateItemRevision(ItemRevisionEntity item) async {
    debugPrint('📦 [AmbulanciasRepository] Actualizando item de revisión: ${item.id}');
    return await _dataSource.updateItemRevision(item);
  }

  @override
  Future<List<ItemRevisionEntity>> updateItemsRevisionBatch(
    List<ItemRevisionEntity> items,
  ) async {
    debugPrint('📦 [AmbulanciasRepository] Actualizando ${items.length} items en lote');
    return await _dataSource.updateItemsRevisionBatch(items);
  }

  @override
  Future<ItemRevisionEntity> marcarItemComoVerificado(
    String itemId, {
    required bool conforme,
    int? cantidadEncontrada,
    String? observaciones,
    DateTime? fechaCaducidad,
    String? verificadoPor,
  }) async {
    debugPrint('📦 [AmbulanciasRepository] Marcando item como verificado: $itemId (conforme: $conforme)');
    return await _dataSource.marcarItemComoVerificado(
      itemId,
      conforme: conforme,
      cantidadEncontrada: cantidadEncontrada,
      observaciones: observaciones,
      fechaCaducidad: fechaCaducidad,
      verificadoPor: verificadoPor,
    );
  }

  // ==========================================
  // GENERACIÓN AUTOMÁTICA
  // ==========================================

  @override
  Future<void> generarRevisionesMes(
    String ambulanciaId,
    int mes,
    int anio,
  ) async {
    debugPrint('📦 [AmbulanciasRepository] Generando revisiones del mes $mes/$anio');
    return await _dataSource.generarRevisionesMes(ambulanciaId, mes, anio);
  }

  @override
  Future<void> generarItemsRevision(String revisionId) async {
    debugPrint('📦 [AmbulanciasRepository] Generando items para revisión: $revisionId');
    return await _dataSource.generarItemsRevision(revisionId);
  }
}
