import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/resizable_data_table.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_bloc.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_event.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/models/conductor_con_vehiculo.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/asignacion_individual_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/asignacion_masiva_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/cancelar_traslado_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/modificar_hora_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/servicios_filters.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/traslado_row_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tabla de servicios pendientes de asignar
///
/// Incluye:
/// - Header con información de selección
/// - Tabla ResizableDataTable con filtros
/// - Checkboxes de selección múltiple
/// - Diálogo de asignación masiva
class ServiciosTable extends StatefulWidget {
  const ServiciosTable({
    required this.traslados,
    required this.trasladosSeleccionados,
    required this.serviciosPorTraslado,
    required this.localidadesPorId,
    required this.personalPorId,
    required this.localidadesPorNombreHospital,
    required this.onSelectionChanged,
    required this.selectedDay,
    this.onEditarServicio,
    super.key,
  });

  final List<TrasladoEntity> traslados;
  final Set<String> trasladosSeleccionados;
  final Map<String, ServicioEntity> serviciosPorTraslado;
  final Map<String, String> localidadesPorId;
  final Map<String, String> personalPorId;
  final Map<String, String> localidadesPorNombreHospital;
  final ValueChanged<Set<String>> onSelectionChanged;
  final DateTime selectedDay;
  final void Function(ServicioEntity servicio)? onEditarServicio;

  @override
  State<ServiciosTable> createState() => _ServiciosTableState();
}

class _ServiciosTableState extends State<ServiciosTable> {
  // Filtros para cada columna
  final Map<String, Set<String>> _filtrosActivos = <String, Set<String>>{
    'tipoTraslado': <String>{},
    'paciente': <String>{},
    'localidadOrigen': <String>{},
    'origen': <String>{},
    'localidadDestino': <String>{},
    'destino': <String>{},
    'terapia': <String>{},
    'estatus': <String>{},
    'conductor': <String>{},
    'matricula': <String>{},
  };

  // Controladores de texto para los filtros en línea
  final Map<String, TextEditingController> _filtroTextControllers = <String, TextEditingController>{};


