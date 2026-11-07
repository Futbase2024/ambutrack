import 'package:ambutrack_desktop/core/theme/app_colors.dart';
import 'package:ambutrack_desktop/features/menu/domain/entities/menu_item.dart';
import 'package:ambutrack_desktop/features/menu/domain/repositories/menu_repository.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Implementación del repositorio de menú con datos estáticos
@LazySingleton(as: MenuRepository)
class MenuRepositoryImpl implements MenuRepository {
  /// Items del menú principal para pantallas grandes
  static final List<MenuItem> _mainMenuItems = <MenuItem>[
    // 0. Dashboard / Home
    const MenuItem(
      key: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard,
      route: '/',
    ),

    // 1. Tablas
    const MenuItem(
      key: 'tablas',
      label: 'Tablas',
      icon: Icons.table_chart,
      children: <MenuItem>[
        MenuItem(
          key: 'tablas_centros_hospitalarios',
          label: 'Centros Hospitalarios',
          icon: Icons.local_hospital,
          route: '/tablas/centros-hospitalarios',
        ),
        MenuItem(
          key: 'tablas_motivos_traslado',
          label: 'Motivos de Traslado',
          icon: Icons.description,
          route: '/tablas/motivos-traslado',
        ),
        MenuItem(
          key: 'tablas_tipos_traslado',
          label: 'Tipos de Traslado',
          icon: Icons.swap_horiz,
          route: '/tablas/tipos-traslado',
        ),
        MenuItem(
          key: 'tablas_motivos_cancelacion',
          label: 'Motivos de Cancelación',
          icon: Icons.cancel,
          route: '/tablas/motivos-cancelacion',
        ),
        MenuItem(
          key: 'tablas_provincias',
          label: 'Provincias',
          icon: Icons.map,
          route: '/tablas/provincias',
        ),
        MenuItem(
          key: 'tablas_localidades',
          label: 'Localidades',
          icon: Icons.location_city,
          route: '/tablas/localidades',
        ),
        MenuItem(
          key: 'tablas_tipos_vehiculo',
          label: 'Tipos de Vehículo',
          icon: Icons.local_shipping,
          route: '/tablas/tipos-vehiculo',
        ),
        MenuItem(
          key: 'tablas_facultativos',
          label: 'Facultativos',
          icon: Icons.medical_services,
          route: '/tablas/facultativos',
        ),
        MenuItem(
          key: 'tablas_tipos_paciente',
          label: 'Tipos de Paciente',
          icon: Icons.people,
          route: '/tablas/tipos-paciente',
        ),
        MenuItem(
          key: 'tablas_protocolos',
          label: 'Protocolos y Normativas',
          icon: Icons.gavel,
          route: '/tablas/protocolos',
        ),
        MenuItem(
          key: 'tablas_categorias_vehiculos',
          label: 'Categorías de Vehículos',
          icon: Icons.category,
          route: '/tablas/categorias-vehiculos',
        ),
        MenuItem(
          key: 'tablas_especialidades',
          label: 'Especialidades Médicas',
          icon: Icons.medical_information,
          route: '/tablas/especialidades',
        ),
      ],
    ),

    // 2. Servicios
    const MenuItem(
      key: 'servicios',
      label: 'Servicios',
      icon: Icons.medical_services,
      children: <MenuItem>[
        MenuItem(
          key: 'servicios_pacientes',
          label: 'Pacientes',
          icon: Icons.person,
          route: '/servicios/pacientes',
        ),
        MenuItem(
          key: 'servicios_servicios',
          label: 'Servicios',
          icon: Icons.medical_services,
          route: '/servicios/servicios',
        ),
        MenuItem(
          key: 'servicios_generar_diarios',
          label: 'Generar Servicios Diarios',
          icon: Icons.today,
          route: '/servicios/generar-diarios',
        ),
        MenuItem(
          key: 'servicios_planificar',
          label: 'Planificar Servicios',
          icon: Icons.calendar_month,
          route: '/servicios/planificar',
        ),
        MenuItem(
          key: 'servicios_urgentes',
          label: 'Servicios Urgentes en Tiempo Real',
          icon: Icons.emergency,
          route: '/servicios/urgentes',
        ),
        MenuItem(
          key: 'servicios_programacion_recurrente',
          label: 'Programación Recurrente',
          icon: Icons.repeat,
          route: '/servicios/programacion-recurrente',
        ),
        MenuItem(
          key: 'servicios_historico',
          label: 'Histórico de Servicios',
          icon: Icons.history,
          route: '/servicios/historico',
        ),
        MenuItem(
          key: 'servicios_estado',
          label: 'Estado del Servicio',
          icon: Icons.info_outline,
          route: '/servicios/estado',
        ),
      ],
    ),

    // 3. Personal
    const MenuItem(
      key: 'personal',
      label: 'Personal',
      icon: Icons.badge,
      children: <MenuItem>[
        MenuItem(
          key: 'personal_lista',
          label: 'Personal',
          icon: Icons.people,
          route: '/personal',
        ),
        MenuItem(
          key: 'personal_formacion',
          label: 'Formación y Certificaciones',
          icon: Icons.school,
          route: '/personal/formacion',
        ),
        MenuItem(
          key: 'personal_documentacion',
          label: 'Documentación',
          icon: Icons.folder,
          route: '/personal/documentacion',
        ),
        MenuItem(
          key: 'personal_ausencias',
          label: 'Ausencias',
          icon: Icons.event_busy,
          route: '/personal/ausencias',
        ),
        MenuItem(
          key: 'personal_vacaciones',
          label: 'Vacaciones',
          icon: Icons.beach_access,
          route: '/personal/vacaciones',
        ),
        MenuItem(
          key: 'personal_evaluaciones',
          label: 'Evaluaciones de Desempeño',
          icon: Icons.assessment,
          route: '/personal/evaluaciones',
        ),
        MenuItem(
          key: 'personal_historial_medico',
          label: 'Historial Médico',
          icon: Icons.medical_services,
          route: '/personal/historial-medico',
        ),
        MenuItem(
          key: 'personal_equipamiento',
          label: 'Equipamiento del Personal',
          icon: Icons.inventory,
          route: '/personal/equipamiento',
        ),
        MenuItem(
          key: 'personal_vestuario',
          label: 'Vestuario',
          icon: Icons.checkroom,
          route: '/personal/vestuario',
        ),
        MenuItem(
          key: 'personal_stock_vestuario',
          label: 'Stock de Vestuario',
          icon: Icons.inventory_2,
          route: '/personal/stock-vestuario',
        ),
      ],
    ),

    // 4. Cuadrante
    const MenuItem(
      key: 'cuadrante',
      label: 'Cuadrante',
      icon: Icons.calendar_view_month,
      children: <MenuItem>[
        MenuItem(
          key: 'cuadrante_horarios',
          label: 'Horarios y Turnos',
          icon: Icons.access_time,
          route: '/cuadrante/horarios',
        ),
        MenuItem(
          key: 'cuadrante_dotaciones',
          label: 'Dotaciones',
          icon: Icons.format_list_numbered,
          route: '/cuadrante/dotaciones',
        ),
        MenuItem(
          key: 'cuadrante_asignaciones',
          label: 'Asignaciones',
          icon: Icons.assignment,
          route: '/cuadrante/asignaciones',
        ),
        MenuItem(
          key: 'cuadrante_bases',
          label: 'Bases',
          icon: Icons.home_work,
          route: '/cuadrante/bases',
        ),
        MenuItem(
          key: 'cuadrante_excepciones',
          label: 'Excepciones/Festivos',
          icon: Icons.event_busy,
          route: '/cuadrante/excepciones',
        ),
      ],
    ),

    // 5. Vehículos
    const MenuItem(
      key: 'vehiculos',
      label: 'Vehículos',
      icon: Icons.local_shipping,
      children: <MenuItem>[
        MenuItem(
          key: 'vehiculos_lista',
          label: 'Vehículos',
          icon: Icons.directions_car,
          route: '/vehiculos',
        ),
        MenuItem(
          key: 'flota_mantenimiento_preventivo',
          label: 'Mantenimiento Preventivo',
          icon: Icons.build_circle,
          route: '/flota/mantenimiento-preventivo',
        ),
        MenuItem(
          key: 'flota_itv',
          label: 'ITV y Revisiones',
          icon: Icons.fact_check,
          route: '/flota/itv-revisiones',
        ),
        MenuItem(
          key: 'flota_documentacion',
          label: 'Documentación (seguros, licencias)',
          icon: Icons.article,
          route: '/flota/documentacion',
        ),
        MenuItem(
          key: 'flota_geolocalizacion',
          label: 'Geolocalización en Tiempo Real',
          icon: Icons.gps_fixed,
          route: '/flota/geolocalizacion',
        ),
        MenuItem(
          key: 'flota_consumo',
          label: 'Consumo y Km',
          icon: Icons.local_gas_station,
          route: '/flota/consumo-km',
        ),
        MenuItem(
          key: 'flota_historial_averias',
          label: 'Historial de Averías',
          icon: Icons.error,
          route: '/flota/historial-averias',
        ),
        MenuItem(
          key: 'flota_stock_equipamiento',
          label: 'Stock de Equipamiento',
          icon: Icons.inventory_2,
          route: '/flota/stock-equipamiento',
        ),
      ],
    ),

    // 6. Tráfico
    const MenuItem(
      key: 'trafico',
      label: 'Tráfico',
      icon: Icons.traffic,
      children: <MenuItem>[
        MenuItem(
          key: 'trafico_estado_tiempo_real',
          label: 'Estado en Tiempo Real',
          icon: Icons.map,
          route: '/trafico/tiempo-real',
        ),
        MenuItem(
          key: 'trafico_alertas',
          label: 'Alertas de Incidencias Viales',
          icon: Icons.warning,
          route: '/trafico/alertas',
        ),
        MenuItem(
          key: 'trafico_rutas_alternativas',
          label: 'Rutas Alternativas Optimizadas',
          icon: Icons.alt_route,
          route: '/trafico/rutas-alternativas',
        ),
        MenuItem(
          key: 'trafico_integracion_mapas',
          label: 'Integración con Mapas / DGT',
          icon: Icons.layers,
          route: '/trafico/integracion-mapas',
        ),
        MenuItem(
          key: 'trafico_prioridad_semaforica',
          label: 'Prioridad Semafórica',
          icon: Icons.traffic_outlined,
          route: '/trafico/prioridad-semaforica',
        ),
      ],
    ),

    // 7. Informes
    const MenuItem(
      key: 'informes',
      label: 'Informes',
      icon: Icons.assessment,
      children: <MenuItem>[
        MenuItem(
          key: 'informes_servicios_realizados',
          label: 'Servicios Realizados',
          icon: Icons.analytics,
          route: '/informes/servicios-realizados',
        ),
        MenuItem(
          key: 'informes_indicadores_calidad',
          label: 'Indicadores de Calidad',
          icon: Icons.trending_up,
          route: '/informes/indicadores-calidad',
        ),
        MenuItem(
          key: 'informes_personal',
          label: 'Informes de Personal',
          icon: Icons.people_outline,
          route: '/informes/personal',
        ),
        MenuItem(
          key: 'informes_estadisticas_flota',
          label: 'Estadísticas de Flota',
          icon: Icons.local_shipping,
          route: '/informes/estadisticas-flota',
        ),
        MenuItem(
          key: 'informes_satisfaccion',
          label: 'Satisfacción del Paciente',
          icon: Icons.sentiment_satisfied,
          route: '/informes/satisfaccion-paciente',
        ),
        MenuItem(
          key: 'informes_costes',
          label: 'Costes Operativos',
          icon: Icons.attach_money,
          route: '/informes/costes-operativos',
        ),
      ],
    ),

    // 8. Taller
    const MenuItem(
      key: 'taller',
      label: 'Taller',
      icon: Icons.construction,
      children: <MenuItem>[
        MenuItem(
          key: 'taller_ordenes_reparacion',
          label: 'Órdenes de Reparación',
          icon: Icons.build,
          route: '/taller/ordenes-reparacion',
        ),
        MenuItem(
          key: 'taller_historial_reparaciones',
          label: 'Historial de Reparaciones',
          icon: Icons.history,
          route: '/taller/historial-reparaciones',
        ),
        MenuItem(
          key: 'taller_control_repuestos',
          label: 'Control de Repuestos',
          icon: Icons.inventory,
          route: '/taller/control-repuestos',
        ),
        MenuItem(
          key: 'taller_alertas_mantenimiento',
          label: 'Alertas de Mantenimiento Preventivo',
          icon: Icons.notifications_active,
          route: '/taller/alertas-mantenimiento',
        ),
        MenuItem(
          key: 'taller_proveedores',
          label: 'Gestión de Proveedores',
          icon: Icons.business,
          route: '/taller/proveedores',
        ),
      ],
    ),

    // 9. Almacén General
    const MenuItem(
      key: 'almacen',
      label: 'Almacén General',
      icon: Icons.warehouse,
      children: <MenuItem>[
        MenuItem(
          key: 'almacen_dashboard',
          label: 'Almacén',
          icon: Icons.dashboard,
          route: '/almacen/dashboard',
        ),
        MenuItem(
          key: 'almacen_movimientos',
          label: 'Movimientos de Stock',
          icon: Icons.history,
          route: '/almacen/movimientos',
        ),
        MenuItem(
          key: 'almacen_proveedores',
          label: 'Proveedores',
          icon: Icons.business,
          route: '/almacen/proveedores',
        ),
        MenuItem(
          key: 'almacen_productos',
          label: 'Productos',
          icon: Icons.inventory_2,
          route: '/almacen/productos',
        ),
      ],
    ),

    // 10. Administración
    const MenuItem(
      key: 'administracion',
      label: 'Administración',
      icon: Icons.admin_panel_settings,
      children: <MenuItem>[
        MenuItem(
          key: 'administracion_contratos',
          label: 'Contratos',
          icon: Icons.description,
          route: '/administracion/contratos',
        ),
        MenuItem(
          key: 'administracion_usuarios',
          label: 'Usuarios y Roles',
          icon: Icons.people,
          route: '/administracion/usuarios-roles',
        ),
        MenuItem(
          key: 'administracion_permisos',
          label: 'Permisos de Acceso',
          icon: Icons.security,
          route: '/administracion/permisos-acceso',
        ),
        MenuItem(
          key: 'administracion_auditorias',
          label: 'Auditorías y Logs',
          icon: Icons.search,
          route: '/administracion/auditorias-logs',
        ),
        MenuItem(
          key: 'administracion_multicentro',
          label: 'Multi-centro / Multi-empresa',
          icon: Icons.business_center,
          route: '/administracion/multicentro',
        ),
        MenuItem(
          key: 'administracion_configuracion',
          label: 'Configuración General',
          icon: Icons.settings,
          route: '/administracion/configuracion-general',
        ),
      ],
    ),

    // 11. Otros
    const MenuItem(
      key: 'otros',
      label: 'Otros',
      icon: Icons.more_horiz,
      children: <MenuItem>[
        MenuItem(
          key: 'otros_integraciones',
          label: 'Integraciones (SMS, FCM, mapas)',
          icon: Icons.integration_instructions,
          route: '/otros/integraciones',
        ),
        MenuItem(
          key: 'otros_backups',
          label: 'Backups y Restauración',
          icon: Icons.backup,
          route: '/otros/backups',
        ),
        MenuItem(
          key: 'otros_api',
          label: 'API / Webhooks',
          icon: Icons.api,
          route: '/otros/api-webhooks',
        ),
      ],
    ),

    // Configuración (botón separado en AppBar)
    const MenuItem(
      key: 'configuracion',
      label: 'Configuración',
      icon: Icons.settings,
      route: '/configuracion',
    ),

    // Usuario (botón separado en AppBar)
    const MenuItem(
      key: 'usuario',
      label: 'Usuario',
      icon: Icons.account_circle,
      children: <MenuItem>[
        MenuItem(
          key: 'usuario_perfil',
          label: 'Mi Perfil',
          icon: Icons.person,
          route: '/perfil',
          color: AppColors.primary,
        ),
        MenuItem(
          key: 'usuario_logout',
          label: 'Cerrar Sesión',
          icon: Icons.logout,
          route: '/logout',
          color: AppColors.emergency,
        ),
      ],
    ),
  ];

