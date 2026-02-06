import 'dart:async';

import 'package:ambutrack_core/ambutrack_core.dart' hide PersonalEntity;
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/widgets/eliminar_dias_parcial_vacacion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para gestionar vacaciones en cualquier estado
///
/// **Acciones disponibles según estado**:
/// - **Pendiente**: Aprobar, Rechazar, Eliminar
/// - **Aprobada**: Volver a Pendiente, Rechazar, Eliminar
/// - **Rechazada**: Volver a Pendiente, Aprobar, Eliminar
class GestionarVacacionDialog extends StatefulWidget {
  const GestionarVacacionDialog({
    required this.vacacion,
    required this.nombrePersonal,
    super.key,
  });

  final VacacionesEntity vacacion;
  final String nombrePersonal;

  @override
  State<GestionarVacacionDialog> createState() =>
      _GestionarVacacionDialogState();
}

class _GestionarVacacionDialogState extends State<GestionarVacacionDialog> {
  final TextEditingController _observacionesController =
      TextEditingController();
  bool _isProcessing = false;
  late String _estadoActual;

  @override
  void initState() {
    super.initState();
    _observacionesController.text = widget.vacacion.observaciones ?? '';
    _estadoActual = widget.vacacion.estado;
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Gestión de Vacaciones',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Info de la solicitud
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Personal',
                    value: widget.nombrePersonal,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Periodo',
                    value:
                        '${_formatDate(widget.vacacion.fechaInicio)} - ${_formatDate(widget.vacacion.fechaFin)}',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icon: Icons.event_available,
                    label: 'Días solicitados',
                    value: '${widget.vacacion.diasSolicitados} días',
                    color: AppColors.info,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label: 'Estado actual',
                    value: _getEstadoLabel(_estadoActual),
                    color: _getEstadoColor(_estadoActual),
                  ),
                  if (widget.vacacion.fechaSolicitud != null) ...<Widget>[
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildInfoRow(
                      icon: Icons.schedule,
                      label: 'Fecha de solicitud',
                      value: _formatDate(widget.vacacion.fechaSolicitud!),
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                  if (widget.vacacion.fechaAprobacion != null) ...<Widget>[
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildInfoRow(
                      icon: Icons.check_circle_outline,
                      label:
                          widget.vacacion.estado == 'aprobada'
                              ? 'Fecha de aprobación'
                              : 'Fecha de rechazo',
                      value: _formatDate(widget.vacacion.fechaAprobacion!),
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Observaciones actuales
            if (widget.vacacion.observaciones != null &&
                widget.vacacion.observaciones!.isNotEmpty) ...<Widget>[
              Text(
                'Observaciones:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Text(
                  widget.vacacion.observaciones!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacing),
            ],

            // Campo para nuevas observaciones
            Text(
              'Nuevas observaciones (opcional):',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            TextFormField(
              controller: _observacionesController,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Añade comentarios sobre la gestión...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                contentPadding: const EdgeInsets.all(AppSizes.paddingMedium),
              ),
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: _buildActions(context),
    );
  }

  /// Construye los botones de acción según el estado actual
  ///
  /// Layout profesional en múltiples filas de 2 botones
  List<Widget> _buildActions(BuildContext context) {
    final String estado = _estadoActual.toLowerCase();
    final bool puedeEliminarDias = widget.vacacion.diasSolicitados > 1;

    return <Widget>[
      // Columna para layout vertical de botones
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Fila 1: Eliminar + Eliminar días
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildCustomButton(
                    onPressed: _isProcessing ? null : _confirmarEliminar,
                    label: 'Eliminar',
                    icon: Icons.delete_outline,
                    color: AppColors.error.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: _buildCustomButton(
                    onPressed: _isProcessing && puedeEliminarDias
                        ? null
                        : (puedeEliminarDias ? _eliminarDiasParciales : null),
                    label: 'Eliminar días',
                    icon: Icons.content_cut,
                    color: AppColors.warning.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSmall),

            // Fila 2: Rechazar/Pendiente + Aprobar
            Row(
              children: <Widget>[
                if (estado == 'pendiente')
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _rechazar,
                      label: 'Rechazar',
                      icon: Icons.cancel,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  )
                else if (estado == 'aprobada')
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _rechazar,
                      label: 'Rechazar',
                      icon: Icons.cancel,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  )
                else if (estado == 'rechazada')
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _volverPendiente,
                      label: 'Pendiente',
                      icon: Icons.pending_actions,
                      color: AppColors.warning.withValues(alpha: 0.75),
                    ),
                  ),
                const SizedBox(width: AppSizes.spacingSmall),
                if (estado == 'pendiente')
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _aprobar,
                      label: 'Aprobar',
                      icon: Icons.check_circle,
                      color: AppColors.primary.withValues(alpha: 0.85),
                    ),
                  )
                else if (estado == 'aprobada')
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _volverPendiente,
                      label: 'Pendiente',
                      icon: Icons.pending_actions,
                      color: AppColors.warning.withValues(alpha: 0.75),
                    ),
                  )
                else if (estado == 'rechazada')
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _aprobar,
                      label: 'Aprobar',
                      icon: Icons.check_circle,
                      color: AppColors.primary.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSmall),

            // Fila 3: Cerrar
            Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                    label: 'Cerrar',
                    variant: AppButtonVariant.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  /// Construye un botón personalizado con color suave
  Widget _buildCustomButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final bool isDisabled = onPressed == null;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.gray300 : color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.gray500,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSizes.spacingSmall),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = <String>[
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getEstadoLabel(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente de aprobación';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.warning;
      case 'aprobada':
        return AppColors.success;
      case 'rechazada':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  Future<PersonalEntity> _obtenerPersonalAprobador() async {
    final AuthService authService = getIt<AuthService>();
    final String? userId = authService.currentUser?.id;

    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }

    debugPrint('👤 Usuario autenticado: $userId');

    final PersonalRepository personalRepository = getIt<PersonalRepository>();
    final List<PersonalEntity> todosPersonal =
        await personalRepository.getAll();

    final PersonalEntity personalAprobador = todosPersonal.firstWhere(
      (PersonalEntity p) => p.usuarioId == userId,
      orElse: () => throw Exception(
        'No se encontró un registro de Personal asociado al usuario autenticado. '
        'Por favor, contacte al administrador para vincular su usuario con su ficha de personal.',
      ),
    );

    debugPrint(
      '👤 Personal encontrado: ${personalAprobador.nombreCompleto} (${personalAprobador.id})',
    );

    return personalAprobador;
  }

  Future<void> _aprobar() async {
    setState(() => _isProcessing = true);

    debugPrint('✅ Aprobando vacación ${widget.vacacion.id}');

    try {
      final PersonalEntity personalAprobador = await _obtenerPersonalAprobador();

      final VacacionesEntity vacacionAprobada = widget.vacacion.copyWith(
        estado: 'aprobada',
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.vacacion.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesUpdateRequested(vacacionAprobada),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Aprobada',
            message: 'La vacación ha sido aprobada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al aprobar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Aprobar',
            message: 'No se pudo aprobar la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _rechazar() async{
    setState(() => _isProcessing = true);

    debugPrint('❌ Rechazando vacación ${widget.vacacion.id}');

    try {
      final PersonalEntity personalAprobador = await _obtenerPersonalAprobador();

      final VacacionesEntity vacacionRechazada = widget.vacacion.copyWith(
        estado: 'rechazada',
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.vacacion.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesUpdateRequested(vacacionRechazada),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Rechazada',
            message: 'La vacación ha sido rechazada.',
            type: ResultType.warning,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al rechazar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Rechazar',
            message: 'No se pudo rechazar la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _volverPendiente() async {
    setState(() => _isProcessing = true);

    debugPrint('⏳ Volviendo vacación a pendiente ${widget.vacacion.id}');

    try {
      final PersonalEntity personalAprobador = await _obtenerPersonalAprobador();

      final VacacionesEntity vacacionPendiente = widget.vacacion.copyWith(
        estado: 'pendiente',
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.vacacion.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesUpdateRequested(vacacionPendiente),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Actualizada',
            message: 'La vacación ha vuelto a estado pendiente.',
            type: ResultType.info,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al volver vacación a pendiente: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Actualizar',
            message: 'No se pudo cambiar el estado de la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _eliminarDiasParciales() async {
    debugPrint('✂️ Abriendo diálogo de eliminación parcial de vacación');

    final ({DateTime fechaInicio, DateTime fechaFin})? resultado =
        await showEliminarDiasParcialVacacionDialog(
      context: context,
      vacacion: widget.vacacion,
      nombrePersonal: widget.nombrePersonal,
    );

    if (resultado != null && mounted) {
      debugPrint('✂️ Eliminando días: ${resultado.fechaInicio} - ${resultado.fechaFin}');

      context.read<VacacionesBloc>().add(
            VacacionEliminarDiasParcialRequested(
              vacacion: widget.vacacion,
              fechaInicioEliminar: resultado.fechaInicio,
              fechaFinEliminar: resultado.fechaFin,
            ),
          );

      Navigator.of(context).pop();

      unawaited(
        showResultDialog(
          context: context,
          title: 'Días Eliminados',
          message: 'Los días seleccionados han sido eliminados de la vacación.',
          type: ResultType.success,
        ),
      );
    }
  }

  Future<void> _confirmarEliminar() async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta vacación? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': widget.nombrePersonal,
        'Periodo':
            '${_formatDate(widget.vacacion.fechaInicio)} - ${_formatDate(widget.vacacion.fechaFin)}',
        'Días': '${widget.vacacion.diasSolicitados} días',
        'Estado': _getEstadoLabel(widget.vacacion.estado),
      },
    );

    if (confirmed == true && mounted) {
      await _eliminar();
    }
  }

  Future<void> _eliminar() async {
    setState(() => _isProcessing = true);

    debugPrint('🗑️ Eliminando vacación ${widget.vacacion.id}');

    try {
      if (mounted) {
        context.read<VacacionesBloc>().add(
              VacacionesDeleteRequested(widget.vacacion.id),
            );
        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Vacación Eliminada',
            message: 'La vacación ha sido eliminada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al eliminar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Eliminar',
            message: 'No se pudo eliminar la vacación.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }
}
