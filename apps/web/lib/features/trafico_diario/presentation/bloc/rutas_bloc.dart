import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/services/routing_service.dart';
import '../../../../core/services/ruta_service.dart';
import '../models/traslado_con_ruta_info.dart';
import 'rutas_event.dart';
import 'rutas_state.dart';

/// BLoC para gestión de rutas de técnicos
@injectable
class RutasBloc extends Bloc<RutasEvent, RutasState> {

  RutasBloc({
    required TrasladoDataSource trasladoDataSource,
    required TPersonalDataSource personalDataSource,
    required VehiculoDataSource vehiculoDataSource,
    required RutaService rutaService,
    required GeocodingService geocodingService,
    required RoutingService routingService,
  })  : _trasladoDataSource = trasladoDataSource,
        _personalDataSource = personalDataSource,
        _vehiculoDataSource = vehiculoDataSource,
        _rutaService = rutaService,
        _geocodingService = geocodingService,
        _routingService = routingService,
        super(const RutasState.initial()) {
    on<RutasEvent>(_onEvent);
  }
  final TrasladoDataSource _trasladoDataSource;
  final TPersonalDataSource _personalDataSource;
  final VehiculoDataSource _vehiculoDataSource;
  final RutaService _rutaService;
  final GeocodingService _geocodingService;
  final RoutingService _routingService;

  Future<void> _onEvent(RutasEvent event, Emitter<RutasState> emit) async {
    await event.when(
      started: () => _onStarted(emit),
      cargarRutaRequested: (String tecnicoId, DateTime fecha, String? turno) =>
          _onCargarRutaRequested(emit, tecnicoId, fecha, turno),
      optimizarRutaRequested: () => _onOptimizarRutaRequested(emit),
      reordenarTrasladosRequested: (List<String> nuevoOrdenIds) =>
          _onReordenarTrasladosRequested(emit, nuevoOrdenIds),
      refreshRequested: () => _onRefreshRequested(emit),
      limpiarRuta: () => _onLimpiarRuta(emit),
    );
  }

  Future<void> _onStarted(Emitter<RutasState> emit) async {
    debugPrint('🚀 RutasBloc: Iniciado');
    emit(const RutasState.initial());
  }

