import 'dart:async';

import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/layout/main_layout.dart';
import 'package:ambutrack_web/core/router/auth_guard.dart';
import 'package:ambutrack_web/core/widgets/placeholder_page.dart';
import 'package:ambutrack_web/features/almacen/presentation/pages/almacen_dashboard_page.dart';
import 'package:ambutrack_web/features/almacen/presentation/pages/movimientos_stock_page.dart';
import 'package:ambutrack_web/features/almacen/presentation/pages/productos_page.dart';
import 'package:ambutrack_web/features/almacen/presentation/pages/proveedores_page.dart';
import 'package:ambutrack_web/features/ausencias/presentation/pages/ausencias_page.dart';
import 'package:ambutrack_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:ambutrack_web/features/auth/presentation/pages/login_page.dart';
import 'package:ambutrack_web/features/contratos/presentation/pages/contratos_page.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/pages/asignaciones_page.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/presentation/pages/cuadrante_mensual_page.dart';
import 'package:ambutrack_web/features/cuadrante/bases/presentation/pages/bases_page.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/pages/cuadrante_page.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_visual/presentation/pages/cuadrante_visual_page.dart';
import 'package:ambutrack_web/features/cuadrante/dotaciones/presentation/pages/dotaciones_page.dart';
import 'package:ambutrack_web/features/cuadrante/excepciones_festivos/presentation/pages/excepciones_festivos_page.dart';
import 'package:ambutrack_web/features/home/home_page_integral.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/pages/itv_revisiones_page.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/pages/mantenimiento_preventivo_page_v2.dart';
import 'package:ambutrack_web/features/personal/personal_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/documentacion_personal_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/equipamiento_personal_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/evaluaciones_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/formacion_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/historial_medico_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/horarios_page.dart';
import 'package:ambutrack_web/features/personal/presentation/pages/vestuario_page.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/pages/pacientes_page.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/pages/servicios_page.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/pages/stock_vestuario_page.dart';
import 'package:ambutrack_web/features/tablas/categorias_vehiculo/presentation/pages/categoria_vehiculo_page.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/presentation/pages/centros_hospitalarios_page.dart';
import 'package:ambutrack_web/features/tablas/especialidades_medicas/presentation/pages/especialidades_medicas_page.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/pages/facultativos_page.dart';
import 'package:ambutrack_web/features/tablas/localidades/presentation/pages/localidades_page.dart';
import 'package:ambutrack_web/features/tablas/motivos_cancelacion/presentation/pages/motivos_cancelacion_page.dart';
import 'package:ambutrack_web/features/tablas/motivos_traslado/presentation/pages/motivos_traslado_page.dart';
import 'package:ambutrack_web/features/tablas/provincias/presentation/pages/provincias_page.dart';
import 'package:ambutrack_web/features/tablas/tipos_paciente/presentation/pages/tipos_paciente_page.dart';
import 'package:ambutrack_web/features/tablas/tipos_traslado/presentation/pages/tipos_traslado_page.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/pages/tipos_vehiculo_page.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/pages/planificar_servicios_page.dart';
import 'package:ambutrack_web/features/turnos/presentation/pages/plantillas_turnos_page.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/pages/vacaciones_page.dart';
import 'package:ambutrack_web/features/vehiculos/consumo_km_page.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion_page.dart';
import 'package:ambutrack_web/features/vehiculos/geolocalizacion_page.dart';
import 'package:ambutrack_web/features/vehiculos/historial_averias_page.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/pages/stock_equipamiento_page.dart';
import 'package:ambutrack_web/features/vehiculos/vehiculo_stock_page.dart';
import 'package:ambutrack_web/features/vehiculos/vehiculos_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


