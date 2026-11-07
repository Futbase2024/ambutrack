/// Módulos de la aplicación AmbuTrack
///
/// Define todos los módulos disponibles para control de permisos por rol.
enum AppModule {
  // === MÓDULOS GENERALES ===
  /// Dashboard principal
  dashboard('dashboard', 'Dashboard', '/'),

  /// Configuración del usuario
  miPerfil('mi_perfil', 'Mi Perfil', '/perfil'),

  // === PERSONAL ===
  /// Gestión completa de personal
  personal('personal', 'Personal', '/personal'),

  /// Formación y certificaciones
  formacion('formacion', 'Formación', '/personal/formacion'),

  /// Documentación del personal
  documentacionPersonal('documentacion_personal', 'Documentación', '/personal/documentacion'),

  /// Ausencias y vacaciones
  ausencias('ausencias', 'Ausencias', '/personal/ausencias'),

  /// Vacaciones
  vacaciones('vacaciones', 'Vacaciones', '/personal/vacaciones'),

  /// Evaluaciones de desempeño
  evaluaciones('evaluaciones', 'Evaluaciones', '/personal/evaluaciones'),

  /// Historial médico
  historialMedico('historial_medico', 'Historial Médico', '/personal/historial-medico'),

  /// Equipamiento del personal
  equipamientoPersonal('equipamiento_personal', 'Equipamiento', '/personal/equipamiento'),

  // === TURNOS Y CUADRANTES ===
  /// Horarios y turnos
  turnos('turnos', 'Turnos', '/cuadrante/horarios'),

  /// Cuadrante de personal
  cuadrantes('cuadrantes', 'Cuadrantes', '/personal/cuadrante'),

  /// Plantillas de turnos
  plantillasTurnos('plantillas_turnos', 'Plantillas Turnos', '/personal/plantillas-turnos'),

  /// Dotaciones
  dotaciones('dotaciones', 'Dotaciones', '/cuadrante/dotaciones'),

  /// Asignaciones
  asignaciones('asignaciones', 'Asignaciones', '/cuadrante/asignaciones'),

  // === BASES ===
  /// Bases
  bases('bases', 'Bases', '/cuadrante/bases'),

  // === VEHÍCULOS ===
  /// Gestión de vehículos
  vehiculos('vehiculos', 'Vehículos', '/vehiculos'),

  /// Mantenimiento preventivo
  mantenimiento('mantenimiento', 'Mantenimiento', '/flota/mantenimiento-preventivo'),

  /// ITV y revisiones
  itv('itv', 'ITV', '/flota/itv-revisiones'),

  /// Documentación de vehículos
  documentacionVehiculos('documentacion_vehiculos', 'Documentación', '/flota/documentacion'),

  /// Geolocalización
  geolocalizacion('geolocalizacion', 'Geolocalización', '/flota/geolocalizacion'),

  /// Consumo y km
  consumoKm('consumo_km', 'Consumo/Km', '/flota/consumo-km'),

  /// Historial de averías
  historialAverias('historial_averias', 'Averías', '/flota/historial-averias'),

  /// Stock de equipamiento
  stockEquipamiento('stock_equipamiento', 'Stock', '/flota/stock-equipamiento'),

  // === SERVICIOS ===
  /// Gestión de servicios
  servicios('servicios', 'Servicios', '/servicios'),

  /// Pacientes
  pacientes('pacientes', 'Pacientes', '/servicios/pacientes'),

  /// Servicios urgentes
  urgentes('urgentes', 'Urgentes', '/servicios/urgentes'),

  /// Planificación de servicios
  planificar('planificar', 'Planificar', '/servicios/planificar'),

  /// Histórico de servicios
  historico('historico', 'Histórico', '/servicios/historico'),

  // === OPERACIONES ===
  /// Operaciones en tiempo real
  operaciones('operaciones', 'Operaciones', '/operaciones'),

  /// Incidencias
  incidencias('incidencias', 'Incidencias', '/operaciones/incidencias'),

  /// Comunicaciones
  comunicaciones('comunicaciones', 'Comunicaciones', '/operaciones/comunicaciones'),

  // === INFORMES ===
  /// Reportes de personal
  reportesPersonal('reportes_personal', 'Reportes Personal', '/informes/personal'),

  /// Reportes de servicios
  reportesServicios('reportes_servicios', 'Reportes Servicios', '/informes/servicios-realizados'),

  /// Estadísticas de flota
  estadisticasFlota('estadisticas_flota', 'Estadísticas Flota', '/informes/estadisticas-flota'),

  /// Indicadores de calidad
  indicadoresCalidad('indicadores_calidad', 'Indicadores', '/informes/indicadores-calidad'),

  // === TABLAS MAESTRAS ===
  /// Centros hospitalarios
  centrosHospitalarios('centros_hospitalarios', 'Centros', '/tablas/centros-hospitalarios'),

  /// Motivos de traslado
  motivosTraslado('motivos_traslado', 'Motivos Traslado', '/tablas/motivos-traslado'),

  /// Tipos de traslado
  tiposTraslado('tipos_traslado', 'Tipos Traslado', '/tablas/tipos-traslado'),

  /// Localidades
  localidades('localidades', 'Localidades', '/tablas/localidades'),

  /// Provincias
  provincias('provincias', 'Provincias', '/tablas/provincias'),

  // === ADMINISTRACIÓN ===
  /// Contratos
  contratos('contratos', 'Contratos', '/administracion/contratos'),

  /// Usuarios y roles
  usuariosRoles('usuarios_roles', 'Usuarios', '/administracion/usuarios-roles'),

  /// Permisos de acceso
  permisosAcceso('permisos_acceso', 'Permisos', '/administracion/permisos-acceso'),

  /// Auditorías
  auditorias('auditorias', 'Auditorías', '/administracion/auditorias-logs'),

  /// Configuración general
  configuracionGeneral('configuracion_general', 'Configuración', '/administracion/configuracion-general'),

  // === MÓDULOS PROPIOS (para conductor/sanitario) ===
  /// Mis turnos
  misTurnos('mis_turnos', 'Mis Turnos', '/mis-turnos'),

  /// Mis servicios
  misServicios('mis_servicios', 'Mis Servicios', '/mis-servicios'),

  /// Mis ausencias
  misAusencias('mis_ausencias', 'Mis Ausencias', '/mis-ausencias'),

  // === CALENDARIO ===
  /// Calendario
  calendario('calendario', 'Calendario', '/calendario');

  const AppModule(this.value, this.label, this.route);

  /// Valor del módulo (usado en permisos)
  final String value;

  /// Etiqueta del módulo (UI)
  final String label;

  /// Ruta del módulo
  final String route;

  /// Crea un AppModule desde un string
  static AppModule? fromString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return AppModule.values.firstWhere(
        (AppModule module) => module.value == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => value;
}
