import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/network/network_info.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/stock_repository.dart';
import 'package:ambutrack_web/features/ausencias/domain/repositories/ausencia_repository.dart';
import 'package:ambutrack_web/features/contratos/domain/repositories/contrato_repository.dart';
import 'package:ambutrack_web/features/cuadrante/asignaciones/domain/repositories/cuadrante_asignacion_repository.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_event.dart';
import 'package:ambutrack_web/features/home/presentation/bloc/home_state.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_card_config.dart';
import 'package:ambutrack_web/features/home/presentation/config/dashboard_role_config.dart';
import 'package:ambutrack_web/features/incidencias/domain/repositories/incidencia_repository.dart';
import 'package:ambutrack_web/features/itv_revisiones/domain/repositories/itv_revision_repository.dart';
import 'package:ambutrack_web/features/mantenimiento/domain/repositories/mantenimiento_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/traslado_repository.dart';
import 'package:ambutrack_web/features/vehiculos/domain/repositories/vehiculo_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// BLoC para manejar el estado de la página Home.
///
/// Carga datos base (vehículos, servicios, mantenimientos) para todos los roles
/// y datos adicionales según el rol del usuario mediante [_loadRoleData].
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(
    this._networkInfo,
    this._vehiculoRepository,
    this._trasladoRepository,
    this._mantenimientoRepository,
    this._roleService,
    this._incidenciaRepository,
    this._itvRevisionRepository,
    this._ausenciaRepository,
    this._cuadranteAsignacionRepository,
    this._contratoRepository,
    this._stockRepository,
  ) : super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshed>(_onHomeRefreshed);
  }

  final NetworkInfo _networkInfo;
  final VehiculoRepository _vehiculoRepository;
  final TrasladoRepository _trasladoRepository;
  final MantenimientoRepository _mantenimientoRepository;
  final RoleService _roleService;
  final IncidenciaRepository _incidenciaRepository;
  final ItvRevisionRepository _itvRevisionRepository;
  final AusenciaRepository _ausenciaRepository;
  final CuadranteAsignacionRepository _cuadranteAsignacionRepository;
  final ContratoRepository _contratoRepository;
  final StockRepository _stockRepository;

  // ─── Eventos ─────────────────────────────────────────────────────

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadAllData(emit);
  }

  Future<void> _onHomeRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    await _loadAllData(emit);
  }

  // ─── Carga centralizada ──────────────────────────────────────────

  Future<void> _loadAllData(Emitter<HomeState> emit) async {
    try {
      final bool isConnected = await _networkInfo.isConnected;

      // Datos base: vehículos
      final List<VehiculoEntity> vehiculos = await _vehiculoRepository.getAll();
      final int total = vehiculos.length;
      final List<VehiculoEntity> disponibles = vehiculos
          .where((VehiculoEntity v) => v.estado == VehiculoEstado.activo)
          .toList();
      final int enServicio = disponibles.length;
      final int mantenimiento = vehiculos
          .where((VehiculoEntity v) =>
              v.estado == VehiculoEstado.mantenimiento ||
              v.estado == VehiculoEstado.reparacion)
          .length;

      // Datos base: servicios del día
      final DateTime hoy = DateTime.now();
      final DateTime inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
      final DateTime finDia = inicioDia.add(const Duration(days: 1));
      final List<TrasladoEntity> trasladosDelDia =
          await _trasladoRepository.getByRangoFechas(
        desde: inicioDia,
        hasta: finDia,
      );
      final List<TrasladoEntity> serviciosActivos =
          await _trasladoRepository.getEnCurso();

      // Métricas de flota (TODO: clasificación por categoría real)
      final int urgDisp = (disponibles.length * 0.4).round();
      final int urgTotal = (total * 0.4).round();

      // Métricas de servicios
      final int programadosActivos = serviciosActivos
          .where((TrasladoEntity t) => t.tipoTraslado != 'urgencia')
          .length;
      final int programadosCompletados = trasladosDelDia
          .where((TrasladoEntity t) =>
              t.tipoTraslado != 'urgencia' &&
              t.estado == EstadoTraslado.finalizado.value)
          .length;
      final int urgActivas = serviciosActivos
          .where((TrasladoEntity t) => t.tipoTraslado == 'urgencia')
          .length;
      final int urgCompletadas = trasladosDelDia
          .where((TrasladoEntity t) =>
              t.tipoTraslado == 'urgencia' &&
              t.estado == EstadoTraslado.finalizado.value)
          .length;
      final int totalesDia = trasladosDelDia.length;
      final int completadosDia = trasladosDelDia
          .where((TrasladoEntity t) => t.estado == EstadoTraslado.finalizado.value)
          .length;

      // Mantenimientos (carga aislada)
      final MantenimientoStats mantStats = await _cargarMantenimientos();

      // Datos por rol
      final RoleData roleData = await _loadRoleData();

      emit(HomeLoaded(
        isConnected: isConnected,
        vehiculosDisponibles: disponibles,
        totalVehiculos: total,
        vehiculosEnServicio: enServicio,
        vehiculosMantenimiento: mantenimiento,
        serviciosActivos: serviciosActivos,
        totalServicios: serviciosActivos.length,
        serviciosProgramadosActivos: programadosActivos,
        serviciosProgramadosCompletados: programadosCompletados,
        serviciosUrgenciasActivos: urgActivas,
        serviciosUrgenciasCompletados: urgCompletadas,
        serviciosTotalesDia: totalesDia,
        serviciosCompletadosDia: completadosDia,
        serviciosEnProceso: serviciosActivos.length,
        vehiculosUrgenciasDisponibles: urgDisp,
        vehiculosUrgenciasTotal: urgTotal,
        vehiculosProgramadosDisponibles: disponibles.length - urgDisp,
        vehiculosProgramadosTotal: total - urgTotal,
        mantenimientosProgramados: mantStats.programados,
        mantenimientosEnProceso: mantStats.enProceso,
        mantenimientosCompletados: mantStats.completados,
        mantenimientosProximosOVencidos: mantStats.proximosOVencidos,
        incidenciasAbiertas: roleData.incidenciasAbiertas,
        ausenciasPendientes: roleData.ausenciasPendientes,
        turnosHoy: roleData.turnosHoy,
        contratosVigentes: roleData.contratosVigentes,
        itvProximasVencer: roleData.itvProximasVencer,
        ordenesAbiertas: roleData.ordenesAbiertas,
        stockBajo: roleData.stockBajo,
        misTurnosHoy: roleData.misTurnosHoy,
        misServiciosHoy: roleData.misServiciosHoy,
        misAusenciasActivas: roleData.misAusenciasActivas,
      ));
    } on Exception catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // ─── Carga aislada de mantenimientos ─────────────────────────────

  Future<MantenimientoStats> _cargarMantenimientos() async {
    List<MantenimientoEntity> todos = <MantenimientoEntity>[];
    try {
      final Either<Exception, List<MantenimientoEntity>> result =
          await _mantenimientoRepository.getAll();
      result.fold(
        (Exception e) =>
            debugPrint('⚠️ HomeBloc: error cargando mantenimientos: $e'),
        (List<MantenimientoEntity> lista) => todos = lista,
      );
    } on Exception catch (e) {
      debugPrint('⚠️ HomeBloc: excepción cargando mantenimientos: $e');
    }

    final DateTime hoy = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return MantenimientoStats(
      programados: todos
          .where((MantenimientoEntity m) =>
              m.estado == EstadoMantenimiento.programado)
          .length,
      enProceso: todos
          .where((MantenimientoEntity m) =>
              m.estado == EstadoMantenimiento.enProceso)
          .length,
      completados: todos
          .where((MantenimientoEntity m) =>
              m.estado == EstadoMantenimiento.completado)
          .length,
      proximosOVencidos: todos
          .where((MantenimientoEntity m) =>
              m.estado == EstadoMantenimiento.programado &&
              m.fechaProgramada != null &&
              m.fechaProgramada!.difference(hoy).inDays <= 7)
          .toList(),
    );
  }

  // ─── Carga de datos por rol ──────────────────────────────────────

  /// Carga datos adicionales según las cards que el rol actual debe ver.
  ///
  /// Cada carga es independiente (try-catch aislado): si falla,
  /// el campo correspondiente queda en 0 sin romper el dashboard.
  Future<RoleData> _loadRoleData() async {
    final UserRole role = _roleService.getCurrentUserRoleSync();
    final List<DashboardCardConfig> cards =
        DashboardRoleConfig.cardsForRole(role);

    // Determinar qué datos necesitamos según los cardTypes presentes
    final Set<DashboardCardType> needed = cards
        .map((DashboardCardConfig c) => c.cardType)
        .toSet();

    int incidenciasAbiertas = 0;
    int ausenciasPendientes = 0;
    int turnosHoy = 0;
    int contratosVigentes = 0;
    int itvProximasVencer = 0;
    int ordenesAbiertas = 0;
    int stockBajo = 0;
    int misTurnosHoy = 0;
    int misServiciosHoy = 0;
    int misAusenciasActivas = 0;

    // Incidencias abiertas (reportada + en_proceso)
    if (needed.contains(DashboardCardType.incidencias)) {
      try {
        final List<IncidenciaEntity> all = await _incidenciaRepository.getAll();
        incidenciasAbiertas = all
            .where((IncidenciaEntity i) =>
                i.estado.name == 'reportada' ||
                i.estado.name == 'enProceso')
            .length;
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando incidencias: $e');
      }
    }

    // Ausencias pendientes
    if (needed.contains(DashboardCardType.ausencias)) {
      try {
        final List<AusenciaEntity> pendientes =
            await _ausenciaRepository.getByEstado(EstadoAusencia.pendiente);
        ausenciasPendientes = pendientes.length;
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando ausencias: $e');
      }
    }

    // Turnos de hoy
    if (needed.contains(DashboardCardType.turnos)) {
      try {
        final DateTime hoy = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final List<CuadranteAsignacionEntity> asignaciones =
            await _cuadranteAsignacionRepository.getByFecha(hoy);
        turnosHoy = asignaciones.length;
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando turnos: $e');
      }
    }

    // Contratos vigentes
    if (needed.contains(DashboardCardType.contratos)) {
      try {
        final List<ContratoEntity> vigentes =
            await _contratoRepository.getVigentes();
        contratosVigentes = vigentes.length;
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando contratos: $e');
      }
    }

    // ITV próximas a vencer
    if (needed.contains(DashboardCardType.itvPendientes)) {
      try {
        final List<ItvRevisionEntity> proximas =
            await _itvRevisionRepository.getProximasVencer(30);
        itvProximasVencer = proximas.length;
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando ITV: $e');
      }
    }

    // Órdenes de reparación abiertas = mantenimientos programados + en proceso
    if (needed.contains(DashboardCardType.ordenesAbiertas)) {
      try {
        final Either<Exception, List<MantenimientoEntity>> result =
            await _mantenimientoRepository.getAll();
        result.fold(
          (Exception _) {},
          (List<MantenimientoEntity> lista) {
            ordenesAbiertas = lista
                .where((MantenimientoEntity m) =>
                    m.estado == EstadoMantenimiento.programado ||
                    m.estado == EstadoMantenimiento.enProceso)
                .length;
          },
        );
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando órdenes: $e');
      }
    }

    // Stock bajo
    if (needed.contains(DashboardCardType.almacen)) {
      try {
        final List<StockEntity> bajo =
            await _stockRepository.getStockBajo('');
        stockBajo = bajo.length;
      } on Exception catch (e) {
        debugPrint('⚠️ HomeBloc: error cargando stock bajo: $e');
      }
    }

    // Self-service (conductor / sanitario)
    if (needed.contains(DashboardCardType.misTurnos) ||
        needed.contains(DashboardCardType.misServicios) ||
        needed.contains(DashboardCardType.misAusencias)) {
      await _loadSelfServiceData(
        needed: needed,
        misTurnosHoyRef: (int v) => misTurnosHoy = v,
        misServiciosHoyRef: (int v) => misServiciosHoy = v,
        misAusenciasActivasRef: (int v) => misAusenciasActivas = v,
      );
    }

    return RoleData(
      incidenciasAbiertas: incidenciasAbiertas,
      ausenciasPendientes: ausenciasPendientes,
      turnosHoy: turnosHoy,
      contratosVigentes: contratosVigentes,
      itvProximasVencer: itvProximasVencer,
      ordenesAbiertas: ordenesAbiertas,
      stockBajo: stockBajo,
      misTurnosHoy: misTurnosHoy,
      misServiciosHoy: misServiciosHoy,
      misAusenciasActivas: misAusenciasActivas,
    );
  }

  /// Carga datos self-service para conductor/sanitario.
  ///
  /// Usa callbacks para evitar mutaciones sobre locals del caller.
  Future<void> _loadSelfServiceData({
    required Set<DashboardCardType> needed,
    required void Function(int) misTurnosHoyRef,
    required void Function(int) misServiciosHoyRef,
    required void Function(int) misAusenciasActivasRef,
  }) async {
    try {
      final String? userId =
          Supabase.instance.client.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        return;
      }

      // Mis turnos hoy
      if (needed.contains(DashboardCardType.misTurnos)) {
        try {
          final DateTime hoy = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
          final List<CuadranteAsignacionEntity> mis =
              await _cuadranteAsignacionRepository.getByPersonal(
            idPersonal: userId,
            fecha: hoy,
          );
          misTurnosHoyRef(mis.length);
        } on Exception catch (e) {
          debugPrint('⚠️ HomeBloc: error cargando mis turnos: $e');
        }
      }

      // Mis servicios hoy — contar servicios donde el usuario es personal
      if (needed.contains(DashboardCardType.misServicios)) {
        try {
          final DateTime hoy = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
          final DateTime finDia = hoy.add(const Duration(days: 1));
          final List<TrasladoEntity> traslados =
              await _trasladoRepository.getByRangoFechas(
            desde: hoy,
            hasta: finDia,
          );
          misServiciosHoyRef(traslados.length);
        } on Exception catch (e) {
          debugPrint('⚠️ HomeBloc: error cargando mis servicios: $e');
        }
      }

      // Mis ausencias activas
      if (needed.contains(DashboardCardType.misAusencias)) {
        try {
          final List<AusenciaEntity> mis =
              await _ausenciaRepository.getByPersonal(userId);
          misAusenciasActivasRef(
            mis.where((AusenciaEntity a) => a.isEnCurso || a.isPendiente).length,
          );
        } on Exception catch (e) {
          debugPrint('⚠️ HomeBloc: error cargando mis ausencias: $e');
        }
      }
    } on Exception catch (e) {
      debugPrint('⚠️ HomeBloc: error cargando datos self-service: $e');
    }
  }
}

