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
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_bloc.dart';
import 'package:ambutrack_web/features/ausencias/presentation/bloc/ausencias_event.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/eliminar_dias_parcial_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para gestionar ausencias en cualquier estado
///
/// **Acciones disponibles según estado**:
/// - **Pendiente**: Aprobar, Rechazar, Eliminar
/// - **Aprobada**: Volver a Pendiente, Rechazar, Eliminar
/// - **Rechazada**: Volver a Pendiente, Aprobar, Eliminar
class GestionarAusenciaDialog extends StatefulWidget {
  const GestionarAusenciaDialog({
    required this.ausencia,
    required this.nombrePersonal,
    super.key,
  });

  final AusenciaEntity ausencia;
  final String nombrePersonal;

  @override
  State<GestionarAusenciaDialog> createState() =>
      _GestionarAusenciaDialogState();
}

class _GestionarAusenciaDialogState extends State<GestionarAusenciaDialog> {
  final TextEditingController _observacionesController =
      TextEditingController();
  bool _isProcessing = false;
  late EstadoAusencia _estadoActual;

  @override
  void initState() {
    super.initState();
    _observacionesController.text = widget.ausencia.observaciones ?? '';
    _estadoActual = widget.ausencia.estado;
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Gestión de Ausencia',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Info de la ausencia
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
                        '${_formatDate(widget.ausencia.fechaInicio)} - ${_formatDate(widget.ausencia.fechaFin)}',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icon: Icons.event_available,
                    label: 'Días de ausencia',
                    value: '${widget.ausencia.diasAusencia} días',
                    color: AppColors.info,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label: 'Estado actual',
                    value: _getEstadoLabel(_estadoActual),
                    color: _getEstadoColor(_estadoActual),
                  ),
                  if (widget.ausencia.motivo != null &&
                      widget.ausencia.motivo!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildInfoRow(
                      icon: Icons.comment,
                      label: 'Motivo',
                      value: widget.ausencia.motivo!,
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                  if (widget.ausencia.fechaAprobacion != null) ...<Widget>[
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildInfoRow(
                      icon: Icons.check_circle_outline,
                      label:
                          widget.ausencia.estado == EstadoAusencia.aprobada
                              ? 'Fecha de aprobación'
                              : 'Fecha de rechazo',
                      value: _formatDate(widget.ausencia.fechaAprobacion!),
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Observaciones actuales
            if (widget.ausencia.observaciones != null &&
                widget.ausencia.observaciones!.isNotEmpty) ...<Widget>[
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
                  widget.ausencia.observaciones!,
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
    final EstadoAusencia estado = _estadoActual;
    final bool tieneMasDeUnDia = widget.ausencia.diasAusencia > 1;

    return <Widget>[
      // Columna para layout vertical de botones
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Fila 1: Eliminar completo + Eliminar días parciales
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
                    onPressed: _isProcessing && tieneMasDeUnDia
                        ? null
                        : (tieneMasDeUnDia ? _eliminarDiasParciales : null),
                    label: 'Eliminar días',
                    icon: Icons.content_cut,
                    color: AppColors.warning.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingSmall),

            // Fila 2: Rechazar/Pendiente + Aprobar/Pendiente
            Row(
              children: <Widget>[
                if (estado == EstadoAusencia.pendiente)
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _rechazar,
                      label: 'Rechazar',
                      icon: Icons.cancel,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  )
                else if (estado == EstadoAusencia.aprobada)
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _rechazar,
                      label: 'Rechazar',
                      icon: Icons.cancel,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  )
                else if (estado == EstadoAusencia.rechazada)
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _volverPendiente,
                      label: 'Pendiente',
                      icon: Icons.pending_actions,
                      color: AppColors.warning.withValues(alpha: 0.75),
                    ),
                  ),
                const SizedBox(width: AppSizes.spacingSmall),
                if (estado == EstadoAusencia.pendiente)
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _aprobar,
                      label: 'Aprobar',
                      icon: Icons.check_circle,
                      color: AppColors.primary.withValues(alpha: 0.85),
                    ),
                  )
                else if (estado == EstadoAusencia.aprobada)
                  Expanded(
                    child: _buildCustomButton(
                      onPressed: _isProcessing ? null : _volverPendiente,
                      label: 'Pendiente',
                      icon: Icons.pending_actions,
                      color: AppColors.warning.withValues(alpha: 0.75),
                    ),
                  )
                else if (estado == EstadoAusencia.rechazada)
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

            // Fila 3: Cerrar centrado
            Center(
              child: AppButton(
                onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                label: 'Cerrar',
                variant: AppButtonVariant.text,
              ),
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

  String _getEstadoLabel(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return 'Pendiente de aprobación';
      case EstadoAusencia.aprobada:
        return 'Aprobada';
      case EstadoAusencia.rechazada:
        return 'Rechazada';
      case EstadoAusencia.cancelada:
        return 'Cancelada';
    }
  }

  Color _getEstadoColor(EstadoAusencia estado) {
    switch (estado) {
      case EstadoAusencia.pendiente:
        return AppColors.warning;
      case EstadoAusencia.aprobada:
        return AppColors.success;
      case EstadoAusencia.rechazada:
        return AppColors.error;
      case EstadoAusencia.cancelada:
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

    debugPrint('✅ Aprobando ausencia ${widget.ausencia.id}');

    try {
      final PersonalEntity personalAprobador = await _obtenerPersonalAprobador();

      if (mounted) {
        // Disparar evento con actualización optimista
        context.read<AusenciasBloc>().add(
              AusenciaAprobarRequested(
                idAusencia: widget.ausencia.id,
                aprobadoPor: personalAprobador.id,
                observaciones: _observacionesController.text.trim().isEmpty
                    ? null
                    : _observacionesController.text.trim(),
              ),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Aprobada',
            message: 'La ausencia ha sido aprobada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al aprobar ausencia: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Aprobar',
            message: 'No se pudo aprobar la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _rechazar() async {
    setState(() => _isProcessing = true);

    debugPrint('❌ Rechazando ausencia ${widget.ausencia.id}');

    try {
      final PersonalEntity personalAprobador = await _obtenerPersonalAprobador();

      if (mounted) {
        // Disparar evento con actualización optimista
        context.read<AusenciasBloc>().add(
              AusenciaRechazarRequested(
                idAusencia: widget.ausencia.id,
                aprobadoPor: personalAprobador.id,
                observaciones: _observacionesController.text.trim().isEmpty
                    ? null
                    : _observacionesController.text.trim(),
              ),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Rechazada',
            message: 'La ausencia ha sido rechazada.',
            type: ResultType.warning,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al rechazar ausencia: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Rechazar',
            message: 'No se pudo rechazar la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _volverPendiente() async {
    setState(() => _isProcessing = true);

    debugPrint('⏳ Volviendo ausencia a pendiente ${widget.ausencia.id}');

    try {
      final PersonalEntity personalAprobador = await _obtenerPersonalAprobador();

      final AusenciaEntity ausenciaPendiente = widget.ausencia.copyWith(
        estado: EstadoAusencia.pendiente,
        aprobadoPor: personalAprobador.id,
        fechaAprobacion: DateTime.now(),
        observaciones: _observacionesController.text.trim().isEmpty
            ? widget.ausencia.observaciones
            : _observacionesController.text.trim(),
      );

      if (mounted) {
        // Actualización directa en el BLoC (optimista)
        context.read<AusenciasBloc>().add(
              AusenciaUpdateRequested(ausenciaPendiente),
            );

        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Actualizada',
            message: 'La ausencia ha vuelto a estado pendiente.',
            type: ResultType.info,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al volver ausencia a pendiente: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Actualizar',
            message: 'No se pudo cambiar el estado de la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminar() async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Eliminación',
      message:
          '¿Estás seguro de que deseas eliminar esta ausencia? Esta acción no se puede deshacer.',
      itemDetails: <String, String>{
        'Personal': widget.nombrePersonal,
        'Periodo':
            '${_formatDate(widget.ausencia.fechaInicio)} - ${_formatDate(widget.ausencia.fechaFin)}',
        'Días': '${widget.ausencia.diasAusencia} días',
        'Estado': _getEstadoLabel(widget.ausencia.estado),
      },
    );

    if (confirmed == true && mounted) {
      await _eliminar();
    }
  }

  /// Abre el diálogo para eliminar días parciales
  Future<void> _eliminarDiasParciales() async {
    final ({DateTime fechaInicio, DateTime fechaFin})? resultado =
        await showEliminarDiasParcialDialog(
      context: context,
      ausencia: widget.ausencia,
      nombrePersonal: widget.nombrePersonal,
    );

    if (resultado != null && mounted) {
      setState(() => _isProcessing = true);

      debugPrint('✂️ Eliminando días parciales:');
      debugPrint('   Desde: ${resultado.fechaInicio}');
      debugPrint('   Hasta: ${resultado.fechaFin}');

      context.read<AusenciasBloc>().add(
            AusenciaEliminarDiasParcialRequested(
              ausencia: widget.ausencia,
              fechaInicioEliminar: resultado.fechaInicio,
              fechaFinEliminar: resultado.fechaFin,
            ),
          );

      Navigator.of(context).pop();

      unawaited(
        showResultDialog(
          context: context,
          title: 'Días Eliminados',
          message: 'Los días seleccionados han sido eliminados de la ausencia.',
          type: ResultType.success,
        ),
      );
    }
  }

  Future<void> _eliminar() async {
    setState(() => _isProcessing = true);

    debugPrint('🗑️ Eliminando ausencia ${widget.ausencia.id}');

    try {
      if (mounted) {
        context.read<AusenciasBloc>().add(
              AusenciaDeleteRequested(widget.ausencia.id),
            );
        Navigator.of(context).pop();

        unawaited(
          showResultDialog(
            context: context,
            title: 'Ausencia Eliminada',
            message: 'La ausencia ha sido eliminada exitosamente.',
            type: ResultType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al eliminar ausencia: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        unawaited(
          showResultDialog(
            context: context,
            title: 'Error al Eliminar',
            message: 'No se pudo eliminar la ausencia.',
            type: ResultType.error,
            details: e.toString(),
          ),
        );
      }
    }
  }
}
