import 'package:flutter/material.dart';

/// AmbuTrack Icon Library v1.5 - Expanded
///
/// Biblioteca centralizada de iconos siguiendo el Design System de AmbuTrack.
/// Basado en Material Icons Round y Material Symbols Outlined.
///
/// **Guía de colores:**
/// - Active: AppColors.primary (#137fec)
/// - Hover: AppColors.primary.withValues(alpha: 0.4) (#137fec66)
/// - Disabled: Colors.grey.withValues(alpha: 0.3) (#4755694D)
///
/// **Uso:**
/// ```dart
/// Icon(AppIcons.gearUniform, color: AppColors.primary)
/// Icon(AppIcons.logFurgon, color: AppColors.primary.withValues(alpha: 0.4))
/// ```
class AppIcons {
  AppIcons._(); // Constructor privado para evitar instanciación

  // ==========================================
  // PERSONNEL & GEAR
  // ==========================================

  /// Uniform / Clothing (at-gear-uniform)
  /// Uso: Gestión de uniformes del personal
  static const IconData gearUniform = Icons.checkroom_rounded;

  /// ID Card (at-gear-id)
  /// Uso: Tarjetas de identificación del personal
  static const IconData gearId = Icons.badge_rounded;

  /// Clock / Time-log (at-gear-log)
  /// Uso: Registro de horarios y fichajes
  static const IconData gearLog = Icons.history_toggle_off_rounded;

  // ==========================================
  // ADVANCED LOGISTICS
  // ==========================================

  /// Van / Furgon (at-log-furgon)
  /// Uso: Vehículos tipo furgoneta/van
  /// NOTA: Material Symbols Outlined - Requiere configuración especial
  static const IconData logFurgon = Icons.airport_shuttle_outlined;

  /// Stacked Documents (at-log-docs)
  /// Uso: Documentación agrupada, archivos múltiples
  static const IconData logDocs = Icons.library_books_rounded;

  /// Curved Path (at-log-route)
  /// Uso: Rutas de navegación, trayectorias
  static const IconData logRoute = Icons.route_rounded;

  /// Folder (at-log-folder)
  /// Uso: Carpetas de archivos, organización documental
  static const IconData logFolder = Icons.folder_open_rounded;

  // ==========================================
  // FACILITIES & SAFETY
  // ==========================================

  /// Warehouse / Building (at-fac-base)
  /// Uso: Instalaciones, almacenes, bases operativas
  static const IconData facBase = Icons.warehouse_rounded;

  /// Safety Vest (at-fac-safety)
  /// Uso: Equipamiento de seguridad
  /// NOTA: Material Symbols Outlined - Requiere configuración especial
  static const IconData facSafety = Icons.safety_check_outlined;

  /// Alarm / Siren (at-fac-alarm)
  /// Uso: Alertas, notificaciones críticas, sirenas
  static const IconData facAlarm = Icons.notifications_active_rounded;

  // ==========================================
  // CORE SETS (Referencia de navegación)
  // ==========================================

  /// Fleet navigation icon
  static const IconData navFleet = Icons.local_shipping_rounded;

  /// Medical navigation icon
  static const IconData navMedical = Icons.medical_services_rounded;

  /// Logistics navigation icon
  static const IconData navLogistics = Icons.assignment_rounded;

  /// Actions navigation icon
  static const IconData navActions = Icons.bolt_rounded;

  /// Personnel & Gear navigation icon
  static const IconData navPersonnel = Icons.groups_rounded;

  /// Advanced Logistics navigation icon
  static const IconData navAdvLogistics = Icons.layers_rounded;

  /// Facilities & Safety navigation icon
  static const IconData navFacilities = Icons.domain_rounded;

  // ==========================================
  // UTILITY ICONS (de la librería HTML)
  // ==========================================

  /// Emergency icon (logo principal)
  static const IconData emergency = Icons.emergency_rounded;

  /// Search icon
  static const IconData search = Icons.search_rounded;

  /// Download icon
  static const IconData download = Icons.download_rounded;