  /// Items del menú móvil (estructura plana)
  static final List<MenuItem> _mobileMenuItems = <MenuItem>[
    const MenuItem(
      key: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard,
      route: '/',
    ),
    const MenuItem(
      key: 'tablas',
      label: 'Tablas',
      icon: Icons.table_chart,
      route: '/tablas',
    ),
    const MenuItem(
      key: 'servicios',
      label: 'Servicios',
      icon: Icons.medical_services,
      route: '/servicios',
    ),
    const MenuItem(
      key: 'personal',
      label: 'Personal',
      icon: Icons.badge,
      route: '/personal',
    ),
    const MenuItem(
      key: 'flota',
      label: 'Vehículos / Flota',
      icon: Icons.local_shipping,
      route: '/flota',
    ),
    const MenuItem(
      key: 'trafico',
      label: 'Tráfico',
      icon: Icons.traffic,
      route: '/trafico',
    ),
    const MenuItem(
      key: 'informes',
      label: 'Informes',
      icon: Icons.assessment,
      route: '/informes',
    ),
    const MenuItem(
      key: 'taller',
      label: 'Taller',
      icon: Icons.construction,
      route: '/taller',
    ),
    const MenuItem(
      key: 'administracion',
      label: 'Administración',
      icon: Icons.admin_panel_settings,
      route: '/administracion',
    ),
    const MenuItem(
      key: 'otros',
      label: 'Otros',
      icon: Icons.more_horiz,
      route: '/otros',
    ),
    const MenuItem(
      key: 'configuracion',
      label: 'Configuración',
      icon: Icons.settings,
      route: '/configuracion',
    ),
    const MenuItem(
      key: 'perfil',
      label: 'Perfil',
      icon: Icons.account_circle,
      route: '/perfil',
    ),
  ];

  @override
  List<MenuItem> getMainMenuItems() {
    return List<MenuItem>.unmodifiable(_mainMenuItems);
  }

  @override
  List<MenuItem> getMobileMenuItems() {
    return List<MenuItem>.unmodifiable(_mobileMenuItems);
  }

  @override
  MenuItem? getMenuItemByKey(String key) {
    // Buscar en items principales
    for (final MenuItem item in _mainMenuItems) {
      if (item.key == key) {
        return item;
      }

      // Buscar en children
      for (final MenuItem child in item.children) {
        if (child.key == key) {
          return child;
        }
      }
    }
    return null;
  }

  @override
  List<MenuItem> getFlatMenuItems() {
    final List<MenuItem> flatItems = <MenuItem>[];

    for (final MenuItem item in _mainMenuItems) {
      if (item.hasChildren) {
        flatItems.addAll(item.children);
      } else {
        flatItems.add(item);
      }
    }

    return List<MenuItem>.unmodifiable(flatItems);
  }
}