  Future<void> _onCargarRutaRequested(
    Emitter<RutasState> emit,
    String tecnicoId,
    DateTime fecha,
    String? turno,
  ) async {
    try {
      debugPrint('📍 RutasBloc: Cargando ruta para técnico $tecnicoId en $fecha (turno: $turno)');
      emit(const RutasState.loading());

      // Obtener información del técnico
      final TPersonalEntity? tecnico = await _personalDataSource.getById(tecnicoId);
      if (tecnico == null) {
        emit(const RutasState.error(message: 'No se encontró el técnico'));
        return;
      }

      debugPrint('👤 Técnico encontrado: ${tecnico.nombreCompleto}');

      // Obtener traslados del técnico en la fecha
      final List<TrasladoEntity> traslados = await _obtenerTrasladosTecnico(
        tecnicoId: tecnicoId,
        fecha: fecha,
        turno: turno,
      );

      if (traslados.isEmpty) {
        emit(RutasState.empty(
          mensaje: 'No hay traslados asignados a ${tecnico.nombreCompleto} para esta fecha',
          tecnicoNombre: tecnico.nombreCompleto,
          fecha: fecha,
        ));
        return;
      }

      debugPrint('📋 Traslados encontrados: ${traslados.length}');

      // Obtener vehículo asignado (del primer traslado)
      String? vehiculoMatricula;
      if (traslados.first.idVehiculo != null) {
        final VehiculoEntity? vehiculo = await _vehiculoDataSource.getById(traslados.first.idVehiculo!);
        vehiculoMatricula = vehiculo?.matricula;
      }

      // Procesar traslados y calcular ruta
      final List<TrasladoConRutaInfo> trasladosConRuta = await _procesarTrasladosConRuta(traslados);

      // Calcular resumen
      final RutaResumen resumen = _rutaService.calcularResumenRuta(
        traslados: trasladosConRuta,
      );

      debugPrint('✅ Ruta calculada exitosamente');
      debugPrint('   - Distancia total: ${resumen.distanciaTotalKm.toStringAsFixed(2)} km');
      debugPrint('   - Tiempo total: ${resumen.tiempoTotalFormateado}');

      emit(RutasState.loaded(
        tecnicoId: tecnicoId,
        tecnicoNombre: tecnico.nombreCompleto,
        vehiculoMatricula: vehiculoMatricula,
        fecha: fecha,
        turno: turno,
        traslados: trasladosConRuta,
        resumen: resumen,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar ruta: $e');
      debugPrint('StackTrace: $stackTrace');
      emit(RutasState.error(
        message: 'Error al cargar la ruta: ${e.toString()}',
        tecnicoId: tecnicoId,
        fecha: fecha,
      ));
    }
  }

  Future<void> _onOptimizarRutaRequested(Emitter<RutasState> emit) async {
    await state.whenOrNull(
      loaded: (String tecnicoId, String tecnicoNombre, String? vehiculoMatricula, DateTime fecha, String? turno, List<TrasladoConRutaInfo> traslados, RutaResumen resumen, bool isOptimizando, RutaResumen? resumenAnterior) async {
        try {
          debugPrint('🔄 Optimizando ruta...');
          emit(RutasState.loaded(
            tecnicoId: tecnicoId,
            tecnicoNombre: tecnicoNombre,
            vehiculoMatricula: vehiculoMatricula,
            fecha: fecha,
            turno: turno,
            traslados: traslados,
            resumen: resumen,
            isOptimizando: true,
            resumenAnterior: resumenAnterior,
          ));

          // Optimizar ruta respetando horarios
          final List<TrasladoConRutaInfo> trasladosOptimizados = _rutaService.optimizarRuta(
            traslados: traslados,
          );

          // Recalcular métricas con el nuevo orden
          final List<TrasladoConRutaInfo> trasladosRecalculados = await _procesarTrasladosConRuta(
            trasladosOptimizados.map((TrasladoConRutaInfo t) => t.traslado).toList(),
          );

          final RutaResumen nuevoResumen = _rutaService.calcularResumenRuta(
            traslados: trasladosRecalculados,
          );

          debugPrint('✅ Ruta optimizada');
          debugPrint('   - Mejora de distancia: ${(resumen.distanciaTotalKm - nuevoResumen.distanciaTotalKm).toStringAsFixed(2)} km');
          debugPrint('   - Mejora de tiempo: ${resumen.tiempoTotalMinutos - nuevoResumen.tiempoTotalMinutos} min');
          debugPrint('   - Retrasos antes: ${resumen.trasladosConRetraso.length}');
          debugPrint('   - Retrasos después: ${nuevoResumen.trasladosConRetraso.length}');

          emit(RutasState.loaded(
            tecnicoId: tecnicoId,
            tecnicoNombre: tecnicoNombre,
            vehiculoMatricula: vehiculoMatricula,
            fecha: fecha,
            turno: turno,
            traslados: trasladosRecalculados,
            resumen: nuevoResumen,
            resumenAnterior: resumen, // Guardar resumen anterior para comparativa
          ));
        } catch (e) {
          debugPrint('❌ Error al optimizar ruta: $e');
          emit(RutasState.loaded(
            tecnicoId: tecnicoId,
            tecnicoNombre: tecnicoNombre,
            vehiculoMatricula: vehiculoMatricula,
            fecha: fecha,
            turno: turno,
            traslados: traslados,
            resumen: resumen,
            resumenAnterior: resumenAnterior,
          ));
        }
      },
    );
  }

  Future<void> _onReordenarTrasladosRequested(
    Emitter<RutasState> emit,
    List<String> nuevoOrdenIds,
  ) async {
    await state.whenOrNull(
      loaded: (String tecnicoId, String tecnicoNombre, String? vehiculoMatricula, DateTime fecha, String? turno, List<TrasladoConRutaInfo> traslados, RutaResumen resumen, bool isOptimizando, RutaResumen? resumenAnterior) async {
        try {
          debugPrint('🔄 Reordenando traslados manualmente...');

          // Reordenar según el nuevo orden
          final List<TrasladoConRutaInfo> trasladosReordenados = <TrasladoConRutaInfo>[];
          for (final String id in nuevoOrdenIds) {
            final TrasladoConRutaInfo traslado = traslados.firstWhere((TrasladoConRutaInfo t) => t.traslado.id == id);
            trasladosReordenados.add(traslado);
          }

          // Recalcular métricas con el nuevo orden
          final List<TrasladoConRutaInfo> trasladosRecalculados = await _procesarTrasladosConRuta(
            trasladosReordenados.map((TrasladoConRutaInfo t) => t.traslado).toList(),
          );

          final RutaResumen nuevoResumen = _rutaService.calcularResumenRuta(
            traslados: trasladosRecalculados,
          );

          debugPrint('✅ Traslados reordenados manualmente');

          emit(RutasState.loaded(
            tecnicoId: tecnicoId,
            tecnicoNombre: tecnicoNombre,
            vehiculoMatricula: vehiculoMatricula,
            fecha: fecha,
            turno: turno,
            traslados: trasladosRecalculados,
            resumen: nuevoResumen,
            resumenAnterior: resumenAnterior,
          ));
        } catch (e) {
          debugPrint('❌ Error al reordenar traslados: $e');
        }
      },
    );
  }

  Future<void> _onRefreshRequested(Emitter<RutasState> emit) async {
    await state.whenOrNull(
      loaded: (String tecnicoId, String tecnicoNombre, String? vehiculoMatricula, DateTime fecha, String? turno, List<TrasladoConRutaInfo> traslados, RutaResumen resumen, bool isOptimizando, RutaResumen? resumenAnterior) async {
        debugPrint('🔄 Refrescando ruta...');
        await _onCargarRutaRequested(emit, tecnicoId, fecha, turno);
      },
    );
  }

  Future<void> _onLimpiarRuta(Emitter<RutasState> emit) async {
    debugPrint('🧹 Limpiando ruta');
    emit(const RutasState.initial());
  }

  /// Obtiene traslados de un técnico en una fecha específica
  Future<List<TrasladoEntity>> _obtenerTrasladosTecnico({
    required String tecnicoId,
    required DateTime fecha,
    String? turno,
  }) async {
    debugPrint('📦 Obteniendo traslados del técnico...');

    // Obtener todos los traslados y filtrar por fecha y técnico
    final List<TrasladoEntity> todosTraslados = await _trasladoDataSource.getAll();

    // Filtrar por técnico/conductor y fecha
    final List<TrasladoEntity> trasladosTecnico = todosTraslados
        .where((TrasladoEntity t) {
          // Filtrar por conductor
          if (t.idPersonalConductor != tecnicoId) {
            return false;
          }

          // Filtrar por fecha (comparar solo día, mes y año)
          if (t.fecha != null) {
            final DateTime trasladoFecha = t.fecha!;
            return trasladoFecha.year == fecha.year &&
                trasladoFecha.month == fecha.month &&
                trasladoFecha.day == fecha.day;
          }

          return false;
        })
        .toList();

    // Si se especifica turno, filtrar además por horario
    if (turno != null && turno.isNotEmpty) {
      return _filtrarPorTurno(trasladosTecnico, turno);
    }

    // Ordenar por hora programada
    trasladosTecnico.sort((TrasladoEntity a, TrasladoEntity b) {
      if (a.horaProgramada == null && b.horaProgramada == null) {
        return 0;
      }
      if (a.horaProgramada == null) {
        return 1;
      }
      if (b.horaProgramada == null) {
        return -1;
      }
      return a.horaProgramada!.compareTo(b.horaProgramada!);
    });

    return trasladosTecnico;
  }

  /// Filtra traslados por turno basándose en la hora programada
  List<TrasladoEntity> _filtrarPorTurno(List<TrasladoEntity> traslados, String turno) {
    return traslados.where((TrasladoEntity t) {
      if (t.horaProgramada == null) {
        return false;
      }

      final int hora = t.horaProgramada!.hour;

      switch (turno.toLowerCase()) {
        case 'mañana':
        case 'manana':
          return hora >= 6 && hora < 14;
        case 'tarde':
          return hora >= 14 && hora < 22;
        case 'noche':
          return hora >= 22 || hora < 6;
        default:
          return true;
      }
    }).toList();
  }

  /// Procesa traslados y calcula información de ruta
  Future<List<TrasladoConRutaInfo>> _procesarTrasladosConRuta(
    List<TrasladoEntity> traslados,
  ) async {
    final List<TrasladoConRutaInfo> trasladosConRuta = <TrasladoConRutaInfo>[];

    for (int i = 0; i < traslados.length; i++) {
      final TrasladoEntity traslado = traslados[i];

      // Obtener puntos de origen y destino
      final PuntoUbicacion origen = await _obtenerPuntoUbicacion(
        traslado.origen ?? 'Origen desconocido',
        traslado.tipoOrigen,
      );

      final PuntoUbicacion destino = await _obtenerPuntoUbicacion(
        traslado.destino ?? 'Destino desconocido',
        traslado.tipoDestino,
      );

      // Calcular ruta real por carretera usando OpenRouteService
      List<LatLng>? geometriaRuta;
      try {
        debugPrint('🚗 Calculando ruta real para traslado ${i + 1}...');
        final RutaCalculada ruta = await _routingService.calcularRuta(
          origen: RutaPunto(
            latitud: origen.latitud,
            longitud: origen.longitud,
            nombre: origen.nombre,
          ),
          destino: RutaPunto(
            latitud: destino.latitud,
            longitud: destino.longitud,
            nombre: destino.nombre,
          ),
        );

        geometriaRuta = ruta.geometria;

        debugPrint(
          '✅ Ruta real calculada: ${ruta.distanciaKm.toStringAsFixed(2)} km, '
          '${ruta.duracionMinutos.toStringAsFixed(1)} min, '
          '${ruta.geometria.length} puntos',
        );
      } catch (e) {
        debugPrint('⚠️ Error calculando ruta real: $e');
        debugPrint('📍 Se usará línea recta como fallback');
        // Si falla el routing, geometriaRuta queda null y se usará línea recta
      }

      // Calcular distancia desde el punto anterior
      double? distanciaDesdeAnterior;
      int? tiempoDesdeAnterior;

      if (i > 0) {
        final TrasladoConRutaInfo trasladoAnterior = trasladosConRuta[i - 1];
        distanciaDesdeAnterior = _rutaService.calcularDistanciaEntrePuntos(
          punto1: trasladoAnterior.destino,
          punto2: origen,
        );
        tiempoDesdeAnterior = _rutaService.calcularTiempoEstimado(
          distanciaKm: distanciaDesdeAnterior,
        );
      }

      // Calcular distancia del traslado (origen → destino)
      final double distanciaTrasladoKm = _rutaService.calcularDistanciaEntrePuntos(
        punto1: origen,
        punto2: destino,
      );

      final int tiempoTrasladoMinutos = _rutaService.calcularTiempoEstimado(
        distanciaKm: distanciaTrasladoKm,
      );

      // Calcular hora estimada de llegada
      DateTime? horaEstimadaLlegada;
      if (i == 0) {
        // Primer traslado: hora programada + tiempo del traslado
        if (traslado.horaProgramada != null) {
          horaEstimadaLlegada = traslado.horaProgramada!.add(
            Duration(minutes: tiempoTrasladoMinutos),
          );
        }
      } else {
        // Traslados siguientes: hora llegada anterior + tiempo desde anterior + tiempo traslado
        final DateTime? horaLlegadaAnterior = trasladosConRuta[i - 1].horaEstimadaLlegada;
        if (horaLlegadaAnterior != null && tiempoDesdeAnterior != null) {
          horaEstimadaLlegada = horaLlegadaAnterior.add(
            Duration(minutes: tiempoDesdeAnterior + tiempoTrasladoMinutos),
          );
        }
      }

      trasladosConRuta.add(
        TrasladoConRutaInfo(
          orden: i + 1,
          traslado: traslado,
          origen: origen,
          destino: destino,
          distanciaDesdeAnteriorKm: distanciaDesdeAnterior,
          tiempoDesdeAnteriorMinutos: tiempoDesdeAnterior,
          horaEstimadaLlegada: horaEstimadaLlegada,
          distanciaTotalTrasladoKm: distanciaTrasladoKm,
          tiempoTotalTrasladoMinutos: tiempoTrasladoMinutos,
          geometriaRuta: geometriaRuta,
        ),
      );
    }

    return trasladosConRuta;
  }

  /// Obtiene punto de ubicación con coordenadas REALES usando geocodificación
  ///
  /// Usa Nominatim (OpenStreetMap) para obtener coordenadas precisas
  Future<PuntoUbicacion> _obtenerPuntoUbicacion(
    String nombreUbicacion,
    String? tipo,
  ) async {
    try {
      debugPrint('🌍 Obteniendo coordenadas para: "$nombreUbicacion"');

      // Extraer contexto del nombre si está disponible
      String? contexto;
      if (nombreUbicacion.toUpperCase().contains('BÁRBATE') ||
          nombreUbicacion.toUpperCase().contains('BARBATE')) {
        contexto = 'Bárbate';
      } else if (tipo == 'hospital' || tipo == 'centro salud') {
        // Para hospitales, añadir contexto de la provincia
        contexto = 'Cádiz';
      }

      // Usar geocodificación real con Nominatim y contexto
      final Map<String, double> coordenadas =
          await _geocodingService.obtenerCoordenadas(
        query: nombreUbicacion,
        contexto: contexto,
          );

      return PuntoUbicacion(
        nombre: nombreUbicacion,
        latitud: coordenadas['lat']!,
        longitud: coordenadas['lng']!,
        tipo: tipo,
      );
    } catch (e) {
      // Fallback a coordenadas aproximadas si falla la geocodificación
      debugPrint('⚠️ Error en geocodificación: $e');
      debugPrint('📍 Usando coordenadas fallback para: "$nombreUbicacion"');

      // Coordenadas fallback basadas en hash (para que sean consistentes)
      return _obtenerCoordenadasFallback(nombreUbicacion, tipo);
    }
  }

  /// Coordenadas de fallback cuando falla la geocodificación
  ///
  /// Genera coordenadas "aleatorias" pero consistentes basadas en el hash
  /// del nombre para que siempre sean las mismas para la misma ubicación
  PuntoUbicacion _obtenerCoordenadasFallback(
    String nombre,
    String? tipo,
  ) {
    // Generar hash consistente para esta ubicación
    final int hash = nombre.hashCode.abs();

    // Coordenadas base (centro aprox de España)
    const double latBase = 40.0;
    const double lngBase = -3.0;

    // Variar ±0.5 grados (aprox ±55 km) para dispersión por España
    final double latOffset = hash % 1000 / 1000 - 0.5;
    final double lngOffset = hash ~/ 1000 % 1000 / 1000 - 0.5;

    return PuntoUbicacion(
      nombre: nombre,
      latitud: latBase + latOffset,
      longitud: lngBase + lngOffset,
      tipo: tipo,
    );
  }
}