/// Transición profesional Fade + Scale para todas las páginas
///
/// Características:
/// - Fade suave con opacidad
/// - Scale sutil (95% → 100%)
/// - Curva easeOutCubic para sensación natural
/// - Duración: 250ms (profesional y rápida)
Page<T> _buildPageWithTransition<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// Configuración del enrutamiento de la aplicación
///
/// Define todas las rutas disponibles en la aplicación.
/// Utiliza GoRouter con ShellRoute para mantener el MainLayout fijo
/// mientras el contenido cambia dinámicamente según la ruta.
/// Incluye protección de autenticación mediante AuthGuard.
/// Todas las páginas usan transición profesional Fade + Scale.
final GoRouter appRouter = GoRouter(
  redirect: AuthGuard.redirect,
  refreshListenable: GoRouterRefreshStream(getIt<AuthRepository>().authStateChanges),
  routes: <RouteBase>[
    // Ruta de Login (sin MainLayout)
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const LoginPage(),
      ),
    ),

    // Rutas protegidas con MainLayout
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainLayout(child: child);
      },
      routes: <RouteBase>[
        // Home / Dashboard
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const HomePageIntegral(),
      ),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const HomePageIntegral(),
      ),
        ),

        // ==================== TABLAS ====================
        // Centros Hospitalarios
        GoRoute(
          path: '/tablas/centros-hospitalarios',
          name: 'tablas_centros_hospitalarios',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const CentrosHospitalariosPage(),
      ),
        ),
        // Motivos de Traslado
        GoRoute(
          path: '/tablas/motivos-traslado',
          name: 'tablas_motivos_traslado',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const MotivosTrasladoPage(),
      ),
        ),
        // Tipos de Traslado
        GoRoute(
          path: '/tablas/tipos-traslado',
          name: 'tablas_tipos_traslado',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const TiposTrasladoPage(),
      ),
        ),
        // Motivos de Cancelación
        GoRoute(
          path: '/tablas/motivos-cancelacion',
          name: 'tablas_motivos_cancelacion',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const MotivosCancelacionPage(),
      ),
        ),
        // Tipos de Paciente
        GoRoute(
          path: '/tablas/tipos-paciente',
          name: 'tablas_tipos_paciente',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const TiposPacientePage(),
      ),
        ),
        // Provincias
        GoRoute(
          path: '/tablas/provincias',
          name: 'tablas_provincias',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ProvinciasPage(),
      ),
        ),
        // Localidades
        GoRoute(
          path: '/tablas/localidades',
          name: 'tablas_localidades',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const LocalidadesPage(),
      ),
        ),
        // Tipos de Vehículo
        GoRoute(
          path: '/tablas/tipos-vehiculo',
          name: 'tablas_tipos_vehiculo',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const TiposVehiculoPage(),
      ),
        ),
        // Vehículos
        GoRoute(
          path: '/tablas/vehiculos',
          name: 'tablas_vehiculos',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Vehículos',
          subtitle: 'Catálogo de vehículos',
          icon: Icons.directions_car,
        ),
      ),
        ),
        // Facultativos
        GoRoute(
          path: '/tablas/facultativos',
          name: 'tablas_facultativos',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const FacultativosPage(),
      ),
        ),
        // Protocolos y Normativas
        GoRoute(
          path: '/tablas/protocolos',
          name: 'tablas_protocolos',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Protocolos y Normativas',
          subtitle: 'Gestión de protocolos médicos',
          icon: Icons.gavel,
        ),
      ),
        ),
        // Categorías de Vehículos
        GoRoute(
          path: '/tablas/categorias-vehiculos',
          name: 'tablas_categorias_vehiculos',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const CategoriasVehiculoPage(),
      ),
        ),
        // Especialidades Médicas
        GoRoute(
          path: '/tablas/especialidades',
          name: 'tablas_especialidades',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const EspecialidadesMedicasPage(),
      ),
        ),

        // ==================== SERVICIOS ====================
        // Pacientes
        GoRoute(
          path: '/servicios/pacientes',
          name: 'servicios_pacientes',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const PacientesPage(),
          ),
        ),
        // Servicios
        GoRoute(
          path: '/servicios/servicios',
          name: 'servicios_servicios',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const ServiciosPage(),
          ),
        ),
        // Generar Servicios Diarios
        GoRoute(
          path: '/servicios/generar-diarios',
          name: 'servicios_generar_diarios',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Generar Servicios Diarios',
          subtitle: 'Creación de servicios del día',
          icon: Icons.today,
        ),
      ),
        ),
        // Planificar Servicios
        GoRoute(
          path: '/servicios/planificar',
          name: 'servicios_planificar',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlanificarServiciosPage(),
      ),
        ),
        // Servicios Urgentes
        GoRoute(
          path: '/servicios/urgentes',
          name: 'servicios_urgentes',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Servicios Urgentes',
          subtitle: 'Gestión de emergencias en tiempo real',
          icon: Icons.emergency,
        ),
      ),
        ),
        // Programación Recurrente
        GoRoute(
          path: '/servicios/programacion-recurrente',
          name: 'servicios_programacion_recurrente',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Programación Recurrente',
          subtitle: 'Servicios programados periódicamente',
          icon: Icons.repeat,
        ),
      ),
        ),
        // Histórico de Servicios
        GoRoute(
          path: '/servicios/historico',
          name: 'servicios_historico',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Histórico de Servicios',
          subtitle: 'Consulta de servicios realizados',
          icon: Icons.history,
        ),
      ),
        ),
        // Estado del Servicio
        GoRoute(
          path: '/servicios/estado',
          name: 'servicios_estado',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Estado del Servicio',
          subtitle: 'Monitoreo de servicios activos',
          icon: Icons.info_outline,
        ),
      ),
        ),

        // ==================== PERSONAL ====================
        // Personal
        GoRoute(
          path: '/personal',
          name: 'personal',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const PersonalPage(),
      ),
        ),
        // Formación y Certificaciones
        GoRoute(
          path: '/personal/formacion',
          name: 'personal_formacion',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const FormacionPage(),
      ),
        ),
        // Documentación
        GoRoute(
          path: '/personal/documentacion',
          name: 'personal_documentacion',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const DocumentacionPersonalPage(),
      ),
        ),
        // ==================== CUADRANTE ====================
        // Bases/Centros
        GoRoute(
          path: '/cuadrante/bases',
          name: 'cuadrante_bases',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const BasesPage(),
      ),
        ),
        // Dotaciones
        GoRoute(
          path: '/cuadrante/dotaciones',
          name: 'cuadrante_dotaciones',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const DotacionesPage(),
      ),
        ),
        // Asignaciones
        GoRoute(
          path: '/cuadrante/asignaciones',
          name: 'cuadrante_asignaciones',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const AsignacionesPage(),
      ),
        ),
        // Horarios y Turnos (movido a Cuadrante)
        GoRoute(
          path: '/cuadrante/horarios',
          name: 'cuadrante_horarios',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const HorariosPage(),
      ),
        ),
        // Excepciones y Festivos
        GoRoute(
          path: '/cuadrante/excepciones',
          name: 'cuadrante_excepciones',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ExcepcionesFestivosPage(),
      ),
      ),
        // Cuadrante Visual (Drag & Drop)
        GoRoute(
          path: '/cuadrante/visual',
          name: 'cuadrante_visual',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const CuadranteVisualPage(),
      ),
        ),
        // Cuadrante Mensual Unificado
        GoRoute(
          path: '/cuadrante/mensual',
          name: 'cuadrante_mensual',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const CuadranteMensualPage(),
      ),
        ),

        // ==================== PERSONAL ====================
        // Ausencias
        GoRoute(
          path: '/personal/ausencias',
          name: 'personal_ausencias',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const AusenciasPage(),
      ),
        ),
        // Vacaciones
        GoRoute(
          path: '/personal/vacaciones',
          name: 'personal_vacaciones',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const VacacionesPage(),
      ),
        ),
        // Evaluaciones de Desempeño
        GoRoute(
          path: '/personal/evaluaciones',
          name: 'personal_evaluaciones',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const EvaluacionesPage(),
      ),
        ),
        // Historial Médico
        GoRoute(
          path: '/personal/historial-medico',
          name: 'personal_historial_medico',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const HistorialMedicoPage(),
      ),
        ),
        // Equipamiento del Personal
        GoRoute(
          path: '/personal/equipamiento',
          name: 'personal_equipamiento',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const EquipamientoPersonalPage(),
      ),
        ),
        // Vestuario
        GoRoute(
          path: '/personal/vestuario',
          name: 'personal_vestuario',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const VestuarioPage(),
      ),
        ),
        // Stock de Vestuario
        GoRoute(
          path: '/personal/stock-vestuario',
          name: 'personal_stock_vestuario',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const StockVestuarioPage(),
      ),
        ),
        // Cuadrante de Personal
        GoRoute(
          path: '/personal/cuadrante',
          name: 'personal_cuadrante',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const CuadrantePage(),
      ),
        ),
        // Plantillas de Turnos
        GoRoute(
          path: '/personal/plantillas-turnos',
          name: 'plantillas_turnos',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const PlantillasTurnosPage(),
      ),
        ),

        // ==================== VEHÍCULOS ====================
        // Vehículos
        GoRoute(
          path: '/vehiculos',
          name: 'vehiculos',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const VehiculosPage(),
      ),
        ),
        // Mantenimiento Preventivo
        GoRoute(
          path: '/flota/mantenimiento-preventivo',
          name: 'flota_mantenimiento_preventivo',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const MantenimientoPreventivoPageV2(),
      ),
        ),
        // ITV y Revisiones
        GoRoute(
          path: '/flota/itv-revisiones',
          name: 'flota_itv',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ItvRevisionesPage(),
      ),
        ),
        // Documentación
        GoRoute(
          path: '/flota/documentacion',
          name: 'flota_documentacion',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const DocumentacionPage(),
      ),
        ),
        // Geolocalización
        GoRoute(
          path: '/flota/geolocalizacion',
          name: 'flota_geolocalizacion',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const GeolocalizacionPage(),
      ),
        ),
        // Consumo y Km
        GoRoute(
          path: '/flota/consumo-km',
          name: 'flota_consumo',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ConsumoKmPage(),
      ),
        ),
        // Historial de Averías
        GoRoute(
          path: '/flota/historial-averias',
          name: 'flota_historial_averias',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const HistorialAveriasPage(),
      ),
        ),
        // Stock de Equipamiento de Vehículos
        GoRoute(
          path: '/flota/stock-equipamiento',
          name: 'flota_stock_equipamiento',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              _buildPageWithTransition(
            key: state.pageKey,
            child: const StockEquipamientoPage(),
          ),
        ),

        // Stock de vehículo individual
        GoRoute(
          path: '/flota/vehiculo/:vehiculoId/stock',
          name: 'flota_stock_vehiculo',
          pageBuilder: (BuildContext context, GoRouterState state) {
            final String vehiculoId = state.pathParameters['vehiculoId']!;
            return _buildPageWithTransition(
              key: state.pageKey,
              child: VehiculoStockPage(vehiculoId: vehiculoId),
            );
          },
        ),

        // ==================== TRÁFICO ====================
        // Estado en Tiempo Real
        GoRoute(
          path: '/trafico/tiempo-real',
          name: 'trafico_estado_tiempo_real',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Estado en Tiempo Real',
          subtitle: 'Monitoreo de tráfico en vivo',
          icon: Icons.map,
        ),
      ),
        ),
        // Alertas de Incidencias Viales
        GoRoute(
          path: '/trafico/alertas',
          name: 'trafico_alertas',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Alertas de Incidencias Viales',
          subtitle: 'Notificaciones de incidentes',
          icon: Icons.warning,
        ),
      ),
        ),
        // Rutas Alternativas Optimizadas
        GoRoute(
          path: '/trafico/rutas-alternativas',
          name: 'trafico_rutas_alternativas',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Rutas Alternativas Optimizadas',
          subtitle: 'Sugerencias de rutas alternativas',
          icon: Icons.alt_route,
        ),
      ),
        ),
        // Integración con Mapas / DGT
        GoRoute(
          path: '/trafico/integracion-mapas',
          name: 'trafico_integracion_mapas',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Integración con Mapas / DGT',
          subtitle: 'Datos de tráfico externo',
          icon: Icons.layers,
        ),
      ),
        ),
        // Prioridad Semafórica
        GoRoute(
          path: '/trafico/prioridad-semaforica',
          name: 'trafico_prioridad_semaforica',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Prioridad Semafórica',
          subtitle: 'Gestión de prioridad en semáforos',
          icon: Icons.traffic_outlined,
        ),
      ),
        ),

        // ==================== INFORMES ====================
        // Servicios Realizados
        GoRoute(
          path: '/informes/servicios-realizados',
          name: 'informes_servicios_realizados',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Servicios Realizados',
          subtitle: 'Reporte de servicios completados',
          icon: Icons.analytics,
        ),
      ),
        ),
        // Indicadores de Calidad
        GoRoute(
          path: '/informes/indicadores-calidad',
          name: 'informes_indicadores_calidad',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Indicadores de Calidad',
          subtitle: 'Métricas de calidad del servicio',
          icon: Icons.trending_up,
        ),
      ),
        ),
        // Informes de Personal
        GoRoute(
          path: '/informes/personal',
          name: 'informes_personal',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Informes de Personal',
          subtitle: 'Reportes del personal',
          icon: Icons.people_outline,
        ),
      ),
        ),
        // Estadísticas de Flota
        GoRoute(
          path: '/informes/estadisticas-flota',
          name: 'informes_estadisticas_flota',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Estadísticas de Flota',
          subtitle: 'Análisis de uso de vehículos',
          icon: Icons.local_shipping,
        ),
      ),
        ),
        // Satisfacción del Paciente
        GoRoute(
          path: '/informes/satisfaccion-paciente',
          name: 'informes_satisfaccion',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Satisfacción del Paciente',
          subtitle: 'Encuestas y valoraciones',
          icon: Icons.sentiment_satisfied,
        ),
      ),
        ),
        // Costes Operativos
        GoRoute(
          path: '/informes/costes-operativos',
          name: 'informes_costes',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Costes Operativos',
          subtitle: 'Análisis de costos',
          icon: Icons.attach_money,
        ),
      ),
        ),

        // ==================== TALLER ====================
        // Órdenes de Reparación
        GoRoute(
          path: '/taller/ordenes-reparacion',
          name: 'taller_ordenes_reparacion',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Órdenes de Reparación',
          subtitle: 'Gestión de reparaciones',
          icon: Icons.build,
        ),
      ),
        ),
        // Historial de Reparaciones
        GoRoute(
          path: '/taller/historial-reparaciones',
          name: 'taller_historial_reparaciones',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Historial de Reparaciones',
          subtitle: 'Registro de reparaciones realizadas',
          icon: Icons.history,
        ),
      ),
        ),
        // Control de Repuestos
        GoRoute(
          path: '/taller/control-repuestos',
          name: 'taller_control_repuestos',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Control de Repuestos',
          subtitle: 'Gestión de inventario de repuestos',
          icon: Icons.inventory,
        ),
      ),
        ),
        // Alertas de Mantenimiento Preventivo
        GoRoute(
          path: '/taller/alertas-mantenimiento',
          name: 'taller_alertas_mantenimiento',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Alertas de Mantenimiento Preventivo',
          subtitle: 'Notificaciones de mantenimiento',
          icon: Icons.notifications_active,
        ),
      ),
        ),
        // Gestión de Proveedores
        GoRoute(
          path: '/taller/proveedores',
          name: 'taller_proveedores',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Gestión de Proveedores',
          subtitle: 'Administración de proveedores',
          icon: Icons.business,
        ),
      ),
        ),

        // ==================== ADMINISTRACIÓN ====================
        // Contratos
        GoRoute(
          path: '/administracion/contratos',
          name: 'administracion_contratos',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ContratosPage(),
      ),
        ),
        // Usuarios y Roles
        GoRoute(
          path: '/administracion/usuarios-roles',
          name: 'administracion_usuarios',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Usuarios y Roles',
          subtitle: 'Gestión de usuarios del sistema',
          icon: Icons.people,
        ),
      ),
        ),
        // Permisos de Acceso
        GoRoute(
          path: '/administracion/permisos-acceso',
          name: 'administracion_permisos',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Permisos de Acceso',
          subtitle: 'Control de permisos',
          icon: Icons.security,
        ),
      ),
        ),
        // Auditorías y Logs
        GoRoute(
          path: '/administracion/auditorias-logs',
          name: 'administracion_auditorias',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Auditorías y Logs',
          subtitle: 'Registro de actividad del sistema',
          icon: Icons.search,
        ),
      ),
        ),
        // Multi-centro / Multi-empresa
        GoRoute(
          path: '/administracion/multicentro',
          name: 'administracion_multicentro',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Multi-centro / Multi-empresa',
          subtitle: 'Gestión multi-organizacional',
          icon: Icons.business_center,
        ),
      ),
        ),
        // Configuración General
        GoRoute(
          path: '/administracion/configuracion-general',
          name: 'administracion_configuracion',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Configuración General',
          subtitle: 'Parámetros del sistema',
          icon: Icons.settings,
        ),
      ),
        ),

        // ==================== OTROS ====================
        // Integraciones
        GoRoute(
          path: '/otros/integraciones',
          name: 'otros_integraciones',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Integraciones',
          subtitle: 'SMS, FCM, mapas y más',
          icon: Icons.integration_instructions,
        ),
      ),
        ),
        // Backups y Restauración
        GoRoute(
          path: '/otros/backups',
          name: 'otros_backups',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Backups y Restauración',
          subtitle: 'Gestión de copias de seguridad',
          icon: Icons.backup,
        ),
      ),
        ),
        // API / Webhooks
        GoRoute(
          path: '/otros/api-webhooks',
          name: 'otros_api',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'API / Webhooks',
          subtitle: 'Configuración de integraciones',
          icon: Icons.api,
        ),
      ),
        ),

        // ==================== CONFIGURACIÓN Y USUARIO ====================
        GoRoute(
          path: '/configuracion',
          name: 'configuracion',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Configuración',
          subtitle: 'Configuración general del sistema',
          icon: Icons.settings,
        ),
      ),
        ),
        GoRoute(
          path: '/perfil',
          name: 'perfil',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Mi Perfil',
          subtitle: 'Gestión de perfil de usuario',
          icon: Icons.person,
        ),
      ),
        ),
        GoRoute(
          path: '/configuracion/cuenta',
          name: 'configuracion_cuenta',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Configuración de Cuenta',
          subtitle: 'Configuración de cuenta de usuario',
          icon: Icons.manage_accounts,
        ),
      ),
        ),

        // ==================== ALMACÉN GENERAL ====================
        // Dashboard de Almacén
        GoRoute(
          path: '/almacen/dashboard',
          name: 'almacen_dashboard',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const AlmacenDashboardPage(),
      ),
        ),
        // Gestión de Proveedores
        GoRoute(
          path: '/almacen/proveedores',
          name: 'almacen_proveedores',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ProveedoresPage(),
      ),
        ),
        // Gestión de Productos (Catálogo)
        GoRoute(
          path: '/almacen/productos',
          name: 'almacen_productos',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const ProductosPage(),
      ),
        ),
        // Movimientos de Stock (Historial)
        GoRoute(
          path: '/almacen/movimientos',
          name: 'almacen_movimientos',
          pageBuilder: (BuildContext context, GoRouterState state) =>
          _buildPageWithTransition(
        key: state.pageKey,
        child: const MovimientosStockPage(),
      ),
        ),

        GoRoute(
          path: '/logout',
          name: 'logout',
          pageBuilder: (BuildContext context, GoRouterState state) => _buildPageWithTransition(
        key: state.pageKey,
        child: const PlaceholderPage(
          title: 'Cerrar Sesión',
          subtitle: 'Proceso de cierre de sesión',
          icon: Icons.logout,
        ),
      ),
        ),
      ],
    ),
  ],
);

/// Extensión para facilitar la navegación
extension NavigationExtension on GoRouter {
  /// Navega a la página de inicio
  void goToHome() => go('/');

  // Agrega más métodos de navegación según necesites
  // void goToProfile() => go('/profile');
}

/// Clase para convertir un Stream en un Listenable para GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Object?> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
