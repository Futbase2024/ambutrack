import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/context_menu/custom_context_menu.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/resizable_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Builder para construir filas de traslados en la tabla
///
/// Separado para reducir complejidad y líneas del componente principal
class TrasladoRowBuilder {
  const TrasladoRowBuilder({
    required this.serviciosPorTraslado,
    required this.localidadesPorId,
    required this.personalPorId,
    required this.localidadesPorNombreHospital,
    required this.trasladosSeleccionados,
    required this.onSelectionChanged,
    required this.context,
    this.onDesasignarConductor,
    this.onDesasignarConductorMasivoRequested,
    this.onEditarServicio,
    this.onAsignarConductorRequested,
    this.onAsignarConductorMasivoRequested,
    this.onModificarHora,
    this.onCancelarTraslado,
    this.onVerHistorial,
  });

  final Map<String, ServicioEntity> serviciosPorTraslado;
  final Map<String, String> localidadesPorId;
  final Map<String, String> personalPorId;
  final Map<String, String> localidadesPorNombreHospital;
  final Set<String> trasladosSeleccionados;
  final ValueChanged<Set<String>> onSelectionChanged;
  final BuildContext context;

  /// Callback para desasignar conductor de un traslado individual
  final void Function(String idTraslado)? onDesasignarConductor;

  /// Callback para desasignar conductor de múltiples traslados
  /// Se usa cuando hay múltiples filas seleccionadas
  final VoidCallback? onDesasignarConductorMasivoRequested;

  /// Callback para editar un servicio
  final void Function(ServicioEntity servicio)? onEditarServicio;

  /// Callback para solicitar asignación de conductor a un traslado individual
  /// Recibe el ID del traslado y el nombre del paciente para mostrar contexto
  final void Function(String idTraslado, String pacienteNombre)? onAsignarConductorRequested;

  /// Callback para solicitar asignación masiva de conductor a múltiples traslados
  /// Se usa cuando hay múltiples filas seleccionadas
  final VoidCallback? onAsignarConductorMasivoRequested;

  /// Callback para modificar la hora programada de un traslado
  /// Recibe el ID del traslado, la hora actual y el nombre del paciente
  final void Function(String idTraslado, DateTime? horaActual, String pacienteNombre)? onModificarHora;

  /// Callback para cancelar un traslado
  /// Recibe el ID del traslado, hora programada, origen y destino para mostrar contexto
  final void Function(String idTraslado, String pacienteNombre, DateTime? horaProgramada, String origen, String destino)? onCancelarTraslado;

  /// Callback para ver el historial de estados de un traslado
  /// Recibe el ID del traslado y el nombre del paciente para mostrar contexto
  final void Function(String idTraslado, String pacienteNombre)? onVerHistorial;

