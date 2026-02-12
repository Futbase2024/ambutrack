import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/services/user_name_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Diálogo para visualizar detalles completos de un mantenimiento
class MantenimientoViewDialog extends StatefulWidget {
  const MantenimientoViewDialog({
    required this.mantenimiento,
    super.key,
  });

  final MantenimientoEntity mantenimiento;

  @override
  State<MantenimientoViewDialog> createState() => _MantenimientoViewDialogState();
}

class _MantenimientoViewDialogState extends State<MantenimientoViewDialog> {
  final UserNameService _userNameService = UserNameService.instance;
  String? _createdByName;
  String? _updatedByName;
  bool _isLoadingNames = true;

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    if (widget.mantenimiento.createdBy != null) {
      _createdByName = await _userNameService.getUserName(widget.mantenimiento.createdBy!);
    }
    if (widget.mantenimiento.updatedBy != null) {
      _updatedByName = await _userNameService.getUserName(widget.mantenimiento.updatedBy!);
    }
    if (mounted) {
      setState(() {
        _isLoadingNames = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 900 ? 800 : screenWidth * 0.9;

    return AppDialog(
      title: 'Detalles del Mantenimiento\n${widget.mantenimiento.tipoMantenimiento.displayName}',
      icon: Icons.build_circle,
      maxWidth: dialogWidth,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Badge de estado al inicio
          _buildEstadoBadge(),
          const SizedBox(height: AppSizes.spacingLarge),

          // Contenido
          _buildContent(),
        ],
      ),
      actions: <Widget>[
        AppButton(
          label: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }

  Widget _buildEstadoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: _getEstadoColor(widget.mantenimiento.estado).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getEstadoColor(widget.mantenimiento.estado)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            _getEstadoIcon(widget.mantenimiento.estado),
            size: 16,
            color: _getEstadoColor(widget.mantenimiento.estado),
          ),
          const SizedBox(width: 6),
          Text(
            widget.mantenimiento.estado.displayName,
            style: GoogleFonts.inter(
              color: _getEstadoColor(widget.mantenimiento.estado),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Información General
        _buildSection(
          title: 'Información General',
          icon: Icons.info_outline,
          children: <Widget>[
            _buildInfoRow('Vehículo ID', widget.mantenimiento.vehiculoId.substring(0, 12)),
            _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(widget.mantenimiento.fecha)),
            _buildInfoRow('Kilometraje', '${NumberFormat('#,###').format(widget.mantenimiento.kmVehiculo)} km'),
            _buildInfoRow('Descripción', widget.mantenimiento.descripcion),
          ],
        ),
        const SizedBox(height: AppSizes.spacingLarge),

        // Detalles del Servicio
        _buildSection(
          title: 'Detalles del Servicio',
          icon: Icons.build,
          children: <Widget>[
            if (widget.mantenimiento.trabajosRealizados != null)
              _buildInfoRow('Trabajos Realizados', widget.mantenimiento.trabajosRealizados!),
            if (widget.mantenimiento.taller != null) _buildInfoRow('Taller', widget.mantenimiento.taller!),
            if (widget.mantenimiento.mecanicoResponsable != null)
              _buildInfoRow('Mecánico Responsable', widget.mantenimiento.mecanicoResponsable!),
            if (widget.mantenimiento.numeroOrden != null)
              _buildInfoRow('Número de Orden', widget.mantenimiento.numeroOrden!),
          ],
        ),
        const SizedBox(height: AppSizes.spacingLarge),

        // Fechas y Programación
        _buildSection(
          title: 'Fechas y Programación',
          icon: Icons.calendar_today,
          children: <Widget>[
            if (widget.mantenimiento.fechaProgramada != null)
              _buildInfoRow(
                'Fecha Programada',
                DateFormat('dd/MM/yyyy').format(widget.mantenimiento.fechaProgramada!),
              ),
            if (widget.mantenimiento.fechaInicio != null)
              _buildInfoRow(
                'Fecha Inicio',
                DateFormat('dd/MM/yyyy HH:mm').format(widget.mantenimiento.fechaInicio!),
              ),
            if (widget.mantenimiento.fechaFin != null)
              _buildInfoRow(
                'Fecha Fin',
                DateFormat('dd/MM/yyyy HH:mm').format(widget.mantenimiento.fechaFin!),
              ),
            if (widget.mantenimiento.tiempoInoperativoHoras != null)
              _buildInfoRow(
                'Tiempo Inoperativo',
                '${widget.mantenimiento.tiempoInoperativoHoras!.toStringAsFixed(1)} horas',
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingLarge),

        // Costos
        _buildSection(
          title: 'Costos',
          icon: Icons.euro,
          color: AppColors.warning,
          children: <Widget>[
            if (widget.mantenimiento.costoManoObra != null)
              _buildInfoRow(
                'Mano de Obra',
                '${widget.mantenimiento.costoManoObra!.toStringAsFixed(2)} €',
              ),
            if (widget.mantenimiento.costoRepuestos != null)
              _buildInfoRow(
                'Repuestos',
                '${widget.mantenimiento.costoRepuestos!.toStringAsFixed(2)} €',
              ),
            _buildInfoRow(
              'Total',
              '${widget.mantenimiento.costoTotal.toStringAsFixed(2)} €',
              isBold: true,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingLarge),

        // Próximo Mantenimiento
        if (widget.mantenimiento.proximoKmSugerido != null || widget.mantenimiento.proximaFechaSugerida != null)
          _buildSection(
            title: 'Próximo Mantenimiento Sugerido',
            icon: Icons.event_available,
            color: AppColors.success,
            children: <Widget>[
              if (widget.mantenimiento.proximoKmSugerido != null)
                _buildInfoRow(
                  'Kilómetros',
                  '${NumberFormat('#,###').format(widget.mantenimiento.proximoKmSugerido!)} km',
                ),
              if (widget.mantenimiento.proximaFechaSugerida != null)
                _buildInfoRow(
                  'Fecha',
                  DateFormat('dd/MM/yyyy').format(widget.mantenimiento.proximaFechaSugerida!),
                ),
            ],
          ),

        // Metadatos
        const SizedBox(height: AppSizes.spacingLarge),
        _buildSection(
          title: 'Información del Sistema',
          icon: Icons.settings,
          children: <Widget>[
            _buildInfoRow(
              'Fecha',
              DateFormat('dd/MM/yyyy HH:mm').format(widget.mantenimiento.createdAt),
            ),
            _buildInfoRow(
              'Creado por',
              _isLoadingNames
                  ? 'Cargando...'
                  : (_createdByName ?? 'Desconocido'),
            ),
            if (widget.mantenimiento.updatedAt != null) ...<Widget>[
              const SizedBox(height: AppSizes.paddingSmall),
              _buildInfoRow(
                'Última modificación',
                _isLoadingNames
                    ? 'Cargando...'
                    : _formatUpdateInfo(
                        widget.mantenimiento.updatedAt!,
                        _updatedByName,
                      ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    final Color sectionColor = color ?? AppColors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: sectionColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                topRight: Radius.circular(AppSizes.radiusMedium),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 20, color: sectionColor),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w600,
                    color: sectionColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontSmall,
                color: AppColors.textPrimaryLight,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Color _getEstadoColor(EstadoMantenimiento estado) {
    switch (estado) {
      case EstadoMantenimiento.programado:
        return AppColors.info;
      case EstadoMantenimiento.enProceso:
        return AppColors.warning;
      case EstadoMantenimiento.completado:
        return AppColors.success;
      case EstadoMantenimiento.cancelado:
        return AppColors.error;
    }
  }

  IconData _getEstadoIcon(EstadoMantenimiento estado) {
    switch (estado) {
      case EstadoMantenimiento.programado:
        return Icons.schedule;
      case EstadoMantenimiento.enProceso:
        return Icons.build;
      case EstadoMantenimiento.completado:
        return Icons.check_circle;
      case EstadoMantenimiento.cancelado:
        return Icons.cancel;
    }
  }

  /// Formatea la información de modificación con fecha y usuario
  String _formatUpdateInfo(DateTime updatedAt, String? userName) {
    final String dateStr = DateFormat('dd/MM/yyyy HH:mm').format(updatedAt);
    if (userName != null && userName.isNotEmpty) {
      return '$dateStr por $userName';
    }
    return dateStr;
  }
}