  @override
  void dispose() {
    for (final TextEditingController controller in _filtroTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.traslados.isEmpty) {
      return _buildEmptyState('No hay traslados para el día seleccionado');
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header con información y botón de asignación masiva
          _buildHeader(),
          const SizedBox(height: 8),

          // Tabla de traslados
          Expanded(
            child: SingleChildScrollView(
              child: _buildTablaTraslados(),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el header de la sección de traslados pendientes
  Widget _buildHeader() {
    final int totalSeleccionados = widget.trasladosSeleccionados.length;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            totalSeleccionados > 0
                ? '$totalSeleccionados traslado${totalSeleccionados > 1 ? 's' : ''} seleccionado${totalSeleccionados > 1 ? 's' : ''}'
                : 'Traslados pendientes de asignar',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: totalSeleccionados > 0 ? AppColors.primary : AppColors.textPrimaryLight,
            ),
          ),
        ),

        if (totalSeleccionados > 0) ...<Widget>[
          Material(
            color: AppColors.gray300,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () {
                widget.onSelectionChanged(<String>{});
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.clear, size: 16, color: AppColors.textPrimaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'Limpiar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
            elevation: 2,
            child: InkWell(
              onTap: _mostrarDialogoAsignacionMasiva,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.assignment_ind, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Asignar Conductor',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Construye la tabla de traslados redimensionable
  Widget _buildTablaTraslados() {
    final List<TrasladoEntity> trasladosFiltrados = _aplicarFiltros(widget.traslados);

    final TrasladoRowBuilder rowBuilder = TrasladoRowBuilder(
      serviciosPorTraslado: widget.serviciosPorTraslado,
      localidadesPorId: widget.localidadesPorId,
      personalPorId: widget.personalPorId,
      localidadesPorNombreHospital: widget.localidadesPorNombreHospital,
      trasladosSeleccionados: widget.trasladosSeleccionados,
      onSelectionChanged: widget.onSelectionChanged,
      context: context,
      onDesasignarConductor: (String idTraslado) {
        debugPrint('🚫 ServiciosTable: Desasignando conductor del traslado $idTraslado');
        context.read<TraficoDiarioBloc>().add(
          TraficoDiarioEvent.desasignarConductorRequested(idTraslado: idTraslado),
        );
      },
      onDesasignarConductorMasivoRequested: _desasignarConductorMasivo,
      onEditarServicio: widget.onEditarServicio,
      onAsignarConductorRequested: _mostrarDialogoAsignacionIndividual,
      onAsignarConductorMasivoRequested: _mostrarDialogoAsignacionMasiva,
      onModificarHora: _mostrarDialogoModificarHora,
      onCancelarTraslado: _mostrarDialogoCancelarTraslado,
    );

    return ResizableDataTable(
      storageKey: 'planificar_servicios_table_widths',
      rowHeight: 35.0,
      initialColumnWidths: const <double>[
        49.37890625, // (Checkbox)
        91.15625, // I/V
        66.9453125, // Hora
        242.22265625, // Paciente
        209.63671875, // Dom. Origen
        120, // Loc. Origen
        130.73046875, // Origen
        141.109375, // Dom. Destino
        120, // Loc. Dest
        120, // Destino
        120, // Terapia
        117.3203125, // Estado
        120, // Conductor
        100, // Matrícula
        61.94140625, // H. Env
        72.9765625, // H. Org
        73.16796875, // H. Sal
        69.61328125, // H. Dst
        71.13671875, // H. Fin
        54.9609375, // SIC
        53.4140625, // CA
        51.62109375, // Ayu
        120, // Ac
      ],
      filterRow: ServiciosFilters(
        traslados: widget.traslados,
        trasladosFiltrados: trasladosFiltrados,
        trasladosSeleccionados: widget.trasladosSeleccionados,
        filtrosActivos: _filtrosActivos,
        filtroTextControllers: _filtroTextControllers,
        serviciosPorTraslado: widget.serviciosPorTraslado,
        localidadesPorId: widget.localidadesPorId,
        personalPorId: widget.personalPorId,
        localidadesPorNombreHospital: widget.localidadesPorNombreHospital,
        onFilterChanged: (Map<String, Set<String>> newFilters) {
          setState(() {
            _filtrosActivos
              ..clear()
              ..addAll(newFilters);
          });
        },
        onSelectionChanged: widget.onSelectionChanged,
      ).build(),
      columns: const <DataTableColumn>[
        DataTableColumn(label: '', alignment: Alignment.center),
        DataTableColumn(label: 'I/V', alignment: Alignment.center),
        DataTableColumn(label: 'Hora', alignment: Alignment.center),
        DataTableColumn(label: 'Paciente'),
        DataTableColumn(label: 'Dom. Origen'),
        DataTableColumn(label: 'Loc. Origen'),
        DataTableColumn(label: 'Origen'),
        DataTableColumn(label: 'Dom. Destino'),
        DataTableColumn(label: 'Loc. Dest'),
        DataTableColumn(label: 'Destino'),
        DataTableColumn(label: 'Terapia'),
        DataTableColumn(label: 'Estado', alignment: Alignment.center),
        DataTableColumn(label: 'Conductor', alignment: Alignment.center),
        DataTableColumn(label: 'Matrícula', alignment: Alignment.center),
        DataTableColumn(label: 'H. Env', alignment: Alignment.center),
        DataTableColumn(label: 'H. Org', alignment: Alignment.center),
        DataTableColumn(label: 'H. Sal', alignment: Alignment.center),
        DataTableColumn(label: 'H. Dst', alignment: Alignment.center),
        DataTableColumn(label: 'H. Fin', alignment: Alignment.center),
        DataTableColumn(label: 'SIC', alignment: Alignment.center),
        DataTableColumn(label: 'CA', alignment: Alignment.center),
        DataTableColumn(label: 'Ayu', alignment: Alignment.center),
        DataTableColumn(label: 'Ac', alignment: Alignment.center),
      ],
      rows: trasladosFiltrados.map(rowBuilder.buildRow).toList(),
    );
  }

  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.event_busy, size: 48, color: AppColors.gray300),
          const SizedBox(height: AppSizes.spacing),
          Text(
            mensaje,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<TrasladoEntity> _aplicarFiltros(List<TrasladoEntity> traslados) {
    final TrasladoRowBuilder rowBuilder = TrasladoRowBuilder(
      serviciosPorTraslado: widget.serviciosPorTraslado,
      localidadesPorId: widget.localidadesPorId,
      personalPorId: widget.personalPorId,
      localidadesPorNombreHospital: widget.localidadesPorNombreHospital,
      trasladosSeleccionados: widget.trasladosSeleccionados,
      onSelectionChanged: widget.onSelectionChanged,
      context: context,
    );

    return traslados.where((TrasladoEntity traslado) {
      for (final MapEntry<String, Set<String>> entry in _filtrosActivos.entries) {
        if (entry.value.isEmpty) {
          continue;
        }

        final String valorTraslado = rowBuilder.obtenerValorColumna(traslado, entry.key);
        if (!entry.value.contains(valorTraslado)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _mostrarDialogoAsignacionMasiva() async {
    if (widget.trasladosSeleccionados.isEmpty) {
      return;
    }

    // ⚠️ IMPORTANTE: Capturar los IDs ANTES de abrir el diálogo
    // porque widget.trasladosSeleccionados podría cambiar mientras el diálogo está abierto
    final List<String> idsCapturados = widget.trasladosSeleccionados.toList();
    final int cantidadCapturada = idsCapturados.length;

    debugPrint('📋 ServiciosTable: Abriendo diálogo de asignación masiva');
    debugPrint('   - IDs capturados: $idsCapturados');
    debugPrint('   - Cantidad: $cantidadCapturada');

    // Obtener conductores con turno activo para el día seleccionado
    final List<ConductorConVehiculo> conductoresDisponibles = await _obtenerConductoresConTurno();

    if (!mounted) {
      return;
    }

    await AsignacionMasivaDialog.show(
      context: context,
      cantidadSeleccionados: cantidadCapturada,
      conductores: conductoresDisponibles,
      onAsignar: (ConductorConVehiculo? conductorConVehiculo) {
        if (conductorConVehiculo != null && context.mounted) {
          debugPrint('🚀 Asignando conductor ${conductorConVehiculo.idConductor}, vehículo ${conductorConVehiculo.idVehiculo} (${conductorConVehiculo.matriculaVehiculo}) a $cantidadCapturada traslados');
          debugPrint('🚀 IDs a asignar: $idsCapturados');

          // Disparar evento de asignación masiva en el BLoC con los IDs capturados
          context.read<TraficoDiarioBloc>().add(
            TraficoDiarioEvent.asignarConductorMasivoRequested(
              idTraslados: idsCapturados,
              idConductor: conductorConVehiculo.idConductor,
              idVehiculo: conductorConVehiculo.idVehiculo,
              matriculaVehiculo: conductorConVehiculo.matriculaVehiculo,
            ),
          );
        }
        widget.onSelectionChanged(<String>{});
      },
    );
  }

  /// Desasigna conductor de múltiples traslados seleccionados
  void _desasignarConductorMasivo() {
    if (widget.trasladosSeleccionados.isEmpty) {
      return;
    }

    // ⚠️ IMPORTANTE: Capturar los IDs ANTES de cualquier operación async
    // porque widget.trasladosSeleccionados podría cambiar
    final List<String> idsCapturados = widget.trasladosSeleccionados.toList();
    final int cantidadCapturada = idsCapturados.length;

    debugPrint('🚫🚫 ServiciosTable: Desasignando conductor de múltiples traslados');
    debugPrint('   - IDs capturados: $idsCapturados');
    debugPrint('   - Cantidad: $cantidadCapturada');

    // Disparar evento de desasignación masiva en el BLoC con los IDs capturados
    context.read<TraficoDiarioBloc>().add(
      TraficoDiarioEvent.desasignarConductorMasivoRequested(
        idTraslados: idsCapturados,
      ),
    );

    // Limpiar selección
    widget.onSelectionChanged(<String>{});
  }

  /// Muestra diálogo de asignación individual para un traslado desde el menú contextual
  Future<void> _mostrarDialogoAsignacionIndividual(String idTraslado, String pacienteNombre) async {
    debugPrint('🚗 ServiciosTable: Mostrando diálogo de asignación individual');
    debugPrint('   - Traslado: $idTraslado');
    debugPrint('   - Paciente: $pacienteNombre');

    // Obtener conductores con turno activo para el día seleccionado
    final List<ConductorConVehiculo> conductoresDisponibles = await _obtenerConductoresConTurno();

    if (!mounted) {
      return;
    }

    await AsignacionIndividualDialog.show(
      context: context,
      idTraslado: idTraslado,
      pacienteNombre: pacienteNombre,
      conductores: conductoresDisponibles,
      onAsignar: (String id, ConductorConVehiculo conductor) {
        debugPrint('✅ Asignando conductor desde menú contextual:');
        debugPrint('   - Traslado: $id');
        debugPrint('   - Conductor: ${conductor.nombreConductor}');
        debugPrint('   - Vehículo: ${conductor.matriculaVehiculo}');

        if (context.mounted) {
          // Usar el mismo evento que la asignación masiva pero con un solo traslado
          context.read<TraficoDiarioBloc>().add(
            TraficoDiarioEvent.asignarConductorMasivoRequested(
              idTraslados: <String>[id],
              idConductor: conductor.idConductor,
              idVehiculo: conductor.idVehiculo,
              matriculaVehiculo: conductor.matriculaVehiculo,
            ),
          );
        }
      },
    );
  }

  /// Obtiene conductores que tienen turno asignado para el día con vehículo
  Future<List<ConductorConVehiculo>> _obtenerConductoresConTurno() async {
    try {
      debugPrint('📅 Buscando conductores con turno para: ${widget.selectedDay}');

      // Normalizar la fecha a inicio y fin del día
      final DateTime inicioDia = DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
      );
      final DateTime finDia = DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
        23,
        59,
        59,
      );

      debugPrint('🔍 Buscando turnos desde ${inicioDia.toIso8601String()} hasta ${finDia.toIso8601String()}');

      // Paso 1: Consultar turnos activos que se solapan con el día seleccionado
      // y que tienen vehículo asignado
      final List<dynamic> turnosResponse = await Supabase.instance.client
          .from('turnos')
          .select('id, idPersonal, nombrePersonal, idVehiculo, fechaInicio, fechaFin')
          .eq('activo', true)
          .not('idVehiculo', 'is', null)
          .lte('fechaInicio', finDia.toIso8601String())
          .gte('fechaFin', inicioDia.toIso8601String());

      debugPrint('📋 Respuesta de turnos: ${turnosResponse.length} registros');

      final List<ConductorConVehiculo> conductoresConTurno = <ConductorConVehiculo>[];
      final Set<String> idsYaAgregados = <String>{};

      // Procesar cada turno encontrado
      for (final dynamic item in turnosResponse) {
        final Map<String, dynamic> turno = item as Map<String, dynamic>;

        final String idPersonal = turno['idPersonal'] as String;
        final String nombrePersonal = turno['nombrePersonal'] as String;
        final String idVehiculo = turno['idVehiculo'] as String;

        // Paso 2: Obtener matrícula del vehículo
        String matricula = 'Sin matrícula';
        try {
          final Map<String, dynamic>? vehiculoData = await Supabase.instance.client
              .from('tvehiculos')
              .select('id, matricula')
              .eq('id', idVehiculo)
              .maybeSingle();

          if (vehiculoData != null) {
            matricula = vehiculoData['matricula'] as String? ?? 'Sin matrícula';
          }
        } catch (e) {
          debugPrint('  ⚠️ Error obteniendo vehículo $idVehiculo: $e');
        }

        // Solo agregar si no está ya en la lista (evitar duplicados)
        if (!idsYaAgregados.contains(idPersonal)) {
          conductoresConTurno.add(
            ConductorConVehiculo(
              idConductor: idPersonal,
              nombreConductor: nombrePersonal,
              idVehiculo: idVehiculo,
              matriculaVehiculo: matricula,
            ),
          );
          idsYaAgregados.add(idPersonal);
          debugPrint('  ✓ $nombrePersonal - $matricula');
        }
      }

      debugPrint('✅ Encontrados ${conductoresConTurno.length} conductores con turno y vehículo');

      return conductoresConTurno;
    } catch (e) {
      debugPrint('❌ Error obteniendo conductores con turno: $e');
      // En caso de error, retornar lista vacía
      return <ConductorConVehiculo>[];
    }
  }

  /// Muestra el diálogo para modificar la hora programada de un traslado
  Future<void> _mostrarDialogoModificarHora(
    String idTraslado,
    DateTime? horaActual,
    String pacienteNombre,
  ) async {
    debugPrint('🕐 ServiciosTable: Abriendo diálogo para modificar hora');
    debugPrint('   - Traslado: $idTraslado');
    debugPrint('   - Hora actual: $horaActual');
    debugPrint('   - Paciente: $pacienteNombre');

    final DateTime? nuevaHora = await ModificarHoraDialog.show(
      context: context,
      horaActual: horaActual,
      pacienteNombre: pacienteNombre,
    );

    if (nuevaHora != null && mounted) {
      debugPrint('✅ Nueva hora seleccionada: ${nuevaHora.hour}:${nuevaHora.minute}');

      // Disparar evento para modificar la hora en el BLoC
      context.read<TraficoDiarioBloc>().add(
        TraficoDiarioEvent.modificarHoraRequested(
          idTraslado: idTraslado,
          nuevaHora: nuevaHora,
        ),
      );
    } else {
      debugPrint('❌ Modificación de hora cancelada');
    }
  }

  /// Muestra el diálogo de confirmación para cancelar un traslado
  Future<void> _mostrarDialogoCancelarTraslado(
    String idTraslado,
    String pacienteNombre,
    DateTime? horaProgramada,
    String origen,
    String destino,
  ) async {
    debugPrint('❌ ServiciosTable: Abriendo diálogo para cancelar traslado');
    debugPrint('   - Traslado: $idTraslado');
    debugPrint('   - Paciente: $pacienteNombre');

    final CancelarTrasladoResult? resultado = await CancelarTrasladoDialog.show(
      context: context,
      pacienteNombre: pacienteNombre,
      horaProgramada: horaProgramada,
      origen: origen,
      destino: destino,
    );

    if (resultado != null && resultado.confirmado && mounted) {
      debugPrint('✅ Cancelación confirmada');
      if (resultado.motivoCancelacion != null) {
        debugPrint('   - Motivo: ${resultado.motivoCancelacion}');
      }

      // Disparar evento para cancelar el traslado en el BLoC
      context.read<TraficoDiarioBloc>().add(
        TraficoDiarioEvent.cancelarTrasladoRequested(
          idTraslado: idTraslado,
          motivoCancelacion: resultado.motivoCancelacion,
        ),
      );
    } else {
      debugPrint('❌ Cancelación de traslado abortada');
    }
  }
}