  /// Construye una fila de datos para un traslado
  DataTableRow buildRow(TrasladoEntity traslado) {
    final ServicioEntity? servicio = serviciosPorTraslado[traslado.id];

    // Usar paciente del servicio (traslado no tiene paciente directo)
    final PacienteEntity? paciente = servicio?.paciente;

    final String tipoTraslado = traslado.tipoTraslado.toUpperCase();
    // Formatear hora a HH:mm (quitar segundos si vienen en formato HH:mm:ss)
    final String horaProgramada = _formatearHora(traslado.horaProgramada);

    final String estatus = _getEstatusTexto(traslado.estado);
    final Color estatusColor = _getEstatusColor(traslado);

    final String pacienteNombre = paciente != null
        ? '${paciente.nombre} ${paciente.primerApellido}${paciente.segundoApellido != null ? ' ${paciente.segundoApellido}' : ''}'
        : '';

    final String domicilioOrigen = traslado.tipoOrigen == 'domicilio_paciente'
        ? (paciente?.domicilioDireccion ?? '')
        : 'HOSPITAL';

    final String domicilioDestino = traslado.tipoDestino == 'domicilio_paciente'
        ? (paciente?.domicilioDireccion ?? '')
        : 'HOSPITAL';

    String localidadOrigen = '';
    if (traslado.tipoOrigen == 'domicilio_paciente') {
      localidadOrigen = paciente?.localidadId != null
          ? (localidadesPorId[paciente!.localidadId!] ?? '')
          : '';
    } else if (traslado.origen != null && traslado.origen!.isNotEmpty) {
      localidadOrigen = localidadesPorNombreHospital[traslado.origen!] ?? '';
    }

    String localidadDestino = '';
    if (traslado.tipoDestino == 'domicilio_paciente') {
      localidadDestino = paciente?.localidadId != null
          ? (localidadesPorId[paciente!.localidadId!] ?? '')
          : '';
    } else if (traslado.destino != null && traslado.destino!.isNotEmpty) {
      localidadDestino = localidadesPorNombreHospital[traslado.destino!] ?? '';
    }

    final String nombreOrigen = traslado.tipoOrigen == 'centro_hospitalario' &&
            traslado.origen != null &&
            traslado.origen!.isNotEmpty
        ? traslado.origen!
        : 'DOMICILIO';

    final String nombreDestino = traslado.tipoDestino == 'centro_hospitalario' &&
            traslado.destino != null &&
            traslado.destino!.isNotEmpty
        ? traslado.destino!
        : 'DOMICILIO';

    // Usar motivo traslado del servicio (traslado solo tiene idMotivoTraslado)
    final String terapia = servicio?.motivoTraslado?.nombre ?? '';
    final String conductor = traslado.idConductor != null
        ? (personalPorId[traslado.idConductor!] ?? traslado.conductorNombre ?? '')
        : '';
    final String matricula = traslado.matriculaVehiculo ?? '';

    // Construir las celdas de la fila
    final List<DataTableCell> cells = <DataTableCell>[
        DataTableCell(
          child: Checkbox(
            value: trasladosSeleccionados.contains(traslado.id),
            onChanged: (bool? value) {
              final Set<String> newSelection = Set<String>.from(trasladosSeleccionados);
              if (value == true) {
                newSelection.add(traslado.id);
              } else {
                newSelection.remove(traslado.id);
              }
              onSelectionChanged(newSelection);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          alignment: Alignment.center,
        ),
        DataTableCell(
          child: Tooltip(
            message: tipoTraslado,
            child: Container(
              width: 28,
              height: 22,
              decoration: BoxDecoration(
                color: tipoTraslado == 'IDA'
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: tipoTraslado == 'IDA'
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                tipoTraslado == 'IDA' ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                size: 18,
                color: tipoTraslado == 'IDA' ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          alignment: Alignment.center,
        ),
        DataTableCell(child: _buildHoraCell(horaProgramada), alignment: Alignment.center),
        DataTableCell(child: _buildCellText(pacienteNombre, false, 11)),
        DataTableCell(child: _buildCellText(domicilioOrigen, false, 11)),
        DataTableCell(child: _buildCellText(localidadOrigen, false, 11)),
        DataTableCell(child: _buildCellText(nombreOrigen, false, 11)),
        DataTableCell(child: _buildCellText(domicilioDestino, false, 11)),
        DataTableCell(child: _buildCellText(localidadDestino, false, 11)),
        DataTableCell(child: _buildCellText(nombreDestino, false, 11)),
        DataTableCell(child: _buildCellText(terapia, false, 11)),
        DataTableCell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: estatusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              estatus,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: estatusColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          alignment: Alignment.center,
        ),
        DataTableCell(child: _buildCellText(conductor, true, 11), alignment: Alignment.center),
        DataTableCell(child: _buildCellText(matricula, true, 11), alignment: Alignment.center),
        ..._buildHorasCronologicas(traslado),
        ..._buildCheckboxesRequisitos(traslado),
    ];

    // Verificar si esta fila está seleccionada
    final bool estaSeleccionado = trasladosSeleccionados.contains(traslado.id);

    // Envolver la fila completa con menú contextual
    return DataTableRow(
      cells: cells.asMap().entries.map((MapEntry<int, DataTableCell> entry) {
        final int index = entry.key;
        final DataTableCell cell = entry.value;

        // No envolver el checkbox con menú contextual
        if (index == 0) {
          return cell;
        }

        return DataTableCell(
          child: CustomContextMenu(
            menuOptions: _buildContextMenuOptions(traslado, servicio),
            child: cell.child,
          ),
          alignment: cell.alignment,
        );
      }).toList(),
      // Color de fondo azul claro cuando está seleccionado
      backgroundColor: estaSeleccionado
          ? AppColors.primary.withValues(alpha: 0.15)
          : null,
      isSelected: estaSeleccionado,
      // Selección con Shift para múltiple, clic normal para única
      onTap: () {
        // Verificar si Shift está presionado para selección múltiple
        final bool shiftPressed = HardwareKeyboard.instance.logicalKeysPressed
            .any((LogicalKeyboardKey key) =>
                key == LogicalKeyboardKey.shiftLeft ||
                key == LogicalKeyboardKey.shiftRight);

        if (shiftPressed) {
          // Shift + clic: añadir/quitar de la selección múltiple
          final Set<String> newSelection = Set<String>.from(trasladosSeleccionados);
          if (estaSeleccionado) {
            newSelection.remove(traslado.id);
          } else {
            newSelection.add(traslado.id);
          }
          onSelectionChanged(newSelection);
        } else {
          // Clic normal: seleccionar solo esta fila (o deseleccionar si ya está sola)
          if (estaSeleccionado && trasladosSeleccionados.length == 1) {
            // Si solo está esta seleccionada, deseleccionarla
            onSelectionChanged(<String>{});
          } else {
            // Seleccionar solo esta fila
            onSelectionChanged(<String>{traslado.id});
          }
        }
      },
    );
  }

  /// Construye las opciones del menú contextual para un traslado
  List<ContextMenuOption> _buildContextMenuOptions(TrasladoEntity traslado, ServicioEntity? servicio) {
    final bool tieneServicio = servicio != null;
    final bool tieneHoraProgramada = traslado.horaProgramada.isNotEmpty;
    final bool estaPendiente = traslado.estado == EstadoTraslado.pendiente;
    // Un traslado tiene conductor asignado si idConductor no es null
    // Esto cubre estados: asignado, enviado, recibido_conductor, en_origen, etc.
    final bool tieneConductorAsignado = traslado.idConductor != null;
    // Un traslado finalizado no puede ser desasignado
    final bool estaFinalizado = traslado.estado == EstadoTraslado.finalizado;

    return <ContextMenuOption>[
      ContextMenuOption(
        label: 'Ver detalles',
        emoji: '📋',
        onTap: () {
          debugPrint('📋 Ver detalles de traslado: ${traslado.id}');
          _mostrarDetallesServicio(traslado, servicio);
        },
      ),
      if (tieneServicio)
        ContextMenuOption(
          label: 'Editar servicio',
          emoji: '✏️',
          onTap: () {
            debugPrint('✏️ Editar servicio: ${servicio.id}');
            if (onEditarServicio != null) {
              onEditarServicio!(servicio);
            }
          },
        ),
      // Si tiene conductor asignado y NO está finalizado → Desasignar
      // Si no tiene conductor → Asignar
      // Si está finalizado → No mostrar opción de desasignar
      if (tieneConductorAsignado && !estaFinalizado)
        ContextMenuOption(
          label: 'Desasignar conductor',
          emoji: '🚫',
          onTap: () {
            // Verificar si hay múltiples traslados seleccionados
            // Si el traslado actual está en la selección y hay más de 1, usar desasignación masiva
            final bool usarDesasignacionMasiva = trasladosSeleccionados.length > 1 &&
                trasladosSeleccionados.contains(traslado.id);

            if (usarDesasignacionMasiva) {
              debugPrint('🚫🚫 Desasignar conductor de ${trasladosSeleccionados.length} traslados seleccionados');
              debugPrint('   - IDs seleccionados: $trasladosSeleccionados');
              if (onDesasignarConductorMasivoRequested != null) {
                onDesasignarConductorMasivoRequested!();
              }
            } else {
              debugPrint('🚫 Desasignar conductor de traslado: ${traslado.id}');
              debugPrint('   - Conductor actual: ${traslado.idConductor ?? "N/A"}');
              debugPrint('   - Vehículo actual: ${traslado.idVehiculo ?? "N/A"}');
              // Llamar al callback de desasignación si está disponible
              if (onDesasignarConductor != null) {
                onDesasignarConductor!(traslado.id);
              }
            }
          },
        ),
      // Solo mostrar "Asignar conductor" si NO tiene conductor asignado
      if (!tieneConductorAsignado)
        ContextMenuOption(
          label: 'Asignar conductor',
          emoji: '🚗',
          onTap: () {
            // Verificar si hay múltiples traslados seleccionados
            // Si el traslado actual está en la selección y hay más de 1, usar asignación masiva
            final bool usarAsignacionMasiva = trasladosSeleccionados.length > 1 &&
                trasladosSeleccionados.contains(traslado.id);

            if (usarAsignacionMasiva) {
              debugPrint('🚗🚗 Asignar conductor a ${trasladosSeleccionados.length} traslados seleccionados');
              debugPrint('   - IDs seleccionados: $trasladosSeleccionados');
              if (onAsignarConductorMasivoRequested != null) {
                onAsignarConductorMasivoRequested!();
              }
            } else {
              debugPrint('🚗 Asignar conductor a traslado: ${traslado.id}');
              debugPrint('   - Estado actual: ${traslado.estado.name}');
              _solicitarAsignacionConductor(traslado, servicio);
            }
          },
        ),
      // Solo mostrar "Modificar hora" si NO está finalizado
      if (tieneHoraProgramada && !estaFinalizado)
        ContextMenuOption(
          label: 'Modificar hora',
          emoji: '🕐',
          onTap: () {
            debugPrint('⏰ Modificar hora de traslado: ${traslado.id}');
            // Usar paciente del servicio
            final PacienteEntity? pacienteLocal = servicio?.paciente;
            final String pacienteNombreLocal = pacienteLocal != null
                ? '${pacienteLocal.nombre} ${pacienteLocal.primerApellido}'
                : '';
            if (onModificarHora != null) {
              // Parsear horaProgramada (String) a TimeOfDay para el callback
              final List<String> horaParts = traslado.horaProgramada.split(':');
              final int hora = int.tryParse(horaParts.isNotEmpty ? horaParts[0] : '0') ?? 0;
              final int minuto = int.tryParse(horaParts.length > 1 ? horaParts[1] : '0') ?? 0;
              final DateTime horaComoDateTime = DateTime(2000, 1, 1, hora, minuto);
              onModificarHora!(traslado.id, horaComoDateTime, pacienteNombreLocal);
            }
          },
        ),
      if (estaPendiente)
        ContextMenuOption(
          label: 'Cancelar traslado',
          emoji: '❌',
          onTap: () {
            debugPrint('❌ Cancelar traslado: ${traslado.id}');
            // Usar paciente del servicio
            final PacienteEntity? pacienteLocal = servicio?.paciente;
            final String pacienteNombreLocal = pacienteLocal != null
                ? '${pacienteLocal.nombre} ${pacienteLocal.primerApellido}'
                : '';
            final String origen = traslado.tipoOrigen == 'centro_hospitalario'
                ? (traslado.origen ?? 'Hospital')
                : 'Domicilio';
            final String destino = traslado.tipoDestino == 'centro_hospitalario'
                ? (traslado.destino ?? 'Hospital')
                : 'Domicilio';
            if (onCancelarTraslado != null) {
              // Parsear horaProgramada (String) a DateTime? para el callback
              final List<String> horaPartsCancelar = traslado.horaProgramada.split(':');
              final int horaCancelar = int.tryParse(horaPartsCancelar.isNotEmpty ? horaPartsCancelar[0] : '0') ?? 0;
              final int minutoCancelar = int.tryParse(horaPartsCancelar.length > 1 ? horaPartsCancelar[1] : '0') ?? 0;
              final DateTime horaComoDateTimeCancelar = DateTime(2000, 1, 1, horaCancelar, minutoCancelar);
              onCancelarTraslado!(traslado.id, pacienteNombreLocal, horaComoDateTimeCancelar, origen, destino);
            }
          },
        ),
      // Ver historial de estados - siempre disponible
      ContextMenuOption(
        label: 'Ver historial',
        emoji: '📜',
        onTap: () {
          debugPrint('📜 Ver historial de traslado: ${traslado.id}');
          // Usar paciente del servicio
          final PacienteEntity? pacienteLocal = servicio?.paciente;
          final String pacienteNombreLocal = pacienteLocal != null
              ? '${pacienteLocal.nombre} ${pacienteLocal.primerApellido}'
              : '';
          if (onVerHistorial != null) {
            onVerHistorial!(traslado.id, pacienteNombreLocal);
          }
        },
      ),
    ];
  }

  /// Muestra un dialog con los detalles completos del traslado (diseño profesional con secciones)
  void _mostrarDetallesServicio(TrasladoEntity traslado, ServicioEntity? servicio) {
    final String tipoTraslado = traslado.tipoTraslado.toUpperCase();
    final bool esIda = tipoTraslado == 'IDA';
    final String horaProgramada = traslado.horaProgramada;
    final String fechaTraslado = DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(traslado.fecha);
    final String estado = traslado.estado.name;

    // Recursos asignados
    final String conductor = traslado.idConductor != null
        ? (personalPorId[traslado.idConductor!] ?? traslado.conductorNombre ?? 'Sin asignar')
        : 'Sin asignar';
    final String matricula = traslado.matriculaVehiculo ?? traslado.vehiculoMatricula ?? 'Sin asignar';

    // Usar paciente del servicio
    final PacienteEntity? paciente = servicio?.paciente;
    final String pacienteNombre = paciente != null
        ? '${paciente.nombre} ${paciente.primerApellido}${paciente.segundoApellido != null ? ' ${paciente.segundoApellido}' : ''}'
        : 'Sin paciente';
    final String pacienteDocumento = paciente != null ? '${paciente.tipoDocumento}: ${paciente.documento}' : '-';
    final String pacienteEdad = paciente != null ? '${paciente.edad} años' : '-';
    final String pacienteSexo = paciente?.sexo ?? '-';
    final String pacienteTelefono = paciente?.telefonoMovil ?? paciente?.telefonoFijo ?? '-';
    final String pacienteDireccion = _buildDireccionCompleta(paciente);
    final String pacienteLocalidad = paciente?.localidadId != null
        ? (localidadesPorId[paciente!.localidadId!] ?? '-')
        : '-';
    final String pacienteNumHistoria = paciente?.numHistoria ?? '-';

    // Datos del servicio
    // Usar motivo traslado del servicio (traslado solo tiene idMotivoTraslado)
    final String motivoTraslado = servicio?.motivoTraslado?.nombre ?? 'No especificado';
    final String tipoRecurrencia = _formatTipoRecurrencia(servicio?.tipoRecurrencia);
    final String tipoAmbulancia = servicio?.tipoAmbulancia ?? 'No especificado';
    final int prioridad = servicio?.prioridad ?? traslado.prioridad;
    final String fechaInicioServicio = servicio?.fechaServicioInicio != null
        ? DateFormat('dd/MM/yyyy').format(servicio!.fechaServicioInicio!)
        : '-';
    final String fechaFinServicio = servicio?.fechaServicioFin != null
        ? DateFormat('dd/MM/yyyy').format(servicio!.fechaServicioFin!)
        : '-';
    final String horaRecogida = servicio?.horaRecogida ?? '-';
    final String horaVuelta = servicio?.horaVuelta ?? '-';

    // Origen y destino
    final String tipoOrigen = _formatTipoOrigenDestino(traslado.tipoOrigen);
    final String tipoDestino = _formatTipoOrigenDestino(traslado.tipoDestino);
    final String origenDetalle = _buildOrigenDestinoDetalle(traslado.tipoOrigen, traslado.origen, servicio?.origenUbicacionCentro, paciente);
    final String destinoDetalle = _buildOrigenDestinoDetalle(traslado.tipoDestino, traslado.destino, servicio?.destinoUbicacionCentro, paciente);
    final String localidadOrigen = _getLocalidadParaTipo(traslado.tipoOrigen, traslado.origen, paciente);
    final String localidadDestino = _getLocalidadParaTipo(traslado.tipoDestino, traslado.destino, paciente);
    final String ubicacionOrigen = servicio?.origenUbicacionCentro ?? '-';
    final String ubicacionDestino = servicio?.destinoUbicacionCentro ?? '-';

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 780,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Header principal con estado destacado
                _buildHeaderProfesional(esIda, tipoTraslado, horaProgramada, fechaTraslado, estado, traslado.codigo, prioridad),
                // Contenido scrolleable con secciones
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // SECCIÓN PACIENTE
                        _buildSeccion(
                          titulo: 'DATOS DEL PACIENTE',
                          icono: Icons.person,
                          color: AppColors.primary,
                          child: _buildPacienteSection(
                            pacienteNombre, pacienteDocumento, pacienteEdad, pacienteSexo,
                            pacienteTelefono, pacienteDireccion, pacienteLocalidad, pacienteNumHistoria,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // SECCIÓN RUTA (ORIGEN → DESTINO)
                        _buildSeccion(
                          titulo: 'RUTA DEL TRASLADO',
                          icono: Icons.route,
                          color: AppColors.secondary,
                          child: _buildRutaSection(
                            tipoOrigen, origenDetalle, localidadOrigen, ubicacionOrigen,
                            tipoDestino, destinoDetalle, localidadDestino, ubicacionDestino,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // SECCIÓN SERVICIO Y RECURSOS (2 columnas)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // Servicio
                              Expanded(
                                child: _buildSeccion(
                                  titulo: 'SERVICIO',
                                  icono: Icons.medical_services,
                                  color: const Color(0xFF7C3AED),
                                  child: _buildServicioSection(
                                    motivoTraslado, tipoRecurrencia, tipoAmbulancia, prioridad,
                                    fechaInicioServicio, fechaFinServicio, horaRecogida, horaVuelta,
                                    servicio?.requiereVuelta ?? false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Recursos
                              Expanded(
                                child: _buildSeccion(
                                  titulo: 'RECURSOS ASIGNADOS',
                                  icono: Icons.groups,
                                  color: AppColors.warning,
                                  child: _buildRecursosSection(conductor, '-', '-', matricula),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SECCIÓN REQUISITOS ESPECIALES
                        if (servicio != null && _tieneRequisitos(servicio)) ...<Widget>[
                          const SizedBox(height: 10),
                          _buildSeccion(
                            titulo: 'REQUISITOS ESPECIALES',
                            icono: Icons.accessibility_new,
                            color: AppColors.success,
                            child: _buildRequisitosSection(servicio),
                          ),
                        ],
                        const SizedBox(height: 10),
                        // SECCIÓN SEGUIMIENTO (TIMELINE)
                        _buildSeccion(
                          titulo: 'SEGUIMIENTO DEL TRASLADO',
                          icono: Icons.timeline,
                          color: AppColors.info,
                          child: _buildTimelineSection(traslado),
                        ),
                        // SECCIÓN OBSERVACIONES
                        if (_hayObservaciones(traslado, servicio)) ...<Widget>[
                          const SizedBox(height: 10),
                          _buildSeccion(
                            titulo: 'OBSERVACIONES',
                            icono: Icons.notes,
                            color: AppColors.warning,
                            child: _buildObservacionesSection(traslado, servicio),
                          ),
                        ],
                        const SizedBox(height: 10),
                        // SECCIÓN AUDITORÍA
                        _buildSeccion(
                          titulo: 'INFORMACIÓN DE AUDITORÍA',
                          icono: Icons.history,
                          color: AppColors.gray500,
                          child: _buildAuditoriaSection(traslado, servicio),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer con botones
                _buildFooterProfesional(dialogContext, traslado, servicio),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formatea el tipo de recurrencia
  String _formatTipoRecurrencia(String? tipo) {
    if (tipo == null) {
      return 'ÚNICO';
    }
    switch (tipo.toLowerCase()) {
      case 'unico':
        return 'ÚNICO';
      case 'diario':
        return 'DIARIO';
      case 'semanal':
        return 'SEMANAL';
      case 'semanas_alternas':
        return 'SEMANAS ALTERNAS';
      case 'dias_alternos':
        return 'DÍAS ALTERNOS';
      case 'mensual':
        return 'MENSUAL';
      case 'especifico':
        return 'FECHAS ESPECÍFICAS';
      default:
        return tipo.toUpperCase();
    }
  }

  /// Formatea el tipo de origen/destino
  String _formatTipoOrigenDestino(String? tipo) {
    if (tipo == null) {
      return 'No especificado';
    }
    switch (tipo.toLowerCase()) {
      case 'domicilio_paciente':
        return 'Domicilio del Paciente';
      case 'centro_hospitalario':
        return 'Centro Hospitalario';
      case 'otro_domicilio':
        return 'Otro Domicilio';
      default:
        return tipo;
    }
  }

  /// Header profesional con estado destacado y prioridad
  Widget _buildHeaderProfesional(
    bool esIda,
    String tipoTraslado,
    String horaProgramada,
    String fechaTraslado,
    String estado,
    String? codigo,
    int prioridad,
  ) {
    final Color colorTipo = esIda ? AppColors.success : AppColors.info;
    final Color colorEstado = _getColorEstado(estado);
    final Color colorPrioridad = _getColorPrioridad(prioridad);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[colorTipo.withValues(alpha: 0.08), colorTipo.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: colorTipo.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: <Widget>[
          // Icono tipo traslado
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorTipo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorTipo.withValues(alpha: 0.3)),
            ),
            child: Icon(esIda ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded, color: colorTipo, size: 20),
          ),
          const SizedBox(width: 12),
          // Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('TRASLADO DE $tipoTraslado', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                    if (codigo != null && codigo.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(4)),
                        child: Text('#$codigo', style: GoogleFonts.robotoMono(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(Icons.calendar_today, size: 12, color: colorTipo),
                    const SizedBox(width: 4),
                    Text(fechaTraslado.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimaryLight)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_filled, size: 12, color: colorTipo),
                    const SizedBox(width: 4),
                    Text(horaProgramada, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: colorTipo)),
                  ],
                ),
              ],
            ),
          ),
          // Badges de estado y prioridad
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorEstado,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(estado.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorPrioridad.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorPrioridad.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.flag, size: 10, color: colorPrioridad),
                    const SizedBox(width: 2),
                    Text('P$prioridad', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: colorPrioridad)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una sección con header colorido
  Widget _buildSeccion({required String titulo, required IconData icono, required Color color, required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header de sección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.15))),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
                  child: Icon(icono, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(titulo, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
              ],
            ),
          ),
          // Contenido
          Padding(padding: const EdgeInsets.all(10), child: child),
        ],
      ),
    );
  }

  /// Sección de datos del paciente
  Widget _buildPacienteSection(
    String nombre,
    String documento,
    String edad,
    String sexo,
    String telefono,
    String direccion,
    String localidad,
    String numHistoria,
  ) {
    return Column(
      children: <Widget>[
        // Nombre destacado
        Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(nombre.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight)),
                  Text(documento, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
        // Grid de datos
        Row(
          children: <Widget>[
            Expanded(child: _buildDatoItem(Icons.cake_outlined, 'Edad', edad)),
            Expanded(child: _buildDatoItem(Icons.wc_outlined, 'Sexo', sexo.toUpperCase())),
            Expanded(child: _buildDatoItem(Icons.phone_outlined, 'Teléfono', telefono)),
            Expanded(child: _buildDatoItem(Icons.badge_outlined, 'Nº Historia', numHistoria)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(flex: 2, child: _buildDatoItem(Icons.location_on_outlined, 'Dirección', direccion)),
            Expanded(child: _buildDatoItem(Icons.map_outlined, 'Localidad', localidad.toUpperCase())),
          ],
        ),
      ],
    );
  }

  /// Item de dato individual
  Widget _buildDatoItem(IconData icono, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icono, size: 12, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textSecondaryLight)),
                Text(valor, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de ruta (origen → destino)
  Widget _buildRutaSection(
    String tipoOrigen,
    String origenDetalle,
    String localidadOrigen,
    String ubicacionOrigen,
    String tipoDestino,
    String destinoDetalle,
    String localidadDestino,
    String ubicacionDestino,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ORIGEN
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.trip_origin, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text('ORIGEN', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(tipoOrigen, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 2),
                Text(origenDetalle.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight), maxLines: 2),
                if (ubicacionOrigen != '-') ...<Widget>[
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.room_outlined, size: 10, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text(ubicacionOrigen, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success)),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Text(localidadOrigen.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
        // Flecha central
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward, size: 14, color: AppColors.gray500),
          ),
        ),
        // DESTINO
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.flag, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text('DESTINO', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(tipoDestino, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 2),
                Text(destinoDetalle.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight), maxLines: 2),
                if (ubicacionDestino != '-') ...<Widget>[
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.room_outlined, size: 10, color: AppColors.error),
                      const SizedBox(width: 2),
                      Text(ubicacionDestino, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Text(localidadDestino.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sección de servicio
  Widget _buildServicioSection(
    String motivoTraslado,
    String tipoRecurrencia,
    String tipoAmbulancia,
    int prioridad,
    String fechaInicio,
    String fechaFin,
    String horaRecogida,
    String horaVuelta,
    bool requiereVuelta,
  ) {
    return Column(
      children: <Widget>[
        _buildDatoItem(Icons.medical_services_outlined, 'Motivo', motivoTraslado.toUpperCase()),
        const SizedBox(height: 4),
        _buildDatoItem(Icons.repeat_outlined, 'Recurrencia', tipoRecurrencia),
        const SizedBox(height: 4),
        _buildDatoItem(Icons.local_shipping_outlined, 'Tipo Ambulancia', tipoAmbulancia.toUpperCase()),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(child: _buildDatoItem(Icons.calendar_today_outlined, 'F. Inicio', fechaInicio)),
            Expanded(child: _buildDatoItem(Icons.event_outlined, 'F. Fin', fechaFin)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(child: _buildDatoItem(Icons.access_time, 'H. Recogida', horaRecogida)),
            if (requiereVuelta) Expanded(child: _buildDatoItem(Icons.access_time_filled, 'H. Vuelta', horaVuelta)),
          ],
        ),
      ],
    );
  }

  /// Sección de recursos asignados
  Widget _buildRecursosSection(String conductor, String enfermero, String medico, String matricula) {
    return Column(
      children: <Widget>[
        _buildRecursoItem(Icons.drive_eta_outlined, 'Conductor', conductor, AppColors.primary),
        const SizedBox(height: 6),
        _buildRecursoItem(Icons.directions_car_outlined, 'Vehículo', matricula.toUpperCase(), AppColors.secondary),
        const SizedBox(height: 6),
        _buildRecursoItem(Icons.medical_services_outlined, 'Enfermero', enfermero, AppColors.info),
        const SizedBox(height: 6),
        _buildRecursoItem(Icons.local_hospital_outlined, 'Médico', medico, const Color(0xFF7C3AED)),
      ],
    );
  }

  /// Item de recurso individual
  Widget _buildRecursoItem(IconData icono, String label, String valor, Color color) {
    final bool sinAsignar = valor == 'Sin asignar' || valor == '-' || valor.isEmpty;
    return Row(
      children: <Widget>[
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: sinAsignar ? AppColors.gray100 : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icono, size: 12, color: sinAsignar ? AppColors.gray400 : color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: GoogleFonts.inter(fontSize: 8, color: AppColors.textSecondaryLight)),
              Text(
                valor.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: sinAsignar ? AppColors.gray400 : AppColors.textPrimaryLight,
                  fontStyle: sinAsignar ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Verifica si tiene requisitos especiales
  bool _tieneRequisitos(ServicioEntity servicio) {
    return servicio.requiereSillaRuedas || servicio.requiereCamilla || servicio.requiereAyuda || servicio.requiereAcompanante;
  }

  /// Sección de requisitos especiales
  Widget _buildRequisitosSection(ServicioEntity servicio) {
    final List<Map<String, dynamic>> requisitos = <Map<String, dynamic>>[
      <String, dynamic>{'label': 'Silla de Ruedas', 'icono': Icons.accessible, 'activo': servicio.requiereSillaRuedas},
      <String, dynamic>{'label': 'Camilla', 'icono': Icons.airline_seat_flat, 'activo': servicio.requiereCamilla},
      <String, dynamic>{'label': 'Requiere Ayuda', 'icono': Icons.support, 'activo': servicio.requiereAyuda},
      <String, dynamic>{'label': 'Acompañante', 'icono': Icons.group, 'activo': servicio.requiereAcompanante},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: requisitos.map((Map<String, dynamic> req) {
        final bool activo = req['activo'] as bool;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: activo ? AppColors.success.withValues(alpha: 0.1) : AppColors.gray100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: activo ? AppColors.success.withValues(alpha: 0.3) : AppColors.gray200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(req['icono'] as IconData, size: 12, color: activo ? AppColors.success : AppColors.gray400),
              const SizedBox(width: 4),
              Text(
                req['label'] as String,
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: activo ? AppColors.success : AppColors.gray400),
              ),
              const SizedBox(width: 3),
              Icon(activo ? Icons.check_circle : Icons.cancel, size: 10, color: activo ? AppColors.success : AppColors.gray400),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Sección de timeline/seguimiento
  Widget _buildTimelineSection(TrasladoEntity traslado) {
    final List<Map<String, dynamic>> pasos = <Map<String, dynamic>>[
      <String, dynamic>{'label': 'Enviado', 'fecha': traslado.fechaEnviado, 'icono': Icons.send},
      <String, dynamic>{'label': 'Recibido', 'fecha': traslado.fechaRecibidoConductor, 'icono': Icons.check_circle},
      <String, dynamic>{'label': 'En Origen', 'fecha': traslado.fechaEnOrigen, 'icono': Icons.location_on},
      <String, dynamic>{'label': 'En Tránsito', 'fecha': traslado.fechaSaliendoOrigen, 'icono': Icons.directions_car},
      <String, dynamic>{'label': 'En Destino', 'fecha': traslado.fechaEnDestino, 'icono': Icons.flag},
      <String, dynamic>{'label': 'Finalizado', 'fecha': traslado.fechaFinalizado, 'icono': Icons.done_all},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: pasos.asMap().entries.map((MapEntry<int, Map<String, dynamic>> entry) {
        final int index = entry.key;
        final Map<String, dynamic> paso = entry.value;
        final DateTime? fecha = paso['fecha'] as DateTime?;
        final bool completado = fecha != null;
        final bool esUltimo = index == pasos.length - 1;

        return Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: completado ? AppColors.success : AppColors.gray100,
                        shape: BoxShape.circle,
                        border: Border.all(color: completado ? AppColors.success : AppColors.gray200, width: 1.5),
                      ),
                      child: Icon(paso['icono'] as IconData, size: 11, color: completado ? Colors.white : AppColors.gray400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paso['label'] as String,
                      style: GoogleFonts.inter(fontSize: 7, fontWeight: completado ? FontWeight.w600 : FontWeight.normal, color: completado ? AppColors.textPrimaryLight : AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      completado ? DateFormat('HH:mm').format(fecha) : '--:--',
                      style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: completado ? AppColors.success : AppColors.gray400),
                    ),
                    if (completado)
                      Text(
                        DateFormat('dd/MM').format(fecha),
                        style: GoogleFonts.inter(fontSize: 7, color: AppColors.textSecondaryLight),
                      ),
                  ],
                ),
              ),
              if (!esUltimo)
                Container(
                  width: 10,
                  height: 1.5,
                  margin: const EdgeInsets.only(bottom: 18),
                  color: completado ? AppColors.success : AppColors.gray200,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Sección de observaciones
  Widget _buildObservacionesSection(TrasladoEntity traslado, ServicioEntity? servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (traslado.observaciones != null && traslado.observaciones!.isNotEmpty) ...<Widget>[
          _buildObservacionItem('Observaciones del Traslado', traslado.observaciones!, Icons.note_outlined, AppColors.info),
          const SizedBox(height: 6),
        ],
        if (traslado.observacionesMedicas != null && traslado.observacionesMedicas!.isNotEmpty) ...<Widget>[
          _buildObservacionItem('Observaciones Médicas', traslado.observacionesMedicas!, Icons.medical_information_outlined, AppColors.warning),
          const SizedBox(height: 6),
        ],
        if (servicio?.observaciones != null && servicio!.observaciones!.isNotEmpty) ...<Widget>[
          _buildObservacionItem('Observaciones del Servicio', servicio.observaciones!, Icons.assignment_outlined, AppColors.secondary),
          const SizedBox(height: 6),
        ],
        if (servicio?.observacionesMedicas != null && servicio!.observacionesMedicas!.isNotEmpty)
          _buildObservacionItem('Observaciones Médicas', servicio.observacionesMedicas!, Icons.medical_information, AppColors.error),
      ],
    );
  }

  /// Item de observación individual
  Widget _buildObservacionItem(String titulo, String texto, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icono, size: 11, color: color),
              const SizedBox(width: 4),
              Text(titulo, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(texto, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textPrimaryLight, height: 1.4)),
        ],
      ),
    );
  }

  /// Sección de auditoría
  Widget _buildAuditoriaSection(TrasladoEntity traslado, ServicioEntity? servicio) {
    final String createdAt = DateFormat('dd/MM/yyyy HH:mm').format(traslado.createdAt);
    final String updatedAt = DateFormat('dd/MM/yyyy HH:mm').format(traslado.updatedAt);
    final String fechaAsignacion = traslado.fechaAsignacion != null ? DateFormat('dd/MM/yyyy HH:mm').format(traslado.fechaAsignacion!) : '-';

    return Row(
      children: <Widget>[
        Expanded(child: _buildDatoItem(Icons.add_circle_outline, 'Creado', createdAt)),
        Expanded(child: _buildDatoItem(Icons.edit_outlined, 'Actualizado', updatedAt)),
        Expanded(child: _buildDatoItem(Icons.assignment_ind_outlined, 'Asignado', fechaAsignacion)),
      ],
    );
  }

  /// Footer profesional con botones
  Widget _buildFooterProfesional(BuildContext dialogContext, TrasladoEntity traslado, ServicioEntity? servicio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Info del traslado
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline, size: 12, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text('ID: ${traslado.id.substring(0, 8)}...', style: GoogleFonts.robotoMono(fontSize: 9, color: AppColors.textSecondaryLight)),
            ],
          ),
          // Botones de acción
          Row(
            children: <Widget>[
              if (servicio != null && onEditarServicio != null)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onEditarServicio!(servicio);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text('Editar', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close, size: 14),
                label: Text('Cerrar', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según la prioridad
  Color _getColorPrioridad(int prioridad) {
    if (prioridad <= 3) {
      return AppColors.error;
    }
    if (prioridad <= 6) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  /// Obtiene el color según el estado
  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente': return AppColors.warning;
      case 'asignado': return AppColors.info;
      case 'enviado': case 'recibido por conductor': return AppColors.primary;
      case 'en origen': case 'saliendo de origen': case 'en tránsito': return AppColors.secondary;
      case 'en destino': case 'finalizado': return AppColors.success;
      case 'cancelado': case 'anulado': case 'no realizado': return AppColors.error;
      default: return AppColors.textSecondaryLight;
    }
  }

  /// Construye la dirección completa del paciente
  String _buildDireccionCompleta(PacienteEntity? paciente) {
    if (paciente == null) {
      return 'No disponible';
    }
    final StringBuffer direccion = StringBuffer();
    if (paciente.domicilioDireccion != null && paciente.domicilioDireccion!.isNotEmpty) {
      direccion.write(paciente.domicilioDireccion);
    }
    if (paciente.domicilioPiso != null && paciente.domicilioPiso!.isNotEmpty) {
      direccion.write(', Piso ${paciente.domicilioPiso}');
    }
    if (paciente.domicilioPuerta != null && paciente.domicilioPuerta!.isNotEmpty) {
      direccion.write(', Pta ${paciente.domicilioPuerta}');
    }
    return direccion.isEmpty ? 'No disponible' : direccion.toString();
  }

  /// Construye el detalle del origen o destino
  String _buildOrigenDestinoDetalle(String? tipo, String? valor, String? ubicacionCentro, PacienteEntity? paciente) {
    if (tipo == 'centro_hospitalario' && valor != null && valor.isNotEmpty) {
      final String ubicacion = ubicacionCentro != null && ubicacionCentro.isNotEmpty ? ' ($ubicacionCentro)' : '';
      return '$valor$ubicacion';
    }
    if (tipo == 'domicilio_paciente' && paciente != null) {
      return _buildDireccionCompleta(paciente);
    }
    return valor ?? 'DOMICILIO';
  }

  /// Obtiene la localidad según el tipo de origen/destino
  String _getLocalidadParaTipo(String? tipo, String? valor, PacienteEntity? paciente) {
    if (tipo == 'domicilio_paciente' && paciente?.localidadId != null) {
      return localidadesPorId[paciente!.localidadId!] ?? '-';
    }
    if (tipo == 'centro_hospitalario' && valor != null && valor.isNotEmpty) {
      return localidadesPorNombreHospital[valor] ?? '-';
    }
    return '-';
  }

  /// Verifica si hay observaciones
  bool _hayObservaciones(TrasladoEntity traslado, ServicioEntity? servicio) {
    return (traslado.observaciones != null && traslado.observaciones!.isNotEmpty) ||
        (traslado.observacionesMedicas != null && traslado.observacionesMedicas!.isNotEmpty) ||
        (servicio?.observaciones != null && servicio!.observaciones!.isNotEmpty) ||
        (servicio?.observacionesMedicas != null && servicio!.observacionesMedicas!.isNotEmpty);
  }

  /// Solicita asignación de conductor para un traslado individual
  void _solicitarAsignacionConductor(TrasladoEntity traslado, ServicioEntity? servicio) {
    // Usar paciente del servicio
    final PacienteEntity? paciente = servicio?.paciente;
    final String pacienteNombre = paciente != null
        ? '${paciente.nombre} ${paciente.primerApellido}${paciente.segundoApellido != null ? ' ${paciente.segundoApellido}' : ''}'
        : '';

    if (onAsignarConductorRequested != null) {
      onAsignarConductorRequested!(traslado.id, pacienteNombre);
    }
  }

  List<DataTableCell> _buildHorasCronologicas(TrasladoEntity traslado) {
    return <DataTableCell>[
      DataTableCell(
        child: _buildHoraCronologicaCell(
          traslado.fechaEnviado != null ? DateFormat('HH:mm').format(traslado.fechaEnviado!) : '',
        ),
        alignment: Alignment.center,
      ),
      DataTableCell(
        child: _buildHoraCronologicaCell(
          traslado.fechaRecibidoConductor != null ? DateFormat('HH:mm').format(traslado.fechaRecibidoConductor!) : '',
        ),
        alignment: Alignment.center,
      ),
      DataTableCell(
        child: _buildHoraCronologicaCell(
          traslado.fechaEnOrigen != null ? DateFormat('HH:mm').format(traslado.fechaEnOrigen!) : '',
        ),
        alignment: Alignment.center,
      ),
      DataTableCell(
        child: _buildHoraCronologicaCell(
          traslado.fechaSaliendoOrigen != null ? DateFormat('HH:mm').format(traslado.fechaSaliendoOrigen!) : '',
        ),
        alignment: Alignment.center,
      ),
      DataTableCell(
        child: _buildHoraCronologicaCell(
          traslado.fechaEnDestino != null ? DateFormat('HH:mm').format(traslado.fechaEnDestino!) : '',
        ),
        alignment: Alignment.center,
      ),
      DataTableCell(
        child: _buildHoraCronologicaCell(
          traslado.fechaFinalizado != null ? DateFormat('HH:mm').format(traslado.fechaFinalizado!) : '',
        ),
        alignment: Alignment.center,
      ),
    ];
  }

  /// Construye la celda de hora cronológica con estilo destacado (negrita y más grande)
  Widget _buildHoraCronologicaCell(String hora) {
    if (hora.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      hora,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<DataTableCell> _buildCheckboxesRequisitos(TrasladoEntity traslado) {
    return <DataTableCell>[
      // SIC = Solo Silla de Ruedas
      DataTableCell(
        child: _buildCheckboxCell(traslado.requiereSillaRuedas),
        alignment: Alignment.center,
      ),
      // CA = Solo Camilla
      DataTableCell(child: _buildCheckboxCell(traslado.requiereCamilla), alignment: Alignment.center),
      // Ayu = Ayuda
      DataTableCell(child: _buildCheckboxCell(traslado.requiereAyuda), alignment: Alignment.center),
      // Ac = Acompañante
      DataTableCell(child: _buildCheckboxCell(traslado.requiereAcompanante), alignment: Alignment.center),
    ];
  }

  Widget _buildCellText(String text, bool negrita, double tamTexto) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: tamTexto,
        fontWeight: negrita ? FontWeight.w600 : FontWeight.normal,
        color: AppColors.textPrimaryLight,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCheckboxCell(bool value) {
    return Icon(
      value ? Icons.check_box : Icons.check_box_outline_blank,
      size: 16,
      color: value ? AppColors.success : AppColors.gray400,
    );
  }

  Color _getEstatusColor(TrasladoEntity traslado) {
    switch (traslado.estado) {
      // Rojo: Estados finales negativos
      case EstadoTraslado.cancelado:
      case EstadoTraslado.noRealizado:
      case EstadoTraslado.finalizado:
        return AppColors.error;
      // Azul: Pendiente
      case EstadoTraslado.pendiente:
        return AppColors.info;
      // Verde: Todos los demás estados activos
      case EstadoTraslado.asignado:
      case EstadoTraslado.enviado:
      case EstadoTraslado.recibido:
      case EstadoTraslado.enOrigen:
      case EstadoTraslado.saliendoOrigen:
      case EstadoTraslado.enTransito:
      case EstadoTraslado.enDestino:
        return AppColors.success;
    }
  }

  /// Obtiene el texto de visualización para el estado del traslado
  /// Usa el label del enum pero cambia "SALIENDO" por "EN RUTA"
  String _getEstatusTexto(EstadoTraslado estado) {
    // Caso especial: mostrar "EN RUTA" en lugar de "SALIENDO"
    if (estado == EstadoTraslado.saliendoOrigen) {
      return 'EN RUTA';
    }
    // Para el resto, usar el label del enum
    return estado.label;
  }

  /// Construye la celda de hora programada con estilo destacado
  Widget _buildHoraCell(String hora) {
    return Text(
      hora,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Formatea la hora a formato HH:mm (quita los segundos si vienen en formato HH:mm:ss)
  String _formatearHora(String hora) {
    if (hora.isEmpty) {
      return '';
    }
    // Si viene en formato HH:mm:ss, extraer solo HH:mm
    final List<String> partes = hora.split(':');
    if (partes.length >= 2) {
      return '${partes[0]}:${partes[1]}';
    }
    return hora;
  }

  /// Obtiene el valor de una columna para filtrado
  String obtenerValorColumna(TrasladoEntity traslado, String columna) {
    final ServicioEntity? servicio = serviciosPorTraslado[traslado.id];
    // Usar paciente del servicio
    final PacienteEntity? paciente = servicio?.paciente;

    switch (columna) {
      case 'tipoTraslado':
        return traslado.tipoTraslado.toUpperCase();
      case 'paciente':
        return paciente != null
            ? '${paciente.nombre} ${paciente.primerApellido}'
            : '';
      case 'terapia':
        // Usar motivo traslado del servicio
        return servicio?.motivoTraslado?.nombre ?? '';
      case 'estatus':
        return traslado.estado.name;
      case 'conductor':
        return traslado.idConductor != null
            ? (personalPorId[traslado.idConductor!] ?? traslado.conductorNombre ?? '')
            : '';
      case 'matricula':
        return traslado.matriculaVehiculo ?? '';
      default:
        return '';
    }
  }
}
