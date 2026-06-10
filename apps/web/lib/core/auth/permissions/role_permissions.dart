import 'package:ambutrack_web/core/auth/enums/app_module.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';

/// Mapa de permisos por rol
///
/// Define qué módulos puede acceder cada rol del sistema.
class RolePermissions {
  /// Obtiene los módulos permitidos para un rol
  static List<AppModule> getModulesForRole(UserRole role) {
    return _roleModuleMap[role] ?? <AppModule>[];
  }

  /// Verifica si un rol tiene acceso a un módulo específico
  static bool hasAccessToModule(UserRole role, AppModule module) {
    // Admin tiene acceso a todo
    if (role == UserRole.admin) {
      return true;
    }

    final List<AppModule> allowedModules = getModulesForRole(role);
    return allowedModules.contains(module);
  }

  /// Verifica si un rol tiene acceso a una ruta específica
  static bool hasAccessToRoute(UserRole role, String route) {
    // Admin tiene acceso a todo
    if (role == UserRole.admin) {
      return true;
    }

    final List<AppModule> allowedModules = getModulesForRole(role);

    // Normalizar la ruta (quitar trailing slash para comparación consistente)
    final String normalizedRoute = route.endsWith('/') && route != '/'
        ? route.substring(0, route.length - 1)
        : route;

    return allowedModules.any((AppModule module) {
      final String moduleRoute = module.route;

      // Caso especial: Dashboard (/) solo debe coincidir exactamente con /
      if (moduleRoute == '/') {
        return normalizedRoute == '/';
      }

      // Para otras rutas: la ruta debe empezar con la ruta del módulo
      // Y si no es exacta, debe tener un / después para evitar coincidencias parciales
      if (normalizedRoute == moduleRoute) {
        return true;
      }

      if (normalizedRoute.startsWith(moduleRoute)) {
        // Verificar que sea un segmento completo
        // Ej: /personal/formacion debe coincidir con /personal
        // pero /personalx no debe coincidir
        final String remaining = normalizedRoute.substring(moduleRoute.length);
        return remaining.isEmpty || remaining.startsWith('/');
      }

      return false;
    });
  }

  /// Mapa de rol → módulos permitidos
  static final Map<UserRole, List<AppModule>> _roleModuleMap =
      <UserRole, List<AppModule>>{
    // ===== ADMIN =====
    // Acceso total al sistema
    UserRole.admin: AppModule.values,

    // ===== JEFE DE PERSONAL =====
    // Gestión RRHH, turnos, ausencias, vacaciones, tablas, administración
    UserRole.jefePersonal: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      // Personal completo
      AppModule.personal,
      AppModule.formacion,
      AppModule.documentacionPersonal,
      AppModule.ausencias,
      AppModule.vacaciones,
      AppModule.evaluaciones,
      AppModule.historialMedico,
      AppModule.equipamientoPersonal,
      // Turnos y cuadrantes
      AppModule.turnos,
      AppModule.cuadrantes,
      AppModule.plantillasTurnos,
      AppModule.dotaciones,
      AppModule.asignaciones,
      // Tablas maestras
      AppModule.centrosHospitalarios,
      AppModule.motivosTraslado,
      AppModule.tiposTraslado,
      AppModule.motivosCancelacion,
      AppModule.localidades,
      AppModule.provincias,
      AppModule.tiposVehiculo,
      AppModule.facultativos,
      AppModule.tiposPaciente,
      AppModule.protocolos,
      AppModule.categoriasVehiculos,
      AppModule.especialidades,
      // Reportes
      AppModule.reportesPersonal,
      // Administración
      AppModule.incidencias,
      AppModule.usuariosRoles,
      AppModule.permisosAcceso,
      AppModule.auditorias,
      AppModule.configuracionGeneral,
      // Configuración
      AppModule.configuracion,
    ],

