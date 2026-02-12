import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/services/auth_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/personal_repository.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_bloc.dart';
import 'package:ambutrack_web/features/vacaciones/presentation/bloc/vacaciones_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para aprobar o rechazar una solicitud de vacaciones
class AprobarVacacionDialog extends StatefulWidget {
  const AprobarVacacionDialog({
    required this.vacacion,
    required this.nombrePersonal,
    super.key,
  });

  final VacacionesEntity vacacion;
  final String nombrePersonal;

  @override
  State<AprobarVacacionDialog> createState() => _AprobarVacacionDialogState();
}

class _AprobarVacacionDialogState extends State<AprobarVacacionDialog> {
  final TextEditingController _observacionesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _observacionesController.text = widget.vacacion.observaciones ?? '';
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Gestión de Solicitud de Vacaciones',
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
                  if (widget.vacacion.fechaSolicitud != null) ...<Widget>[
                    const SizedBox(height: AppSizes.spacingSmall),
                    _buildInfoRow(
                      icon: Icons.schedule,
                      label: 'Fecha de solicitud',
                      value: _formatDate(widget.vacacion.fechaSolicitud!),
                      color: AppColors.textSecondaryLight,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing),

            // Observaciones
            if (widget.vacacion.observaciones != null &&
                widget.vacacion.observaciones!.isNotEmpty) ...<Widget>[
              Text(
                'Observaciones del solicitante:',
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

            // Campo para observaciones del aprobador
            Text(
              'Observaciones (opcional):',
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
              decoration: InputDecoration(
                hintText: 'Añade comentarios sobre la aprobación/rechazo...',
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
      actions: <Widget>[
        // Botón Cancelar
        AppButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          label: 'Cancelar',
          variant: AppButtonVariant.text,
        ),

        // Botón Rechazar
        AppButton(
          onPressed: _isProcessing ? null : _rechazar,
          label: 'Rechazar',
          icon: Icons.cancel,
          variant: AppButtonVariant.danger,
        ),

        // Botón Aprobar
        AppButton(
          onPressed: _isProcessing ? null : _aprobar,
          label: 'Aprobar',
          icon: Icons.check_circle,
        ),
      ],
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

  Future<void> _aprobar() async {
    setState(() => _isProcessing = true);

    debugPrint('✅ Aprobando vacación ${widget.vacacion.id}');

    try {
      // 1. Obtener el UUID del usuario autenticado de Supabase Auth
      final AuthService authService = getIt<AuthService>();
      final String? userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('No hay usuario autenticado');
      }

      debugPrint('👤 Usuario autenticado: $userId');

      // 2. Buscar el PersonalEntity que tenga ese usuarioId
      final PersonalRepository personalRepository = getIt<PersonalRepository>();
      final List<PersonalEntity> todosPersonal = await personalRepository.getAll();

      final PersonalEntity personalAprobador = todosPersonal.firstWhere(
        (PersonalEntity p) => p.usuarioId == userId,
        orElse: () => throw Exception(
          'No se encontró un registro de Personal asociado al usuario autenticado. '
          'Por favor, contacte al administrador para vincular su usuario con su ficha de personal.',
        ),
      );

      debugPrint('👤 Personal encontrado: ${personalAprobador.nombreCompleto} (${personalAprobador.id})');

      // 3. Usar el ID de Personal para aprobar
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
      }
    } catch (e) {
      debugPrint('❌ Error al aprobar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _rechazar() async {
    setState(() => _isProcessing = true);

    debugPrint('❌ Rechazando vacación ${widget.vacacion.id}');

    try {
      // 1. Obtener el UUID del usuario autenticado de Supabase Auth
      final AuthService authService = getIt<AuthService>();
      final String? userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('No hay usuario autenticado');
      }

      debugPrint('👤 Usuario autenticado: $userId');

      // 2. Buscar el PersonalEntity que tenga ese usuarioId
      final PersonalRepository personalRepository = getIt<PersonalRepository>();
      final List<PersonalEntity> todosPersonal = await personalRepository.getAll();

      final PersonalEntity personalAprobador = todosPersonal.firstWhere(
        (PersonalEntity p) => p.usuarioId == userId,
        orElse: () => throw Exception(
          'No se encontró un registro de Personal asociado al usuario autenticado. '
          'Por favor, contacte al administrador para vincular su usuario con su ficha de personal.',
        ),
      );

      debugPrint('👤 Personal encontrado: ${personalAprobador.nombreCompleto} (${personalAprobador.id})');

      // 3. Usar el ID de Personal para rechazar
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
      }
    } catch (e) {
      debugPrint('❌ Error al rechazar vacación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
