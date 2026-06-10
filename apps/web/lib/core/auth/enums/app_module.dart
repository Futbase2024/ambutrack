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

  /// Agenda de Pendientes
  agendaPendientes('agenda_pendientes', 'Agenda Pendientes', '/servicios/agenda-pendientes'),

  // === OPERACIONES ===
  /// Operaciones en tiempo real
  operaciones('operaciones', 'Operaciones', '/operaciones'),

  /// Incidencias
  incidencias('incidencias', 'Incidencias', '/administracion/incidencias'),

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

  /// Satisfacción del paciente
  reportesSatisfaccion('reportes_satisfaccion', 'Satisfacción', '/informes/satisfaccion-paciente'),

  /// Costes operativos
  reportesCostes('reportes_costes', 'Costes', '/informes/costes-operativos'),

  // === TRÁFICO ===
  /// Estado en tiempo real
  traficoTiempoReal('trafico_tiempo_real', 'Tiempo Real', '/trafico/tiempo-real'),

  /// Alertas viales
  traficoAlertas('trafico_alertas', 'Alertas Viales', '/trafico/alertas'),

  /// Rutas alternativas
  traficoRutasAlternativas('trafico_rutas_alternativas', 'Rutas Alternativas', '/trafico/rutas-alternativas'),

  /// Integración con mapas/DGT
  traficoIntegracion('trafico_integracion', 'Integración Mapas', '/trafico/integracion-mapas'),

  /// Prioridad semafórica
  traficoPrioridadSemaforica('trafico_prioridad_semaforica', 'Prioridad Semafórica', '/trafico/prioridad-semaforica'),

  // === TALLER ===
  /// Catálogo de talleres
  talleres('talleres', 'Talleres', '/taller/talleres'),

  /// Órdenes de reparación
  ordenesReparacion('ordenes_reparacion', 'Órdenes Reparación', '/taller/ordenes-reparacion'),

  /// Historial de reparaciones
  historialReparaciones('historial_reparaciones', 'Historial Reparaciones', '/taller/historial-reparaciones'),

  /// Control de repuestos
  controlRepuestos('control_repuestos', 'Control Repuestos', '/taller/control-repuestos'),

  /// Alertas de mantenimiento
  alertasMantenimiento('alertas_mantenimiento', 'Alertas Mantenimiento', '/taller/alertas-mantenimiento'),

  /// Proveedores de taller
  proveedores('proveedores', 'Proveedores', '/taller/proveedores'),

  // === ALMACÉN ===
  /// Dashboard de almacén
  almacenDashboard('almacen_dashboard', 'Almacén', '/almacen/dashboard'),

  /// Movimientos de stock
  almacenMovimientos('almacen_movimientos', 'Movimientos Stock', '/almacen/movimientos'),

  /// Proveedores de almacén
  almacenProveedores('almacen_proveedores', 'Proveedores Almacén', '/almacen/proveedores'),

  /// Productos
  almacenProductos('almacen_productos', 'Productos', '/almacen/productos'),

  // === TABLAS MAESTRAS ===
  /// Centros hospitalarios
  centrosHospitalarios('centros_hospitalarios', 'Centros', '/tablas/centros-hospitalarios'),

  /// Motivos de traslado
  motivosTraslado('motivos_traslado', 'Motivos Traslado', '/tablas/motivos-traslado'),

  /// Tipos de traslado
  tiposTraslado('tipos_traslado', 'Tipos Traslado', '/tablas/tipos-traslado'),

  /// Motivos de cancelación
  motivosCancelacion('motivos_cancelacion', 'Motivos Cancelación', '/tablas/motivos-cancelacion'),

  /// Localidades
  localidades('localidades', 'Localidades', '/tablas/localidades'),

  /// Provincias
  provincias('provincias', 'Provincias', '/tablas/provincias'),

  /// Tipos de vehículo
  tiposVehiculo('tipos_vehiculo', 'Tipos Vehículo', '/tablas/tipos-vehiculo'),

  /// Facultativos
  facultativos('facultativos', 'Facultativos', '/tablas/facultativos'),

  /// Tipos de paciente
  tiposPaciente('tipos_paciente', 'Tipos Paciente', '/tablas/tipos-paciente'),

  /// Protocolos y normativas
  protocolos('protocolos', 'Protocolos', '/tablas/protocolos'),

  /// Categorías de vehículos
  categoriasVehiculos('categorias_vehiculos', 'Categorías Vehículos', '/tablas/categorias-vehiculos'),

  /// Especialidades médicas
  especialidades('especialidades', 'Especialidades', '/tablas/especialidades'),

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

  // === CONFIGURACIÓN ===
  /// Configuración general de la aplicación
  configuracion('configuracion', 'Configuración', '/configuracion'),

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