    // ===== JEFE DE TRÁFICO =====
    // Operaciones, servicios, vehículos, tablas, tráfico, administración
    UserRole.jefeTrafic: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      // Servicios
      AppModule.servicios,
      AppModule.pacientes,
      AppModule.urgentes,
      AppModule.planificar,
      AppModule.historico,
      AppModule.agendaPendientes,
      // Personal
      AppModule.personal,
      // Vehículos
      AppModule.vehiculos,
      AppModule.mantenimiento,
      AppModule.itv,
      AppModule.documentacionVehiculos,
      AppModule.geolocalizacion,
      AppModule.consumoKm,
      AppModule.historialAverias,
      AppModule.stockEquipamiento,
      // Cuadrantes
      AppModule.cuadrantes,
      AppModule.dotaciones,
      AppModule.asignaciones,
      // Bases
      AppModule.bases,
      // Operaciones
      AppModule.operaciones,
      AppModule.incidencias,
      // Tráfico
      AppModule.traficoTiempoReal,
      AppModule.traficoAlertas,
      AppModule.traficoRutasAlternativas,
      AppModule.traficoIntegracion,
      AppModule.traficoPrioridadSemaforica,
      // Taller
      AppModule.talleres,
      AppModule.ordenesReparacion,
      AppModule.historialReparaciones,
      AppModule.controlRepuestos,
      AppModule.alertasMantenimiento,
      AppModule.proveedores,
      // Tablas maestras
      AppModule.centrosHospitalarios,
      AppModule.motivosTraslado,
      AppModule.tiposTraslado,
      AppModule.motivosCancelacion,
      AppModule.localidades,
      AppModule.provincias,
      AppModule.tiposVehiculo,
      AppModule.facultativos,
      AppModule.tiposPaciente,
      AppModule.protocolos,
      AppModule.categoriasVehiculos,
      AppModule.especialidades,
      // Reportes
      AppModule.reportesServicios,
      AppModule.estadisticasFlota,
      AppModule.reportesSatisfaccion,
      AppModule.reportesCostes,
      // Administración
      AppModule.contratos,
      AppModule.incidencias,
      AppModule.usuariosRoles,
      AppModule.permisosAcceso,
      AppModule.auditorias,
      AppModule.configuracionGeneral,
      // Configuración
      AppModule.configuracion,
    ],

    // ===== COORDINADOR =====
    // Supervisión operativa, incidencias, tráfico, tablas, administración
    UserRole.coordinador: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      // Servicios
      AppModule.servicios,
      AppModule.pacientes,
      AppModule.urgentes,
      AppModule.planificar,
      AppModule.historico,
      AppModule.agendaPendientes,
      // Cuadrantes
      AppModule.cuadrantes,
      AppModule.dotaciones,
      AppModule.asignaciones,
      // Operaciones
      AppModule.operaciones,
      AppModule.incidencias,
      AppModule.comunicaciones,
      // Tráfico
      AppModule.traficoTiempoReal,
      AppModule.traficoAlertas,
      AppModule.traficoRutasAlternativas,
      AppModule.traficoIntegracion,
      AppModule.traficoPrioridadSemaforica,
      // Tablas maestras
      AppModule.centrosHospitalarios,
      AppModule.motivosTraslado,
      AppModule.tiposTraslado,
      AppModule.motivosCancelacion,
      AppModule.localidades,
      AppModule.provincias,
      AppModule.tiposVehiculo,
      AppModule.facultativos,
      AppModule.tiposPaciente,
      AppModule.protocolos,
      AppModule.categoriasVehiculos,
      AppModule.especialidades,
      // Administración
      AppModule.incidencias,
      AppModule.usuariosRoles,
      AppModule.permisosAcceso,
      AppModule.auditorias,
      AppModule.configuracionGeneral,
      // Configuración
      AppModule.configuracion,
    ],

    // ===== ADMINISTRATIVO =====
    // Gestión documental y contratos
    UserRole.administrativo: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      // Contratos
      AppModule.contratos,
      // Documentación
      AppModule.documentacionPersonal,
      AppModule.documentacionVehiculos,
      // Personal (solo lectura)
      AppModule.personal,
      // Vehículos (solo lectura)
      AppModule.vehiculos,
      // Calendario
      AppModule.calendario,
      // Administración (contratos + docs)
      AppModule.contratos,
      AppModule.incidencias,
    ],

    // ===== CONDUCTOR =====
    // Acceso a datos propios
    UserRole.conductor: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      AppModule.misTurnos,
      AppModule.misServicios,
      AppModule.misAusencias,
    ],

    // ===== SANITARIO =====
    // Acceso a datos propios
    UserRole.sanitario: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      AppModule.misTurnos,
      AppModule.misServicios,
      AppModule.misAusencias,
    ],

    // ===== GESTOR DE FLOTA =====
    // Gestión de flota + taller
    UserRole.gestor: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      AppModule.vehiculos,
      AppModule.mantenimiento,
      AppModule.itv,
      AppModule.documentacionVehiculos,
      AppModule.consumoKm,
      AppModule.historialAverias,
      AppModule.stockEquipamiento,
      AppModule.estadisticasFlota,
      // Taller
      AppModule.talleres,
      AppModule.ordenesReparacion,
      AppModule.historialReparaciones,
      AppModule.controlRepuestos,
      AppModule.alertasMantenimiento,
      AppModule.proveedores,
    ],

    // ===== TÉCNICO =====
    // Mantenimiento + taller + almacén
    UserRole.tecnico: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      AppModule.mantenimiento,
      AppModule.itv,
      AppModule.historialAverias,
      AppModule.stockEquipamiento,
      // Taller
      AppModule.talleres,
      AppModule.ordenesReparacion,
      AppModule.historialReparaciones,
      AppModule.controlRepuestos,
      AppModule.alertasMantenimiento,
      AppModule.proveedores,
      // Almacén
      AppModule.almacenDashboard,
      AppModule.almacenMovimientos,
      AppModule.almacenProveedores,
      AppModule.almacenProductos,
    ],

    // ===== JEFE DE TALLER =====
    // Gestión de mantenimiento, taller, almacén, vehículos, informes flota
    UserRole.jefeTaller: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      // Vehículos
      AppModule.vehiculos,
      AppModule.mantenimiento,
      AppModule.itv,
      AppModule.documentacionVehiculos,
      AppModule.consumoKm,
      AppModule.historialAverias,
      AppModule.stockEquipamiento,
      // Taller (completo)
      AppModule.ordenesReparacion,
      AppModule.historialReparaciones,
      AppModule.controlRepuestos,
      AppModule.alertasMantenimiento,
      AppModule.proveedores,
      // Almacén (completo)
      AppModule.almacenDashboard,
      AppModule.almacenMovimientos,
      AppModule.almacenProveedores,
      AppModule.almacenProductos,
      // Informes (flota)
      AppModule.estadisticasFlota,
      // Tablas (referencia)
      AppModule.centrosHospitalarios,
      AppModule.motivosTraslado,
      AppModule.tiposTraslado,
      AppModule.motivosCancelacion,
      AppModule.localidades,
      AppModule.provincias,
      AppModule.tiposVehiculo,
      AppModule.facultativos,
      AppModule.tiposPaciente,
      AppModule.protocolos,
      AppModule.categoriasVehiculos,
      AppModule.especialidades,
    ],

    // ===== OPERADOR =====
    // Solo lectura
    UserRole.operador: <AppModule>[
      AppModule.dashboard,
      AppModule.miPerfil,
      // Solo lectura de algunos módulos básicos
      AppModule.personal,
      AppModule.vehiculos,
      AppModule.servicios,
    ],
  };
}
