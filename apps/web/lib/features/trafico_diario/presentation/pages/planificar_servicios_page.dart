import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_bloc.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_event.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/servicio_form_wizard_dialog.dart';
import 'package:ambutrack_web/features/tablas/centros_hospitalarios/domain/repositories/centro_hospitalario_repository.dart';
import 'package:ambutrack_web/features/tablas/localidades/domain/repositories/localidad_repository.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_bloc.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_event.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_state.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/servicios_header.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/servicios_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de planificación de servicios
///
/// Permite visualizar los servicios del día y asignar conductor/vehículo
/// Layout: Servicios pendientes arriba + Conductores con servicios abajo
class PlanificarServiciosPage extends StatelessWidget {
  const PlanificarServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        // Servic BLoC para cargar la lista de servicios recurrentes
        BlocProvider<ServiciosBloc>(
          create: (_) => getIt<ServiciosBloc>()
            ..add(const ServiciosEvent.estadoFilterChanged(estado: 'ACTIVO')),
        ),
        // TraficoDiario BLoC para gestionar traslados
        BlocProvider<TraficoDiarioBloc>(
          create: (_) => getIt<TraficoDiarioBloc>()..add(const TraficoDiarioEvent.started()),
        ),
      ],
      child: const SafeArea(
        child: _PlanificarServiciosView(),
      ),
    );
  }
}

/// Vista principal de planificación de servicios
class _PlanificarServiciosView extends StatefulWidget {
  const _PlanificarServiciosView();

  @override
  State<_PlanificarServiciosView> createState() =>
      _PlanificarServiciosViewState();
}

class _PlanificarServiciosViewState extends State<_PlanificarServiciosView> {
  DateTime _selectedDay = DateTime.now();

  // Set de IDs de traslados seleccionados para asignación múltiple
  final Set<String> _trasladosSeleccionados = <String>{};

  // Mapa para guardar los servicios originales por ID de traslado
  final Map<String, ServicioEntity> _serviciosPorTraslado = <String, ServicioEntity>{};

  // Mapas de cache para datos auxiliares
  final Map<String, String> _localidadesPorId = <String, String>{};
  final Map<String, String> _personalPorId = <String, String>{};
  final Map<String, String> _localidadesHospitalesPorId = <String, String>{};
  final Map<String, String> _hospitalesPorId = <String, String>{};
  final Map<String, String> _localidadesPorNombreHospital = <String, String>{};

  // Flag para rastrear si ya se solicitó cargar traslados (evita bucle infinito)
  bool _trasladosAlreadyRequested = false;

  @override
  void initState() {
    super.initState();
    debugPrint('📅 PlanificarServiciosPage: Inicializada');
    _cargarDatosAuxiliares();
  }

  /// Carga datos auxiliares para la tabla (localidades, personal y hospitales)
  /// usando los repositorios correspondientes (arquitectura limpia)
  Future<void> _cargarDatosAuxiliares() async {
    try {
      await Future.wait<void>(<Future<void>>[
        _cargarLocalidades(),
        _cargarPersonal(),
        _cargarHospitales(),
      ]);
    } catch (e) {
      debugPrint('⚠️ Error cargando datos auxiliares: $e');
    }
  }

  /// Carga todas las localidades usando LocalidadRepository
  Future<void> _cargarLocalidades() async {
    try {
      final LocalidadRepository repository = getIt<LocalidadRepository>();
      final List<LocalidadEntity> localidades = await repository.getAll();

      for (final LocalidadEntity localidad in localidades) {
        _localidadesPorId[localidad.id] = localidad.nombre;
      }

      debugPrint('✅ Cargadas ${_localidadesPorId.length} localidades');
    } catch (e) {
      debugPrint('⚠️ Error cargando localidades: $e');
    }
  }

  /// Carga todo el personal usando PersonalRepository
  Future<void> _cargarPersonal() async {
    try {
      final PersonalRepository repository = getIt<PersonalRepository>();
      final List<PersonalEntity> personal = await repository.getAll();

      for (final PersonalEntity persona in personal) {
        _personalPorId[persona.id] = persona.nombreCompleto;
      }

      debugPrint('✅ Cargado ${_personalPorId.length} registros de personal');
    } catch (e) {
      debugPrint('⚠️ Error cargando personal: $e');
    }
  }

