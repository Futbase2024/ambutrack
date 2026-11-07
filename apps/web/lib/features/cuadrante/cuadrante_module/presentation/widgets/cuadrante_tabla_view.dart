import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_bloc.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_event.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/bloc/cuadrante_state.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/turnos_state.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/turno_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Vista de tabla semanal del cuadrante
class CuadranteTablaView extends StatelessWidget {
  const CuadranteTablaView({required this.state, super.key});

  final CuadranteLoaded state;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TurnosBloc, TurnosState>(
      listener: (BuildContext context, TurnosState turnosState) {
        if (turnosState is TurnosOperationSuccess) {
          debugPrint('✅ Operación de turno exitosa, refrescando cuadrante...');
          // Refrescar el cuadrante para mostrar los cambios usando addPostFrameCallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<CuadranteBloc>().add(const CuadranteRefreshRequested());
            }
          });
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (state.personalConTurnos.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingSmall),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.gray200),
        ),
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header de la tabla
              _buildTableHeader(),

              // Filas de personal
              ...state.personalConTurnos.map(_buildPersonalRow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              'No hay personal disponible',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Text(
              'Ajusta los filtros o agrega personal al sistema',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    final List<DateTime> diasSemana = _getDiasSemana();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.paddingMedium,
      ),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray300, width: 2)),
      ),
      child: Row(
        children: <Widget>[
          // Columna de personal (fija)
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
              child: Text(
                'Personal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          // Columnas de días
          ...diasSemana.map((DateTime dia) => Expanded(child: _buildDiaHeader(dia))),
        ],
      ),
    );
  }

  Widget _buildDiaHeader(DateTime dia) {
    final DateFormat formatoDia = DateFormat('EEE', 'es_ES');
    final DateFormat formatoFecha = DateFormat('d MMM', 'es_ES');
    final bool esHoy = _esHoy(dia);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: esHoy ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: <Widget>[
          Text(
            formatoDia.format(dia).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: esHoy ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            formatoFecha.format(dia),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: esHoy ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalRow(PersonalConTurnosEntity personalConTurnos) {
    final List<DateTime> diasSemana = _getDiasSemana();

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Columna de información del personal
            SizedBox(
              width: 200,
              child: _buildPersonalInfo(personalConTurnos),
            ),

            // Columnas de turnos por día
            ...diasSemana.map((DateTime dia) {
              final List<TurnoEntity> turnosDelDia =
                  personalConTurnos.getTurnosParaFecha(dia);
              return Expanded(
                child: _buildTurnoCell(personalConTurnos, dia, turnosDelDia),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(PersonalConTurnosEntity personalConTurnos) {
    final String categoria = personalConTurnos.personal.categoriaServicio.displayText;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            personalConTurnos.personal.nombreCompleto,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            categoria,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoCell(
    PersonalConTurnosEntity personalConTurnos,
    DateTime dia,
    List<TurnoEntity> turnos,
  ) {
    final bool esHoy = _esHoy(dia);

    return Builder(
      builder: (BuildContext context) {
        return DragTarget<TurnoEntity>(
          onWillAcceptWithDetails: (DragTargetDetails<TurnoEntity> details) {
            final TurnoEntity turnoArrastrado = details.data;

            // Rechazar si se arrastra a la misma celda (mismo personal + misma fecha)
            final bool mismaCelda = turnoArrastrado.idPersonal == personalConTurnos.personal.id &&
                _mismaFecha(turnoArrastrado.fechaInicio, dia);

            if (mismaCelda) {
              return false;
            }

            // Permitir arrastrar a diferente fecha o diferente personal
            return true;
          },
          onAcceptWithDetails: (DragTargetDetails<TurnoEntity> details) {
            _handleTurnoDrop(context, details.data, personalConTurnos, dia);
          },
          builder: (
            BuildContext context,
            List<TurnoEntity?> candidateData,
            List<dynamic> rejectedData,
          ) {
            final bool isHovering = candidateData.isNotEmpty;
            final bool hasRejected = rejectedData.isNotEmpty;

            return Container(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              decoration: BoxDecoration(
                color: hasRejected
                    ? AppColors.error.withValues(alpha: 0.1)
                    : (isHovering
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : (esHoy ? AppColors.gray50 : Colors.transparent)),
                border: Border.all(
                  color: hasRejected
                      ? AppColors.error
                      : (isHovering ? AppColors.primary : AppColors.gray100),
                  width: (isHovering || hasRejected) ? 2 : 1,
                ),
              ),
              child: turnos.isEmpty
                  ? _buildEmptyTurnoCell(personalConTurnos, dia)
                  : _buildTurnoChips(turnos, personalConTurnos, dia),
            );
          },
        );
      },
    );
  }

  /// Maneja el drop de un turno en una celda
  Future<void> _handleTurnoDrop(
    BuildContext context,
    TurnoEntity turnoOriginal,
    PersonalConTurnosEntity personalConTurnos,
    DateTime nuevaFecha,
  ) async {
    final bool esMismoConductor = turnoOriginal.idPersonal == personalConTurnos.personal.id;
    final String tipoCopia = esMismoConductor ? 'MISMO CONDUCTOR' : 'DIFERENTE CONDUCTOR';

    // Log de valores originales para debugging
    debugPrint('DRAG & DROP - Turno original:');
    debugPrint('   Conductor: ${turnoOriginal.nombrePersonal}');
    debugPrint('   categoriaPersonal: ${turnoOriginal.categoriaPersonal ?? "NULL"}');
    debugPrint('   idContrato: ${turnoOriginal.idContrato ?? "NULL"}');
    debugPrint('   idDotacion: ${turnoOriginal.idDotacion ?? "NULL"}');
    debugPrint('   idVehiculo: ${turnoOriginal.idVehiculo ?? "NULL"}');
    debugPrint('   idBase: ${turnoOriginal.idBase ?? "NULL"}');
    debugPrint('Copiando a: ${personalConTurnos.personal.nombreCompleto} el $nuevaFecha');
    debugPrint('Tipo copia: $tipoCopia');

    // Calcular fechaFin respetando si el turno original cruzaba medianoche
    final bool cruzaMedianoche = !_mismaFecha(turnoOriginal.fechaInicio, turnoOriginal.fechaFin);
    final DateTime fechaFin = cruzaMedianoche
        ? nuevaFecha.add(const Duration(days: 1))
        : nuevaFecha;

    // Validar conflicto de vehículo solo si es diferente conductor y tiene vehículo asignado
    String? idVehiculoFinal = turnoOriginal.idVehiculo;

    if (!esMismoConductor && turnoOriginal.idVehiculo != null) {
      final bool hayConflicto = _verificarConflictoVehiculo(
        turnoOriginal.idVehiculo!,
        nuevaFecha,
        turnoOriginal.horaInicio,
        turnoOriginal.horaFin,
        state,
      );

      if (hayConflicto) {
        // Mostrar diálogo de confirmación
        final bool? copiarSinVehiculo = await _mostrarDialogoConflictoVehiculo(
          context,
          turnoOriginal,
          personalConTurnos.personal.nombreCompleto,
          state,
        );

        if (copiarSinVehiculo == null) {
          // Usuario canceló
          debugPrint('Usuario canceló la copia del turno');
          return;
        }

        if (copiarSinVehiculo) {
          // Copiar sin vehículo
          idVehiculoFinal = null;
          debugPrint('Copiando turno SIN vehiculo debido a conflicto');
        }
        // Si copiarSinVehiculo == false, se mantiene el vehículo (usuario eligió copiar con conflicto)
      }
    }

    // Crear nuevo turno copiando TODOS los datos del original
    // Incluye: categoriaPersonal, contrato, dotación, vehículo (si no hay conflicto), base, observaciones
    final TurnoEntity nuevoTurno = TurnoEntity(
      id: const Uuid().v4(), // Nuevo ID
      idPersonal: personalConTurnos.personal.id,
      nombrePersonal: personalConTurnos.personal.nombreCompleto,
      categoriaPersonal: turnoOriginal.categoriaPersonal, // Copiar del turno original
      tipoTurno: turnoOriginal.tipoTurno,
      fechaInicio: nuevaFecha,
      fechaFin: fechaFin,
      horaInicio: turnoOriginal.horaInicio,
      horaFin: turnoOriginal.horaFin,
      // Copiar TODO siempre
      idBase: turnoOriginal.idBase,
      idVehiculo: idVehiculoFinal, // Puede ser null si hubo conflicto y usuario eligió copiar sin vehículo
      idDotacion: turnoOriginal.idDotacion,
      idContrato: turnoOriginal.idContrato,
      observaciones: turnoOriginal.observaciones,
    );

    // Log simplificado para evitar errores con emojis y operadores null-coalescing
    final String categoriaInfo = nuevoTurno.categoriaPersonal ?? 'Sin funcion';
    final String vehiculoInfo = nuevoTurno.idVehiculo ?? 'Sin asignar';
    final String baseInfo = nuevoTurno.idBase ?? 'Sin asignar';
    final String dotacionInfo = nuevoTurno.idDotacion ?? 'Sin asignar';
    final String contratoInfo = nuevoTurno.idContrato ?? 'Sin asignar';

    debugPrint('Nuevo turno creado para ${nuevoTurno.nombrePersonal}');
    debugPrint('   Tipo: ${nuevoTurno.tipoTurno.nombre}, Horario: ${nuevoTurno.horaInicio} - ${nuevoTurno.horaFin}');
    debugPrint('   Funcion: $categoriaInfo, Vehiculo: $vehiculoInfo, Base: $baseInfo');
    debugPrint('   Dotacion: $dotacionInfo, Contrato: $contratoInfo');

    // Crear el turno (el feedback se mostrará desde cuadrante_view.dart)
    if (context.mounted) {
      context.read<TurnosBloc>().add(TurnoCreateRequested(nuevoTurno));
    }
  }

  Widget _buildEmptyTurnoCell(PersonalConTurnosEntity personalConTurnos, DateTime dia) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () => _showAsignarTurnoDialog(context, personalConTurnos, dia),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.gray200,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add_circle_outline,
                size: 18,
                color: AppColors.gray400,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Muestra el diálogo para asignar un turno
  Future<void> _showAsignarTurnoDialog(
    BuildContext context,
    PersonalConTurnosEntity personalConTurnos,
    DateTime fecha,
  ) async {
    debugPrint(
      '📅 Abriendo diálogo para asignar turno a ${personalConTurnos.personal.nombreCompleto} el ${fecha.toString()}',
    );

    // Capturar los BLoCs antes de abrir el diálogo
    final TurnosBloc turnosBloc = context.read<TurnosBloc>();
    final CuadranteBloc cuadranteBloc = context.read<CuadranteBloc>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        debugPrint('🔨 Builder del diálogo ejecutado');
        // El TurnoFormDialog maneja su propio cierre y muestra ResultDialog
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<TurnosBloc>.value(value: turnosBloc),
            BlocProvider<CuadranteBloc>.value(value: cuadranteBloc),
          ],
          child: TurnoFormDialog(
            personal: personalConTurnos.personal,
            fechaInicio: fecha,
          ),
        );
      },
    );

    debugPrint('✅ Diálogo cerrado, showDialog completado');
  }

  Widget _buildTurnoChips(
    List<TurnoEntity> turnos,
    PersonalConTurnosEntity personalConTurnos,
    DateTime dia,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Chips de turnos existentes
        ...turnos.map((TurnoEntity turno) => _buildTurnoChip(turno, dia)),
        // Botón para agregar otro turno
        const SizedBox(height: 4),
        _buildAddTurnoButton(personalConTurnos, dia),
      ],
    );
  }

  /// Botón pequeño para agregar un turno adicional
  Widget _buildAddTurnoButton(PersonalConTurnosEntity personalConTurnos, DateTime dia) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () => _showAsignarTurnoDialog(context, personalConTurnos, dia),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: AppColors.gray300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.add_circle_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Añadir turno',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnoChip(TurnoEntity turno, DateTime dia) {
    // Detectar tipo especial de turno
    final bool cruzaMedianoche = _cruzaMedianoche(turno);
    final bool esTurno24h = _esTurno24Horas(turno);
    final bool esTurno12hDia = _esTurno12HorasDia(turno);
    final bool esTurno12hNoche = _esTurno12HorasNoche(turno);

    // Determinar color, emoji y texto según tipo especial
    late Color color;
    late String emoji;
    late String tipoTurnoText;

    if (esTurno24h) {
      color = AppColors.turnoMorado;
      emoji = '🚨';
      tipoTurnoText = '24 Horas';
    } else if (esTurno12hDia) {
      color = AppColors.turnoTurquesa;
      emoji = '☀️';
      tipoTurnoText = '12h Día';
    } else if (esTurno12hNoche) {
      color = AppColors.turnoAzul;
      emoji = '🌙';
      tipoTurnoText = '12h Noche';
    } else {
      color = _getTurnoColor(turno.tipoTurno);
      emoji = _getTurnoEmoji(turno.tipoTurno);
      tipoTurnoText = turno.tipoTurno.nombre;
    }

    // Calcular horarios a mostrar según el día
    String horaInicioDisplay = turno.horaInicio;
    String horaFinDisplay = turno.horaFin;

    if (cruzaMedianoche) {
      final bool esPrimerDia = _mismaFecha(dia, turno.fechaInicio);
      if (esPrimerDia) {
        // Primer día: horaInicio → 00:00
        horaFinDisplay = '00:00';
      } else {
        // Segundo día: 00:00 → horaFin
        horaInicioDisplay = '00:00';
      }
    }

    // Buscar matrícula del vehículo si existe
    String? vehiculoMatricula;
    if (turno.idVehiculo != null && turno.idVehiculo!.isNotEmpty) {
      try {
        final VehiculoEntity vehiculo = state.vehiculos.firstWhere(
          (VehiculoEntity v) => v.id == turno.idVehiculo,
        );
        vehiculoMatricula = vehiculo.matricula;
      } catch (e) {
        debugPrint('⚠️ Vehículo ${turno.idVehiculo} no encontrado en lista');
      }
    }

    // Crear tooltip con información del turno
    final String vehiculoInfo = vehiculoMatricula != null
        ? '\n🚗 Vehículo: $vehiculoMatricula'
        : '';

    final String tooltipText = '''
$tipoTurnoText
Horario: $horaInicioDisplay - $horaFinDisplay${cruzaMedianoche ? ' (continúa)' : ''}$vehiculoInfo
${turno.observaciones != null && turno.observaciones!.isNotEmpty ? 'Observaciones: ${turno.observaciones}' : ''}
Arrastra para copiar'''.trim();

    return _TurnoChipWithHover(
      turno: turno,
      color: color,
      emoji: emoji,
      tooltipText: tooltipText,
      tipoTurnoText: tipoTurnoText,
      horaInicioDisplay: horaInicioDisplay,
      horaFinDisplay: horaFinDisplay,
      vehiculoMatricula: vehiculoMatricula,
      onTap: _showEditarTurnoDialog,
      onDelete: _confirmDeleteTurno,
    );
  }

  /// Confirma la eliminación del turno
  Future<void> _confirmDeleteTurno(BuildContext context, TurnoEntity turno) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Confirmar Eliminación',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '¿Estás seguro de que deseas eliminar este turno?',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildInfoRow('Personal:', turno.nombrePersonal),
                    _buildInfoRow('Turno:', turno.tipoTurno.nombre),
                    _buildInfoRow('Horario:', '${turno.horaInicio} - ${turno.horaFin}'),
                    _buildInfoRow(
                      'Fecha:',
                      '${turno.fechaInicio.day}/${turno.fechaInicio.month}/${turno.fechaInicio.year}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Eliminar', style: GoogleFonts.inter()),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      debugPrint('🗑️ Eliminando turno: ${turno.id}');
      context.read<TurnosBloc>().add(TurnoDeleteRequested(turno.id));
    }
  }

  /// Helper para mostrar filas de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo para editar un turno existente
  Future<void> _showEditarTurnoDialog(
    BuildContext context,
    TurnoEntity turno,
  ) async {
    debugPrint(
      '✏️ Abriendo diálogo para editar turno: ${turno.nombrePersonal} - ${turno.tipoTurno.nombre}',
    );

    // Capturar los BLoCs antes de abrir el diálogo
    final TurnosBloc turnosBloc = context.read<TurnosBloc>();
    final CuadranteBloc cuadranteBloc = context.read<CuadranteBloc>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        debugPrint('🔨 Builder del diálogo EDITAR ejecutado');
        // El TurnoFormDialog maneja su propio cierre y muestra ResultDialog
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<TurnosBloc>.value(value: turnosBloc),
            BlocProvider<CuadranteBloc>.value(value: cuadranteBloc),
          ],
          child: TurnoFormDialog(
            turno: turno, // Pasar el turno existente para edición
          ),
        );
      },
    );

    debugPrint('✅ Diálogo EDITAR cerrado, showDialog completado');
  }

  List<DateTime> _getDiasSemana() {
    final List<DateTime> dias = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      dias.add(state.primerDiaSemana.add(Duration(days: i)));
    }
    return dias;
  }

  bool _esHoy(DateTime dia) {
    final DateTime hoy = DateTime.now();
    return dia.year == hoy.year && dia.month == hoy.month && dia.day == hoy.day;
  }

  /// Compara dos fechas ignorando la hora
  bool _mismaFecha(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  /// Detecta si un turno cruza medianoche
  /// Un turno cruza medianoche si fechaFin != fechaInicio
  bool _cruzaMedianoche(TurnoEntity turno) {
    return !_mismaFecha(turno.fechaInicio, turno.fechaFin);
  }

  /// Detecta si un turno es de 24 horas
  /// Un turno de 24h tiene horaInicio == horaFin y cruza medianoche
  bool _esTurno24Horas(TurnoEntity turno) {
    return _cruzaMedianoche(turno) && turno.horaInicio == turno.horaFin;
  }

  /// Detecta si un turno es de 12 horas
  /// Calcula la duración en minutos entre horaInicio y horaFin
  bool _esTurno12Horas(TurnoEntity turno) {
    final List<String> partesInicio = turno.horaInicio.split(':');
    final List<String> partesFin = turno.horaFin.split(':');

    if (partesInicio.length != 2 || partesFin.length != 2) {
      return false;
    }

    final int minutosInicio = (int.tryParse(partesInicio[0]) ?? 0) * 60 + (int.tryParse(partesInicio[1]) ?? 0);
    int minutosFin = (int.tryParse(partesFin[0]) ?? 0) * 60 + (int.tryParse(partesFin[1]) ?? 0);

    // Si cruza medianoche, sumar 24 horas al fin
    if (_cruzaMedianoche(turno)) {
      minutosFin += 24 * 60;
    }

    final int duracionMinutos = minutosFin - minutosInicio;
    final double duracionHoras = duracionMinutos / 60.0;

    // Considerar 12 horas si la duración está entre 11.5 y 12.5 horas
    return duracionHoras >= 11.5 && duracionHoras <= 12.5;
  }

  /// Detecta si es un turno de 12 horas diurno (día)
  /// Generalmente 08:00-20:00 o similar, mismo día
  bool _esTurno12HorasDia(TurnoEntity turno) {
    return _esTurno12Horas(turno) && !_cruzaMedianoche(turno);
  }

  /// Detecta si es un turno de 12 horas nocturno
  /// Generalmente 20:00-08:00 o similar, cruza medianoche
  bool _esTurno12HorasNoche(TurnoEntity turno) {
    return _esTurno12Horas(turno) && _cruzaMedianoche(turno);
  }

  Color _getTurnoColor(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return AppColors.success; // 🟢 Verde
      case TipoTurno.tarde:
        return AppColors.turnoNaranja; // 🟠 Naranja
      case TipoTurno.noche:
        return AppColors.turnoAzul; // 🔵 Azul
      case TipoTurno.personalizado:
        return AppColors.turnoGris; // ⚪ Gris
    }
  }

  String _getTurnoEmoji(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return '🌅';
      case TipoTurno.tarde:
        return '🌆';
      case TipoTurno.noche:
        return '🌙';
      case TipoTurno.personalizado:
        return '⚙️';
    }
  }

  /// Verifica si hay conflicto de vehículo en la fecha y horario especificados
  bool _verificarConflictoVehiculo(
    String idVehiculo,
    DateTime fecha,
    String horaInicio,
    String horaFin,
    CuadranteLoaded state,
  ) {
    // Buscar en todos los turnos del cuadrante si hay alguno con el mismo vehículo
    // en la misma fecha y con horarios que se superpongan
    for (final PersonalConTurnosEntity personalConTurnos in state.personalConTurnos) {
      for (final TurnoEntity turno in personalConTurnos.turnos) {
        // Verificar si es el mismo vehículo
        if (turno.idVehiculo == idVehiculo) {
          // Verificar si es el mismo día
          if (_mismaFecha(turno.fechaInicio, fecha)) {
            // Verificar si los horarios se superponen
            if (_horariosSeSolapan(horaInicio, horaFin, turno.horaInicio, turno.horaFin)) {
              debugPrint('CONFLICTO VEHICULO detectado:');
              debugPrint('   Vehiculo: $idVehiculo');
              debugPrint('   Ya asignado a: ${turno.nombrePersonal}');
              debugPrint('   Horario existente: ${turno.horaInicio} - ${turno.horaFin}');
              debugPrint('   Horario nuevo: $horaInicio - $horaFin');
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  /// Verifica si dos rangos de horarios se solapan
  bool _horariosSeSolapan(String inicio1, String fin1, String inicio2, String fin2) {
    // Convertir strings a minutos desde medianoche para comparar
    final int minInicio1 = _horaAMinutos(inicio1);
    final int minFin1 = _horaAMinutos(fin1);
    final int minInicio2 = _horaAMinutos(inicio2);
    final int minFin2 = _horaAMinutos(fin2);

    // Manejar turnos que cruzan medianoche
    final bool cruzaMedianoche1 = minFin1 < minInicio1;
    final bool cruzaMedianoche2 = minFin2 < minInicio2;

    if (cruzaMedianoche1 || cruzaMedianoche2) {
      // Si alguno cruza medianoche, es más complejo
      // Por simplicidad, consideramos que se solapan si hay turno nocturno
      return true;
    }

    // Verificar solapamiento normal (ninguno cruza medianoche)
    return minInicio1 < minFin2 && minInicio2 < minFin1;
  }

  /// Convierte hora en formato HH:mm a minutos desde medianoche
  int _horaAMinutos(String hora) {
    final List<String> partes = hora.split(':');
    final int horas = int.parse(partes[0]);
    final int minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }

  /// Muestra diálogo de conflicto de vehículo
  /// Retorna true si copiar sin vehículo, false si copiar con vehículo, null si cancelar
  Future<bool?> _mostrarDialogoConflictoVehiculo(
    BuildContext context,
    TurnoEntity turnoOriginal,
    String nombreNuevoConductor,
    CuadranteLoaded state,
  ) async {
    // Buscar el vehículo en el state para mostrar info
    VehiculoEntity? vehiculo;
    try {
      vehiculo = state.vehiculos.firstWhere((VehiculoEntity v) => v.id == turnoOriginal.idVehiculo);
    } catch (e) {
      // No encontrado
    }

    final String vehiculoNombre = vehiculo?.matricula ?? turnoOriginal.idVehiculo ?? 'Desconocido';

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
              const SizedBox(width: 12),
              Text(
                'Conflicto de Vehículo',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'El vehículo $vehiculoNombre ya está asignado a otro conductor en el mismo horario.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildInfoRow('Turno:', turnoOriginal.tipoTurno.nombre),
                      _buildInfoRow('Horario:', '${turnoOriginal.horaInicio} - ${turnoOriginal.horaFin}'),
                      _buildInfoRow('Vehículo:', vehiculoNombre),
                      _buildInfoRow('Nuevo conductor:', nombreNuevoConductor),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Qué deseas hacer?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: Text('Copiar sin Vehículo', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: Text('Copiar de Todas Formas', style: GoogleFonts.inter()),
            ),
          ],
        );
      },
    );
  }
}

/// Widget de turno con hover que muestra icono de eliminar
class _TurnoChipWithHover extends StatefulWidget {
  const _TurnoChipWithHover({
    required this.turno,
    required this.color,
    required this.emoji,
    required this.tooltipText,
    required this.tipoTurnoText,
    required this.horaInicioDisplay,
    required this.horaFinDisplay,
    this.vehiculoMatricula,
    required this.onTap,
    required this.onDelete,
  });

  final TurnoEntity turno;
  final Color color;
  final String emoji;
  final String tooltipText;
  final String tipoTurnoText;
  final String horaInicioDisplay;
  final String horaFinDisplay;
  final String? vehiculoMatricula;
  final void Function(BuildContext, TurnoEntity) onTap;
  final Future<void> Function(BuildContext, TurnoEntity) onDelete;

  @override
  State<_TurnoChipWithHover> createState() => _TurnoChipWithHoverState();
}

class _TurnoChipWithHoverState extends State<_TurnoChipWithHover> {
  bool _isHovering = false;

  /// Obtiene el emoji según la categoría del personal
  String _getCategoriaEmoji(TurnoEntity turno) {
    final String? categoria = turno.categoriaPersonal?.toLowerCase();

    if (categoria == null || categoria.isEmpty) {
      return ''; // Sin emoji si no hay categoría
    }

    // Mapeo de categorías a emojis
    if (categoria.contains('conductor')) {
      return '🚑';
    }
    if (categoria.contains('médico') || categoria.contains('medico')) {
      return '⚕️';
    }
    if (categoria.contains('enfermero') || categoria.contains('enfermera')) {
      return '🩺';
    }
    if (categoria.contains('tes')) {
      return '🚑';
    }
    if (categoria.contains('camillero')) {
      return '🏥';
    }
    if (categoria.contains('administrativo') || categoria.contains('oficina')) {
      return '💼';
    }

    return ''; // Sin emoji por defecto
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltipText,
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: Draggable<TurnoEntity>(
          data: widget.turno,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.7,
              child: _buildChipContainer(isDragging: true),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildChipContainer(),
          ),
          child: GestureDetector(
            onTap: () => widget.onTap(context, widget.turno),
            behavior: HitTestBehavior.opaque,
            child: _buildChipContainer(),
          ),
        ),
      ),
    );
  }

  Widget _buildChipContainer({bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: isDragging ? 0.3 : 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: widget.color.withValues(alpha: isDragging ? 1.0 : 0.4),
          width: isDragging ? 2 : 1.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Contenido del chip
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Primera fila: Tipo de turno (izquierda) + Emoji categoría (derecha)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${widget.emoji} ${widget.tipoTurnoText}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getCategoriaEmoji(widget.turno),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Segunda fila: Horario (izquierda) + Matrícula (derecha)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${widget.horaInicioDisplay} - ${widget.horaFinDisplay}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                  if (widget.vehiculoMatricula != null && widget.vehiculoMatricula!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text('🚑', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 2),
                        Text(
                          widget.vehiculoMatricula!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.color,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),

          // Icono de eliminar (solo visible en hover)
          if (_isHovering && !isDragging)
            Positioned(
              top: -6,
              right: -6,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    // Detener propagación del evento
                    await widget.onDelete(context, widget.turno);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
