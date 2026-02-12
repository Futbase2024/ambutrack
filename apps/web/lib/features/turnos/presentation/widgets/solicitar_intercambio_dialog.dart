import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/features/turnos/domain/repositories/turnos_repository.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_bloc.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_event.dart';
import 'package:ambutrack_web/features/turnos/presentation/bloc/intercambios_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Diálogo para solicitar intercambio de turno
class SolicitarIntercambioDialog extends StatefulWidget {
  const SolicitarIntercambioDialog({
    required this.turnoSolicitante,
    required this.idPersonalSolicitante,
    required this.nombrePersonalSolicitante,
    super.key,
  });

  /// Turno que se quiere intercambiar
  final TurnoEntity turnoSolicitante;

  /// ID del personal solicitante
  final String idPersonalSolicitante;

  /// Nombre del personal solicitante
  final String nombrePersonalSolicitante;

  @override
  State<SolicitarIntercambioDialog> createState() =>
      _SolicitarIntercambioDialogState();
}

class _SolicitarIntercambioDialogState
    extends State<SolicitarIntercambioDialog> {
  final TextEditingController _motivoController = TextEditingController();
  TurnoEntity? _turnoSeleccionado;
  List<TurnoEntity> _turnosDisponibles = <TurnoEntity>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTurnosDisponibles();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _cargarTurnosDisponibles() async {
    try {
      final TurnosRepository repository = getIt<TurnosRepository>();
      final List<TurnoEntity> todosTurnos = await repository.getAll();

      // Filtrar: misma fecha, pero distinto personal
      final List<TurnoEntity> disponibles = todosTurnos.where((TurnoEntity t) {
        final bool mismoDia = t.fechaInicio.year ==
                widget.turnoSolicitante.fechaInicio.year &&
            t.fechaInicio.month == widget.turnoSolicitante.fechaInicio.month &&
            t.fechaInicio.day == widget.turnoSolicitante.fechaInicio.day;
        final bool distintaPersona =
            t.idPersonal != widget.idPersonalSolicitante;

        return mismoDia && distintaPersona;
      }).toList();

      if (mounted) {
        setState(() {
          _turnosDisponibles = disponibles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IntercambiosBloc>(
      create: (_) => getIt<IntercambiosBloc>(),
      child: BlocConsumer<IntercambiosBloc, IntercambiosState>(
        listener: (BuildContext context, IntercambiosState state) {
          if (state is IntercambiosSuccess) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is IntercambiosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (BuildContext context, IntercambiosState state) {
          if (state is IntercambiosProcessing) {
            return _buildLoadingDialog();
          }
          return _buildFormDialog();
        },
      ),
    );
  }

  Widget _buildFormDialog() {
    return AppDialog(
      title: 'Solicitar Intercambio de Turno',
      content: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Turno solicitante (mi turno)
                  _buildSeccionTitulo('📋 Tu Turno Actual'),
                  _buildTurnoCard(widget.turnoSolicitante, esMiTurno: true),
                  const SizedBox(height: AppSizes.spacing),

                  // Selección de turno destino
                  _buildSeccionTitulo('🔄 Selecciona con quién intercambiar'),
                  if (_turnosDisponibles.isEmpty)
                    _buildEmptyState()
                  else
                    ..._buildListaTurnos(),
                  const SizedBox(height: AppSizes.spacing),

                  // Motivo (opcional)
                  _buildSeccionTitulo('💬 Motivo (Opcional)'),
                  TextField(
                    controller: _motivoController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Explica por qué solicitas este intercambio...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      contentPadding: const EdgeInsets.all(
                        AppSizes.paddingMedium,
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
      actions: <Widget>[
        AppButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),
        AppButton(
          onPressed: _turnoSeleccionado == null ? null : _solicitarIntercambio,
          label: 'Solicitar Intercambio',
        ),
      ],
    );
  }

  Widget _buildLoadingDialog() {
    return const AppDialog(
      title: 'Enviando Solicitud',
      maxWidth: 400,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: AppSizes.spacing),
          Text('Creando solicitud de intercambio...'),
        ],
      ),
      actions: <Widget>[],
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Text(
        titulo,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildTurnoCard(TurnoEntity turno, {bool esMiTurno = false}) {
    final DateFormat dateFormatter = DateFormat('EEEE d MMMM', 'es_ES');
    final Color bgColor =
        esMiTurno ? AppColors.info.withValues(alpha: 0.1) : Colors.white;
    final Color borderColor =
        esMiTurno ? AppColors.info : AppColors.gray300;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  turno.nombrePersonal,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatter.format(turno.fechaInicio),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${turno.horaInicio} - ${turno.horaFin}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getTipoTurnoColor(turno.tipoTurno),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              turno.tipoTurno.nombre,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListaTurnos() {
    return _turnosDisponibles.map((TurnoEntity turno) {
      final bool isSelected = _turnoSeleccionado?.id == turno.id;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
        child: InkWell(
          onTap: () {
            setState(() {
              _turnoSeleccionado = turno;
            });
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.gray300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  )
                else
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gray300),
                    ),
                  ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        turno.nombrePersonal,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${turno.horaInicio} - ${turno.horaFin}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTipoTurnoColor(turno.tipoTurno),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Text(
                    turno.tipoTurno.nombre,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.event_busy,
            size: 48,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            'No hay turnos disponibles para intercambiar',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _solicitarIntercambio() {
    if (_turnoSeleccionado == null) {
      return;
    }

    final SolicitudIntercambioEntity solicitud = SolicitudIntercambioEntity(
      id: const Uuid().v4(),
      idTurnoSolicitante: widget.turnoSolicitante.id,
      idPersonalSolicitante: widget.idPersonalSolicitante,
      nombrePersonalSolicitante: widget.nombrePersonalSolicitante,
      idTurnoDestino: _turnoSeleccionado!.id,
      idPersonalDestino: _turnoSeleccionado!.idPersonal,
      nombrePersonalDestino: _turnoSeleccionado!.nombrePersonal,
      estado: EstadoSolicitud.pendienteAprobacionTrabajador,
      motivoSolicitud: _motivoController.text.trim().isEmpty
          ? null
          : _motivoController.text.trim(),
      fechaSolicitud: DateTime.now(),
    );

    context.read<IntercambiosBloc>().add(
          IntercambioCreateRequested(solicitud),
        );
  }

  Color _getTipoTurnoColor(TipoTurno tipo) {
    switch (tipo) {
      case TipoTurno.manana:
        return AppColors.info;
      case TipoTurno.tarde:
        return AppColors.warning;
      case TipoTurno.noche:
        return AppColors.primaryDark;
      case TipoTurno.personalizado:
        return AppColors.secondary;
    }
  }
}