  /// Carga todos los centros hospitalarios usando CentroHospitalarioRepository
  Future<void> _cargarHospitales() async {
    try {
      final CentroHospitalarioRepository repository = getIt<CentroHospitalarioRepository>();
      final List<CentroHospitalarioEntity> hospitales = await repository.getAll();

      for (final CentroHospitalarioEntity hospital in hospitales) {
        _hospitalesPorId[hospital.id] = hospital.nombre;

        // Guardar localidad del hospital si existe
        if (hospital.localidadNombre != null && hospital.localidadNombre!.isNotEmpty) {
          _localidadesHospitalesPorId[hospital.id] = hospital.localidadNombre!;
          _localidadesPorNombreHospital[hospital.nombre] = hospital.localidadNombre!;

          debugPrint('   🏥 ${hospital.nombre} → ${hospital.localidadNombre}');
        } else {
          debugPrint('   ⚠️ ${hospital.nombre} SIN localidad');
        }
      }

      debugPrint('✅ Cargados ${_hospitalesPorId.length} hospitales');
      debugPrint('📍 Mapa localidades por hospital: $_localidadesPorNombreHospital');
    } catch (e) {
      debugPrint('⚠️ Error cargando hospitales: $e');
    }
  }

  /// Abre el formulario de edición de servicio
  Future<void> _editarServicio(BuildContext parentContext, ServicioEntity servicio) async {
    debugPrint('✏️ Editando servicio: ${servicio.id}');

    final ServiciosBloc bloc = parentContext.read<ServiciosBloc>();

    await showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ServicioFormWizardDialog(
          servicio: servicio,
          paciente: servicio.paciente,
        );
      },
    );

    // Recargar datos después de la edición
    if (mounted) {
      _trasladosAlreadyRequested = false;
      bloc.add(const ServiciosEvent.estadoFilterChanged(estado: 'ACTIVO'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiciosBloc, ServiciosState>(
      builder: (BuildContext context, ServiciosState serviciosState) {
        // Cargar traslados cuando se carguen los servicios
        serviciosState.whenOrNull(
          loaded: (
            List<ServicioEntity> servicios,
            String searchQuery,
            int? yearFilter,
            String? estadoFilter,
            bool isRefreshing,
            ServicioEntity? selectedServicio,
            bool isLoadingDetails,
          ) {
            // Si hay servicios cargados y aún no hemos solicitado traslados, cargarlos
            if (servicios.isNotEmpty && !_trasladosAlreadyRequested) {
              final List<String> servicioIds = servicios
                  .map((ServicioEntity s) => s.id)
                  .whereType<String>()  // Filtrar nulls
                  .toList();
              debugPrint('🔄 Disparando evento para cargar traslados de ${servicioIds.length} servicios');

              // Marcar como ya solicitado
              if (!_trasladosAlreadyRequested) {
                _trasladosAlreadyRequested = true;

                // Usar addPostFrameCallback para evitar llamar add() durante build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && context.mounted) {
                    try {
                      context.read<TraficoDiarioBloc>().add(
                            TraficoDiarioEvent.loadTrasladosRequested(
                              idsServiciosRecurrentes: servicioIds,
                              fecha: _selectedDay,
                            ),
                          );
                    } catch (e) {
                      debugPrint('⚠️ Error al disparar evento de carga de traslados: $e');
                    }
                  }
                });
              }
            }

            // Guardar mapa de servicios por traslado
            for (final ServicioEntity servicio in servicios) {
              if (servicio.id != null) {
                // Este mapeo se usará en la tabla
              }
            }
          },
        );

        return BlocBuilder<TraficoDiarioBloc, TraficoDiarioState>(
          builder: (BuildContext context, TraficoDiarioState traficoDiarioState) {
            List<TrasladoEntity> trasladosPendientes = <TrasladoEntity>[];

            traficoDiarioState.whenOrNull(
              loaded: (List<TrasladoEntity> traslados, String searchQuery, String? estadoFilter, String? centroFilter, bool isRefreshing) {
                debugPrint('📅 TraficoDiarioBloc loaded: ${traslados.length} traslados');

                // Filtrar traslados para el día seleccionado directamente del BLoC
                final DateTime selectedDayKey = DateTime(
                  _selectedDay.year,
                  _selectedDay.month,
                  _selectedDay.day,
                );

                trasladosPendientes = traslados.where((TrasladoEntity traslado) {
                  if (traslado.fecha == null) return false;
                  final DateTime trasladoKey = DateTime(
                    traslado.fecha!.year,
                    traslado.fecha!.month,
                    traslado.fecha!.day,
                  );
                  return trasladoKey == selectedDayKey;
                }).toList();

                debugPrint('🔍 Traslados filtrados para ${selectedDayKey.toIso8601String().split('T')[0]}: ${trasladosPendientes.length}');

                // Actualizar mapa de servicios por traslado
                serviciosState.whenOrNull(
                  loaded: (
                    List<ServicioEntity> servicios,
                    String searchQuery,
                    int? yearFilter,
                    String? estadoFilter,
                    bool isRefreshing,
                    ServicioEntity? selectedServicio,
                    bool isLoadingDetails,
                  ) {
                    _serviciosPorTraslado.clear();
                    for (final TrasladoEntity traslado in traslados) {
                      // ✅ FIX: Usar idServicio (tabla servicios), NO idServicioRecurrente (otra tabla)
                      // El ServicioEntity.id corresponde a la tabla 'servicios'
                      // traslado.idServicio apunta a 'servicios', no a 'servicios_recurrentes'
                      final Iterable<ServicioEntity> matches = servicios.where(
                        (ServicioEntity s) => s.id == traslado.idServicio,
                      );
                      if (matches.isNotEmpty) {
                        _serviciosPorTraslado[traslado.id] = matches.first;
                        debugPrint('✅ Match encontrado: traslado ${traslado.id.substring(0, 8)} → servicio ${matches.first.id?.substring(0, 8)}');
                      } else {
                        debugPrint('⚠️ Sin match para traslado ${traslado.id.substring(0, 8)}: idServicio=${traslado.idServicio}, idServicioRecurrente=${traslado.idServicioRecurrente}');
                      }
                    }
                  },
                );
              },
            );

            return Scaffold(
              backgroundColor: AppColors.backgroundLight,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header con selector de fecha
                    ServiciosHeader(
                      selectedDay: _selectedDay,
                      onDayChanged: (DateTime newDay) {
                        setState(() {
                          _selectedDay = newDay;
                          // Resetear flag cuando cambia la fecha para permitir nueva carga
                          _trasladosAlreadyRequested = false;
                        });

                        // Recargar traslados para la nueva fecha
                        serviciosState.whenOrNull(
                          loaded: (
                            List<ServicioEntity> servicios,
                            String searchQuery,
                            int? yearFilter,
                            String? estadoFilter,
                            bool isRefreshing,
                            ServicioEntity? selectedServicio,
                            bool isLoadingDetails,
                          ) {
                            if (servicios.isNotEmpty) {
                              final List<String> servicioIds = servicios
                                  .map((ServicioEntity s) => s.id)
                                  .whereType<String>()
                                  .toList();

                              context.read<TraficoDiarioBloc>().add(
                                    TraficoDiarioEvent.loadTrasladosRequested(
                                      idsServiciosRecurrentes: servicioIds,
                                      fecha: newDay,
                                    ),
                                  );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Tabla de traslados
                    Expanded(
                      child: ServiciosTable(
                        // ✅ Key único basado en el contenido de traslados
                        // Esto fuerza la reconstrucción cuando cambian los datos
                        key: ValueKey<String>('servicios_table_${trasladosPendientes.length}_${trasladosPendientes.map((TrasladoEntity t) => '${t.id}_${t.idConductor ?? 'null'}').join('_')}'),
                        traslados: trasladosPendientes,
                        trasladosSeleccionados: _trasladosSeleccionados,
                        serviciosPorTraslado: _serviciosPorTraslado,
                        localidadesPorId: _localidadesPorId,
                        personalPorId: _personalPorId,
                        localidadesPorNombreHospital: _localidadesPorNombreHospital,
                        selectedDay: _selectedDay,
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _trasladosSeleccionados
                              ..clear()
                              ..addAll(newSelection);
                          });
                        },
                        onEditarServicio: (ServicioEntity servicio) => _editarServicio(context, servicio),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );  // Cierre BlocBuilder TraficoDiarioBloc
      },
    );  // Cierre BlocBuilder ServiciosBloc
  }
}
