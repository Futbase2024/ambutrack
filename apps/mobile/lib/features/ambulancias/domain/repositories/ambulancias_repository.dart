import 'package:ambutrack_core/ambutrack_core.dart';

/// Contrato del repositorio de ambulancias y revisiones
/// Siguiendo el patrón pass-through, este repositorio simplemente delega al datasource
abstract class AmbulanciasRepository {
  // ==========================================
  // TIPOS DE AMBULANCIA
  // ==========================================

  /// Obtiene todos los tipos de ambulancia disponibles
  Future<List<TipoAmbulanciaEntity>> getTiposAmbulancia();

  /// Obtiene un tipo de ambulancia por ID
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaById(String id);

  /// Obtiene un tipo de ambulancia por código (A1, A2, B, C, A1EE)
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaByCodigo(String codigo);

  // ==========================================
  // AMBULANCIAS
  // ==========================================

  /// Obtiene todas las ambulancias
  Future<List<AmbulanciaEntity>> getAll();

  /// Obtiene una ambulancia por ID
  Future<AmbulanciaEntity?> getById(String id);

  /// Busca ambulancias por matrícula (búsqueda parcial)
  Future<List<AmbulanciaEntity>> searchByMatricula(String matricula);

  /// Obtiene ambulancias filtradas por estado
  Future<List<AmbulanciaEntity>> getAmbulanciasByEstado(EstadoAmbulancia estado);

  /// Obtiene ambulancias de una empresa específica
  Future<List<AmbulanciaEntity>> getAmbulanciasByEmpresa(
    String empresaId, {
    bool incluirTipo = true,
  });

  /// Obtiene una ambulancia con todas sus relaciones
  Future<AmbulanciaEntity?> getAmbulanciaWithRelations(
    String id, {
    bool incluirTipo = true,
  });

  /// Crea una nueva ambulancia
  Future<AmbulanciaEntity> create(AmbulanciaEntity ambulancia);

  /// Actualiza una ambulancia existente
  Future<AmbulanciaEntity> update(AmbulanciaEntity ambulancia);

  /// Elimina una ambulancia
  Future<void> delete(String id);

  // ==========================================
  // REVISIONES
  // ==========================================

  /// Obtiene las revisiones de una ambulancia específica
  Future<List<RevisionEntity>> getRevisionesByAmbulancia(
    String ambulanciaId, {
    EstadoRevision? estado,
    bool incluirItems = false,
  });

  /// Obtiene una revisión con todas sus relaciones
  Future<RevisionEntity?> getRevisionWithRelations(
    String id, {
    bool incluirAmbulancia = true,
    bool incluirItems = true,
  });

  /// Crea una nueva revisión
  Future<RevisionEntity> createRevision(RevisionEntity revision);

  /// Actualiza una revisión existente
  Future<RevisionEntity> updateRevision(RevisionEntity revision);

  /// Marca una revisión como completada
  Future<RevisionEntity> completarRevision(
    String revisionId, {
    String? observaciones,
  });

  /// Obtiene las revisiones pendientes de una ambulancia
  Future<List<RevisionEntity>> getRevisionesPendientes(String ambulanciaId);

  // ==========================================
  // ITEMS DE REVISIÓN
  // ==========================================

  /// Obtiene los items de una revisión específica
  Future<List<ItemRevisionEntity>> getItemsByRevision(String revisionId);

  /// Obtiene un item de revisión por ID
  Future<ItemRevisionEntity?> getItemRevisionById(String id);

  /// Actualiza un item de revisión
  Future<ItemRevisionEntity> updateItemRevision(ItemRevisionEntity item);

  /// Actualiza múltiples items en lote
  Future<List<ItemRevisionEntity>> updateItemsRevisionBatch(
    List<ItemRevisionEntity> items,
  );

  /// Marca un item como verificado
  Future<ItemRevisionEntity> marcarItemComoVerificado(
    String itemId, {
    required bool conforme,
    int? cantidadEncontrada,
    String? observaciones,
    DateTime? fechaCaducidad,
    String? verificadoPor,
  });

  // ==========================================
  // GENERACIÓN AUTOMÁTICA
  // ==========================================

  /// Genera las revisiones del mes para una ambulancia
  Future<void> generarRevisionesMes(
    String ambulanciaId,
    int mes,
    int anio,
  );

  /// Genera los items de una revisión basándose en el tipo de ambulancia
  Future<void> generarItemsRevision(String revisionId);
}