  /// Copy icon
  static const IconData copy = Icons.content_copy_rounded;

  /// Palette icon
  static const IconData palette = Icons.palette_rounded;

  /// Straighten icon
  static const IconData straighten = Icons.straighten_rounded;

  /// Verified icon
  static const IconData verified = Icons.verified_rounded;

  // ==========================================
  // APP NAVIGATION & ACTIONS
  // ==========================================

  /// Logout / Sign out icon
  static const IconData logout = Icons.logout_rounded;

  /// Dashboard / Home icon
  static const IconData dashboard = Icons.dashboard_rounded;

  /// Schedule / Clock icon (registro horario)
  static const IconData schedule = Icons.schedule_rounded;

  /// Checklist icon
  static const IconData checklist = Icons.checklist_rounded;

  /// Assignment / Document icon (partes diarios)
  static const IconData assignment = Icons.assignment_rounded;

  /// Warning / Alert icon (incidencias)
  static const IconData warningAmber = Icons.warning_amber_rounded;

  /// Person / Profile icon
  static const IconData person = Icons.person_rounded;

  /// Settings icon
  static const IconData settings = Icons.settings_rounded;

  /// Notifications icon
  static const IconData notifications = Icons.notifications_rounded;

  /// More vertical (menu) icon
  static const IconData moreVert = Icons.more_vert_rounded;

  /// Add icon
  static const IconData add = Icons.add_rounded;

  /// Edit icon
  static const IconData edit = Icons.edit_rounded;

  /// Delete icon
  static const IconData delete = Icons.delete_rounded;

  /// Close icon
  static const IconData close = Icons.close_rounded;

  /// Check / Confirm icon
  static const IconData check = Icons.check_rounded;

  /// Filter icon
  static const IconData filter = Icons.filter_list_rounded;

  /// Sort icon
  static const IconData sort = Icons.sort_rounded;

  /// Refresh icon
  static const IconData refresh = Icons.refresh_rounded;

  /// Info icon
  static const IconData info = Icons.info_rounded;

  /// Help icon
  static const IconData help = Icons.help_rounded;

  // ==========================================
  // APP FEATURES (AmbuTrack Mobile)
  // ==========================================

  /// Servicios / Traslados icon
  static const IconData servicios = Icons.local_hospital_rounded;

  /// Trámites / Documentos icon
  static const IconData tramites = Icons.description_rounded;

  /// Vehículo / Coche asignado icon
  static const IconData vehiculo = Icons.directions_car_rounded;

  /// Vestuario / Uniformes icon
  static const IconData vestuario = Icons.checkroom_rounded;

  /// Ambulancias icon
  static const IconData ambulancias = Icons.emergency_rounded;

  /// Turno / Clock in/out icon
  static const IconData turno = Icons.access_time_rounded;

  /// Perfil de usuario icon
  static const IconData perfil = Icons.account_circle_rounded;

  /// Base / Instalaciones icon
  static const IconData base = Icons.business_rounded;

  /// Ruta / GPS icon
  static const IconData ruta = Icons.route_rounded;

  /// Mapa / Localización icon
  static const IconData mapa = Icons.map_rounded;

  /// Calendario icon
  static const IconData calendario = Icons.calendar_today_rounded;

  /// Documentación / Archivos icon
  static const IconData documentacion = Icons.folder_rounded;

  /// Historial icon
  static const IconData historial = Icons.history_rounded;

  /// Estadísticas / Gráficos icon
  static const IconData estadisticas = Icons.bar_chart_rounded;

  /// Configuración / Ajustes icon
  static const IconData configuracion = Icons.tune_rounded;
}

/// Extensión para obtener iconos con estados predefinidos
extension AppIconStates on IconData {
  /// Retorna el color para estado activo
  Color get activeColor => const Color(0xFF137FEC);

  /// Retorna el color para estado hover
  Color get hoverColor => const Color(0xFF137FEC).withValues(alpha: 0.4);

  /// Retorna el color para estado deshabilitado
  Color get disabledColor => const Color(0xFF475569).withValues(alpha: 0.3);
}
