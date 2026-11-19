import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_bloc.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/bloc/trafico_diario_event.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/models/conductor_con_vehiculo.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/asignacion_individual_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/asignacion_masiva_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/cancelar_traslado_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/modificar_hora_dialog.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/planificar_traslado_valores.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/planificar_traslados_bar.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/planificar_traslados_columns.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/traslado_row_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rejilla de traslados del día en "Planificar Servicios".
///
/// Usa `GestionGrid` (la misma rejilla que el resto de pantallas de gestión):
/// - Columnas flexibles con ancho mínimo (desplazamiento horizontal si no caben)
/// - Ordenación por cabecera y filtros estilo Excel por columna
/// - Casillas para marcar varios traslados y asignarlos a la vez
/// - Doble clic / Intro: detalles del traslado; clic derecho: menú de acciones
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
  GestionColumnFilters _filters = const GestionColumnFilters();
  GestionSort _sort = const GestionSort(columnIndex: 1);
  String? _selectedId;

  TrasladoRowBuilder _acciones() {
    return TrasladoRowBuilder(
      serviciosPorTraslado: widget.serviciosPorTraslado,
      localidadesPorId: widget.localidadesPorId,
      personalPorId: widget.personalPorId,
      localidadesPorNombreHospital: widget.localidadesPorNombreHospital,
      trasladosSeleccionados: widget.trasladosSeleccionados,
      context: context,
      onDesasignarConductor: (String idTraslado) {
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
      onVerHistorial: _mostrarDialogoHistorial,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TrasladoRowBuilder acciones = _acciones();
    final List<GestionColumn<TrasladoEntity>> columns = planificarTrasladosColumns(
      valores: PlanificarTrasladoValores(
        serviciosPorTraslado: widget.serviciosPorTraslado,
        localidadesPorId: widget.localidadesPorId,
        personalPorId: widget.personalPorId,
        localidadesPorNombreHospital: widget.localidadesPorNombreHospital,
      ),
      menu: acciones.contextMenuOptions,
    );
    final List<TrasladoEntity> visibles = _sort.apply(_filters.apply(widget.traslados, columns), columns);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PlanificarTrasladosBar(
              seleccionados: widget.trasladosSeleccionados.length,
              columns: columns,
              filters: _filters,
              onFiltersChanged: (GestionColumnFilters f) => setState(() => _filters = f),
              onLimpiarSeleccion: () => widget.onSelectionChanged(<String>{}),
              onAsignar: _mostrarDialogoAsignacionMasiva,
            ),
            Expanded(
              child: GestionGrid<TrasladoEntity>(
                columns: columns,
                rows: visibles,
                rowId: (TrasladoEntity t) => t.id,
                selectedId: _selectedId,
                onSelect: (TrasladoEntity t) => setState(() => _selectedId = t.id),
                onActivate: acciones.mostrarDetalles,
                sort: _sort,
                onSort: (GestionSort s) => setState(() => _sort = s),
                filters: _filters,
                onFiltersChanged: (GestionColumnFilters f) => setState(() => _filters = f),
                filterSource: widget.traslados,
                checkedIds: widget.trasladosSeleccionados,
                onCheckedChanged: widget.onSelectionChanged,
                emptyMessage: widget.traslados.isEmpty
                    ? 'No hay traslados para el día seleccionado'
                    : 'Ningún traslado coincide con los filtros',
              ),
            ),
          ],
        ),
      ),
    );
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

  /// Muestra el diálogo con el historial de estados de un traslado
  Future<void> _mostrarDialogoHistorial(
    String idTraslado,
    String pacienteNombre,
  ) async {
    debugPrint('📜 ServiciosTable: Abriendo diálogo de historial de estados');
    debugPrint('   - Traslado: $idTraslado');
    debugPrint('   - Paciente: $pacienteNombre');

    // Mostrar diálogo de carga mientras se obtiene el historial
    if (!mounted) {
      return;
    }

    // Variable para guardar el contexto del diálogo de carga
    BuildContext? loadingDialogContext;

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Guardar el contexto del diálogo de carga después del frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          loadingDialogContext = dialogContext;
        });
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(
                'Cargando historial...',
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ],
          ),
        );
      },
    ));

    // Esperar un frame para que el diálogo se muestre y el contexto se guarde
    await Future<void>.delayed(const Duration(milliseconds: 50));

    try {
      // Consultar historial de estados desde Supabase
      final List<Map<String, dynamic>> historialResponse = await Supabase.instance.client
          .from('historial_estados_traslado')
          .select()
          .eq('id_traslado', idTraslado)
          .order('fecha_cambio', ascending: false);

      debugPrint('✅ Historial obtenido: ${historialResponse.length} registros');

      // Obtener los IDs únicos de usuarios
      final Set<String> idsUsuarios = <String>{};
      for (final Map<String, dynamic> item in historialResponse) {
        final String? idUsuario = item['id_usuario'] as String?;
        if (idUsuario != null && idUsuario.isNotEmpty) {
          idsUsuarios.add(idUsuario);
        }
      }

      // Consultar nombres de usuarios si hay IDs
      final Map<String, Map<String, dynamic>> usuariosPorId = <String, Map<String, dynamic>>{};
      if (idsUsuarios.isNotEmpty) {
        final List<Map<String, dynamic>> usuariosResponse = await Supabase.instance.client
            .from('tpersonal')
            .select('id, nombre, apellidos')
            .inFilter('id', idsUsuarios.toList());

        for (final Map<String, dynamic> usuario in usuariosResponse) {
          final String id = usuario['id'] as String;
          usuariosPorId[id] = usuario;
        }
        debugPrint('✅ Usuarios obtenidos: ${usuariosPorId.length}');
      }

      // Agregar datos de usuario a cada item del historial
      final List<Map<String, dynamic>> response = historialResponse.map((Map<String, dynamic> item) {
        final String? idUsuario = item['id_usuario'] as String?;
        if (idUsuario != null && usuariosPorId.containsKey(idUsuario)) {
          return <String, dynamic>{
            ...item,
            'usuario': usuariosPorId[idUsuario],
          };
        }
        return item;
      }).toList();

      if (!mounted) {
        return;
      }

      // Cerrar diálogo de carga usando el contexto guardado
      if (loadingDialogContext != null && loadingDialogContext!.mounted) {
        Navigator.of(loadingDialogContext!).pop();
      }

      // Mostrar diálogo con el historial
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Row(
              children: <Widget>[
                const Icon(Icons.history, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Historial de Estados',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pacienteNombre.isNotEmpty)
                        Text(
                          pacienteNombre,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              height: 400,
              child: response.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.info_outline,
                            size: 48,
                            color: AppColors.gray300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay historial de estados',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: response.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> item = response[index];
                        return _buildHistorialItem(item, index == 0);
                      },
                    ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Error al obtener historial: $e');

      // Cerrar diálogo de carga usando el contexto guardado
      if (loadingDialogContext != null && loadingDialogContext!.mounted) {
        Navigator.of(loadingDialogContext!).pop();
      }

      if (!mounted) {
        return;
      }

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar historial: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Construye un item del historial de estados
  Widget _buildHistorialItem(Map<String, dynamic> item, bool esActual) {
    final String? estadoAnteriorStr = item['estado_anterior'] as String?;
    final String estadoNuevoStr = item['estado_nuevo'] as String? ?? 'desconocido';
    final String? fechaCambioStr = item['fecha_cambio'] as String?;
    final String? observaciones = item['observaciones'] as String?;

    // Obtener nombre del usuario que realizó el cambio
    final Map<String, dynamic>? usuarioData = item['usuario'] as Map<String, dynamic>?;
    String nombreUsuario = 'Usuario desconocido';
    if (usuarioData != null) {
      final String nombre = usuarioData['nombre'] as String? ?? '';
      final String apellidos = usuarioData['apellidos'] as String? ?? '';
      if (nombre.isNotEmpty || apellidos.isNotEmpty) {
        nombreUsuario = '$nombre $apellidos'.trim();
      }
    }

    // Parsear la fecha
    DateTime? fechaCambio;
    if (fechaCambioStr != null) {
      fechaCambio = DateTime.tryParse(fechaCambioStr);
    }

    // Obtener etiquetas de los estados
    final String estadoAnteriorLabel = estadoAnteriorStr != null
        ? _getEstadoLabel(estadoAnteriorStr)
        : 'Sin estado';
    final String estadoNuevoLabel = _getEstadoLabel(estadoNuevoStr);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: esActual
          ? BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Fecha y hora
          Row(
            children: <Widget>[
              Icon(
                Icons.access_time,
                size: 14,
                color: esActual ? AppColors.primary : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                fechaCambio != null
                    ? '${fechaCambio.day.toString().padLeft(2, '0')}/${fechaCambio.month.toString().padLeft(2, '0')}/${fechaCambio.year} ${fechaCambio.hour.toString().padLeft(2, '0')}:${fechaCambio.minute.toString().padLeft(2, '0')}'
                    : 'Fecha desconocida',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: esActual ? FontWeight.w600 : FontWeight.normal,
                  color: esActual ? AppColors.primary : AppColors.textSecondaryLight,
                ),
              ),
              if (esActual) ...<Widget>[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ACTUAL',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Usuario que realizó el cambio
          Row(
            children: <Widget>[
              const Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                nombreUsuario,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Cambio de estado
          Row(
            children: <Widget>[
              _buildEstadoBadge(estadoAnteriorLabel, estadoAnteriorStr),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.gray400),
              const SizedBox(width: 8),
              _buildEstadoBadge(estadoNuevoLabel, estadoNuevoStr),
            ],
          ),

          // Observaciones (si las hay)
          if (observaciones != null && observaciones.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.notes, size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    observaciones,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Construye un badge para el estado
  Widget _buildEstadoBadge(String label, String? estadoStr) {
    final Color color = _getColorForEstadoStr(estadoStr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Obtiene la etiqueta legible de un estado
  String _getEstadoLabel(String estadoStr) {
    switch (estadoStr) {
      case 'pendiente':
        return 'PENDIENTE';
      case 'asignado':
        return 'ASIGNADO';
      case 'enviado':
        return 'ENVIADO';
      case 'recibido_conductor':
        return 'RECIBIDO';
      case 'en_origen':
        return 'EN ORIGEN';
      case 'saliendo_origen':
        return 'EN RUTA';
      case 'en_transito':
        return 'EN TRÁNSITO';
      case 'en_destino':
        return 'EN DESTINO';
      case 'finalizado':
        return 'FINALIZADO';
      case 'cancelado':
        return 'CANCELADO';
      case 'no_realizado':
        return 'NO REALIZADO';
      default:
        return estadoStr.toUpperCase();
    }
  }

  /// Obtiene el color para un estado dado como string
  Color _getColorForEstadoStr(String? estadoStr) {
    switch (estadoStr) {
      case 'cancelado':
      case 'no_realizado':
      case 'finalizado':
        return AppColors.error;
      case 'pendiente':
        return AppColors.info;
      case 'asignado':
      case 'enviado':
      case 'recibido_conductor':
      case 'en_origen':
      case 'saliendo_origen':
      case 'en_transito':
      case 'en_destino':
        return AppColors.success;
      default:
        return AppColors.gray500;
    }
  }
}
