import 'entities/ambulancia_entity.dart';
import 'entities/item_revision_entity.dart';
import 'entities/revision_entity.dart';
import 'entities/tipo_ambulancia_entity.dart';

/// Contrato para operaciones de datasource de ambulancias y revisiones
///
/// Proporciona métodos para gestionar ambulancias, revisiones y sus items
abstract class AmbulanciasRevisionesDataSource {
  // ==========================================
  // OPERACIONES CRUD DE AMBULANCIAS
  // ==========================================

  /// Obtiene todas las ambulancias
  Future<List<AmbulanciaEntity>> getAll();

  /// Obtiene una ambulancia por ID
  Future<AmbulanciaEntity?> getById(String id);

  /// Crea una nueva ambulancia
  Future<AmbulanciaEntity> create(AmbulanciaEntity entity);

  /// Actualiza una ambulancia existente
  Future<AmbulanciaEntity> update(AmbulanciaEntity entity);

  /// Elimina una ambulancia
  Future<void> delete(String id);

  // ==========================================
  // OPERACIONES DE TIPOS DE AMBULANCIA
  // ==========================================

  /// Obtiene todos los tipos de ambulancia disponibles
  Future<List<TipoAmbulanciaEntity>> getTiposAmbulancia();

  /// Obtiene un tipo de ambulancia por su ID
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaById(String id);

  /// Obtiene un tipo de ambulancia por su código (A1, A2, B, C, A1EE)
  Future<TipoAmbulanciaEntity?> getTipoAmbulanciaByCodigo(String codigo);

  // ==========================================
  // OPERACIONES DE AMBULANCIAS
  // ==========================================

  /// Busca ambulancias por matrícula (búsqueda parcial)
  ///
  /// [matricula] - Matrícula a buscar (permite búsqueda parcial)
  /// Devuelve lista de ambulancias que coinciden
  Future<List<AmbulanciaEntity>> searchByMatricula(String matricula);

  /// Obtiene ambulancias por estado
  ///
  /// [estado] - Estado de la ambulancia (activa, mantenimiento, baja)
  /// Devuelve lista de ambulancias que coinciden con el estado
  Future<List<AmbulanciaEntity>> getAmbulanciasByEstado(EstadoAmbulancia estado);

  /// Obtiene ambulancias por empresa con relaciones cargadas
  ///
  /// [empresaId] - ID de la empresa
  /// [incluirTipo] - Si incluir la relación con tipo de ambulancia
  /// Devuelve lista de ambulancias de la empresa
  Future<List<AmbulanciaEntity>> getAmbulanciasByEmpresa(
    String empresaId, {
    bool incluirTipo = true,
  });

  /// Obtiene una ambulancia por ID con relaciones
  ///
  /// [id] - ID de la ambulancia
  /// [incluirTipo] - Si incluir la relación con tipo de ambulancia
  Future<AmbulanciaEntity?> getAmbulanciaWithRelations(
    String id, {
    bool incluirTipo = true,
  });

  // ==========================================
  // OPERACIONES DE REVISIONES
  // ==========================================

  /// Obtiene revisiones de una ambulancia
  ///
  /// [ambulanciaId] - ID de la ambulancia
  /// [estado] - Filtro opcional por estado
  /// [incluirItems] - Si incluir los items de cada revisión
  /// Devuelve lista de revisiones
  Future<List<RevisionEntity>> getRevisionesByAmbulancia(
    String ambulanciaId, {
    EstadoRevision? estado,
    bool incluirItems = false,
  });

  /// Obtiene una revisión por ID con todas sus relaciones
  ///
  /// [id] - ID de la revisión
  /// [incluirAmbulancia] - Si incluir la ambulancia
  /// [incluirItems] - Si incluir los items de revisión
  /// Devuelve la revisión con sus relaciones
  Future<RevisionEntity?> getRevisionWithRelations(
    String id, {
    bool incluirAmbulancia = true,
    bool incluirItems = true,
  });

  /// Crea una nueva revisión
  ///
  /// [revision] - Entity de la revisión a crear
  /// Devuelve la revisión creada con ID generado
  Future<RevisionEntity> createRevision(RevisionEntity revision);

  /// Actualiza una revisión existente
  ///
  /// [revision] - Entity de la revisión a actualizar
  /// Devuelve la revisión actualizada
  Future<RevisionEntity> updateRevision(RevisionEntity revision);

  /// Marca una revisión como completada
  ///
  /// [revisionId] - ID de la revisión
  /// [observaciones] - Observaciones finales
  /// Devuelve la revisión actualizada
  Future<RevisionEntity> completarRevision(
    String revisionId, {
    String? observaciones,
  });

  /// Obtiene revisiones pendientes de una ambulancia
  ///
  /// [ambulanciaId] - ID de la ambulancia
  /// Devuelve lista de revisiones pendientes o en progreso
  Future<List<RevisionEntity>> getRevisionesPendientes(String ambulanciaId);

  // ==========================================
  // OPERACIONES DE ITEMS DE REVISIÓN
  // ==========================================

  /// Obtiene items de una revisión
  ///
  /// [revisionId] - ID de la revisión
  /// Devuelve lista de items de la revisión
  Future<List<ItemRevisionEntity>> getItemsByRevision(String revisionId);

  /// Obtiene un item de revisión por ID
  ///
  /// [id] - ID del item
  Future<ItemRevisionEntity?> getItemRevisionById(String id);

  /// Actualiza un item de revisión
  ///
  /// [item] - Entity del item a actualizar
  /// Devuelve el item actualizado
  Future<ItemRevisionEntity> updateItemRevision(ItemRevisionEntity item);

  /// Actualiza múltiples items de revisión
  ///
  /// [items] - Lista de items a actualizar
  /// Devuelve lista de items actualizados
  Future<List<ItemRevisionEntity>> updateItemsRevisionBatch(
    List<ItemRevisionEntity> items,
  );

  /// Marca un item como verificado
  ///
  /// [itemId] - ID del item
  /// [conforme] - Si el item está conforme o no
  /// [cantidadEncontrada] - Cantidad encontrada
  /// [observaciones] - Observaciones opcionales
  /// [fechaCaducidad] - Fecha de caducidad si aplica
  /// [verificadoPor] - ID del usuario que verificó
  /// Devuelve el item actualizado
  Future<ItemRevisionEntity> marcarItemComoVerificado(
    String itemId, {
    required bool conforme,
    int? cantidadEncontrada,
    String? observaciones,
    DateTime? fechaCaducidad,
    String? verificadoPor,
  });

  // ==========================================
  // OPERACIONES DE GENERACIÓN AUTOMÁTICA
  // ==========================================

  /// Genera revisiones mensuales para una ambulancia
  ///
  /// [ambulanciaId] - ID de la ambulancia
  /// [mes] - Mes (1-12)
  /// [anio] - Año
  /// Crea las 3 revisiones del mes (Día 1, 2, 3)
  Future<void> generarRevisionesMes(
    String ambulanciaId,
    int mes,
    int anio,
  );

  /// Genera items para una revisión basándose en el catálogo
  ///
  /// [revisionId] - ID de la revisión
  /// Crea todos los items según el tipo de ambulancia y día de revisión
  Future<void> generarItemsRevision(String revisionId);
}