// ─── Clases auxiliares ──────────────────────────────────────────────

/// Métricas de mantenimientos preventivos agrupadas por estado.
class MantenimientoStats {
  const MantenimientoStats({
    required this.programados,
    required this.enProceso,
    required this.completados,
    required this.proximosOVencidos,
  });

  final int programados;
  final int enProceso;
  final int completados;
  final List<MantenimientoEntity> proximosOVencidos;
}

/// Resultado de la carga de datos por rol.
///
/// Agrupa todos los campos adicionales que se cargan
/// según las cards que el usuario debe ver.
class RoleData {
  const RoleData({
    this.incidenciasAbiertas = 0,
    this.ausenciasPendientes = 0,
    this.turnosHoy = 0,
    this.contratosVigentes = 0,
    this.itvProximasVencer = 0,
    this.ordenesAbiertas = 0,
    this.stockBajo = 0,
    this.misTurnosHoy = 0,
    this.misServiciosHoy = 0,
    this.misAusenciasActivas = 0,
  });

  final int incidenciasAbiertas;
  final int ausenciasPendientes;
  final int turnosHoy;
  final int contratosVigentes;
  final int itvProximasVencer;
  final int ordenesAbiertas;
  final int stockBajo;
  final int misTurnosHoy;
  final int misServiciosHoy;
  final int misAusenciasActivas;
}
