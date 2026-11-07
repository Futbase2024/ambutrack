/// Strings localizados de la aplicación AmbuTrack
///
/// TEMPORAL: Esta clase provee acceso a strings localizados hasta que
/// se reactive easy_localization (actualmente deshabilitado por conflicto con design system).
// TODO(team): Migrar a context.tr() cuando easy_localization esté disponible.
class AppStrings {
  AppStrings._();

  // === COMÚN ===

  static const String guardar = 'Guardar';
  static const String cancelar = 'Cancelar';
  static const String eliminar = 'Eliminar';
  static const String editar = 'Editar';
  static const String agregar = 'Agregar';
  static const String buscar = 'Buscar';
  static const String filtros = 'Filtros';
  static const String reintentar = 'Reintentar';
  static const String aceptar = 'Aceptar';

  // === VEHÍCULOS ===

  static const String vehiculosTitulo = 'Gestión de Vehículos';
  static const String vehiculosSubtitulo =
      'Administra tu flota de ambulancias y vehículos de emergencia';
  static const String vehiculosAgregar = 'Nuevo Vehículo';
  static const String vehiculosListaTitulo = 'Lista de Vehículos';

  // Stats
  static const String vehiculosStatsTotal = 'Total Vehículos';
  static const String vehiculosStatsDisponibles = 'Disponibles';
  static const String vehiculosStatsEnServicio = 'En Servicio';
  static const String vehiculosStatsMantenimiento = 'Mantenimiento';

  // Estados
  static const String vehiculosEstadoDisponible = 'Disponible';
  static const String vehiculosEstadoMantenimiento = 'Mantenimiento';
  static const String vehiculosEstadoReparacion = 'En Reparación';
  static const String vehiculosEstadoBaja = 'Baja';

  // Mensajes
  static const String vehiculosErrorCarga = 'Error al cargar vehículos';
  static const String vehiculosListaVacia = 'No hay vehículos registrados';
  static const String vehiculosListaVaciaDescripcion =
      'Agrega tu primer vehículo para comenzar';

  // Formulario
  static const String vehiculosFormMatriculaLabel = 'Matrícula';
  static const String vehiculosFormMatriculaHint = 'Ej: ABC-1234';
  static const String vehiculosFormMarcaLabel = 'Marca';
  static const String vehiculosFormMarcaHint = 'Ej: Mercedes-Benz';
  static const String vehiculosFormModeloLabel = 'Modelo';
  static const String vehiculosFormModeloHint = 'Ej: Sprinter';
  static const String vehiculosFormTipoLabel = 'Tipo de Vehículo';
  static const String vehiculosFormTipoHint = 'Selecciona el tipo';
  static const String vehiculosFormEstadoLabel = 'Estado';
  static const String vehiculosFormKmLabel = 'Kilómetros Actuales';
  static const String vehiculosFormKmHint = 'Ej: 50000';
  static const String vehiculosFormUbicacionLabel = 'Ubicación Actual';
  static const String vehiculosFormUbicacionHint = 'Ej: Base Central';

  // === PERSONAL ===

  static const String personalListaTitulo = 'Lista de Personal';
  static const String personalListaVacia = 'No hay personal registrado';
  static const String personalListaVaciaDescripcion = 'Agrega tu primer integrante para comenzar';
}
