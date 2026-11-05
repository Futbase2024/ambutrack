import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/services/user_name_service.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_detail_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Diálogo para visualizar detalles completos de un mantenimiento (solo consulta)
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
  static const double _labelWidth = 150;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserNameService _userNameService = UserNameService.instance;
  final DateFormat _fecha = DateFormat('dd/MM/yyyy');
  final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _km = NumberFormat('#,###');
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

  String _euros(double v) => '${v.toStringAsFixed(2)} €';

  @override
  Widget build(BuildContext context) {
    final MantenimientoEntity m = widget.mantenimiento;
    final bool tieneProximo = m.proximoKmSugerido != null || m.proximaFechaSugerida != null;

    return GestionFormDialog(
      title: 'Detalle del mantenimiento',
      subtitle: m.tipoMantenimiento.displayName,
      icon: Icons.build_circle_outlined,
      formKey: _formKey,
      readOnly: true,
      onSave: () => Navigator.of(context).pop(),
      children: <Widget>[
        const GestionDetailSection(title: 'Información general'),
        GestionDetailField(
          label: 'Estado',
          labelWidth: _labelWidth,
          child: _EstadoValor(estado: m.estado),
        ),
        _Campo('Vehículo ID', m.vehiculoId.substring(0, 12)),
        _Campo('Fecha', _fechaHora.format(m.fecha)),
        _Campo('Kilometraje', '${_km.format(m.kmVehiculo)} km'),
        _Campo('Descripción', m.descripcion),
        const GestionDetailSection(title: 'Detalles del servicio'),
        if (m.trabajosRealizados != null) _Campo('Trabajos realizados', m.trabajosRealizados),
        if (m.taller != null) _Campo('Taller', m.taller),
        if (m.mecanicoResponsable != null) _Campo('Mecánico responsable', m.mecanicoResponsable),
        if (m.numeroOrden != null) _Campo('Número de orden', m.numeroOrden),
        const GestionDetailSection(title: 'Fechas y programación'),
        if (m.fechaProgramada != null) _Campo('Fecha programada', _fecha.format(m.fechaProgramada!)),
        if (m.fechaInicio != null) _Campo('Fecha inicio', _fechaHora.format(m.fechaInicio!)),
        if (m.fechaFin != null) _Campo('Fecha fin', _fechaHora.format(m.fechaFin!)),
        if (m.tiempoInoperativoHoras != null)
          _Campo('Tiempo inoperativo', '${m.tiempoInoperativoHoras!.toStringAsFixed(1)} horas'),
        const GestionDetailSection(title: 'Costes'),
        if (m.costoManoObra != null) _Campo('Mano de obra', _euros(m.costoManoObra!)),
        if (m.costoRepuestos != null) _Campo('Repuestos', _euros(m.costoRepuestos!)),
        GestionDetailField(
          label: 'Total',
          labelWidth: _labelWidth,
          child: Text(
            _euros(m.costoTotal),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.gray900),
          ),
        ),
        if (tieneProximo) ...<Widget>[
          const GestionDetailSection(title: 'Próximo mantenimiento sugerido'),
          if (m.proximoKmSugerido != null) _Campo('Kilómetros', '${_km.format(m.proximoKmSugerido!)} km'),
          if (m.proximaFechaSugerida != null) _Campo('Fecha', _fecha.format(m.proximaFechaSugerida!)),
        ],
        const GestionDetailSection(title: 'Información del sistema'),
        _Campo('Fecha', _fechaHora.format(m.createdAt)),
        _Campo('Creado por', _isLoadingNames ? 'Cargando...' : (_createdByName ?? 'Desconocido')),
        if (m.updatedAt != null)
          _Campo(
            'Última modificación',
            _isLoadingNames ? 'Cargando...' : _formatUpdateInfo(m.updatedAt!, _updatedByName),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Formatea la información de modificación con fecha y usuario
  String _formatUpdateInfo(DateTime updatedAt, String? userName) {
    final String dateStr = _fechaHora.format(updatedAt);
    if (userName != null && userName.isNotEmpty) {
      return '$dateStr por $userName';
    }
    return dateStr;
  }
}

/// Fila "Etiqueta   Valor" con el ancho de etiqueta de esta ficha
class _Campo extends StatelessWidget {
  const _Campo(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return GestionDetailField(
      label: label,
      value: value,
      labelWidth: _MantenimientoViewDialogState._labelWidth,
    );
  }
}

/// Estado del mantenimiento con icono y color
class _EstadoValor extends StatelessWidget {
  const _EstadoValor({required this.estado});

  final EstadoMantenimiento estado;

  Color get _color {
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

  IconData get _icon {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(_icon, size: 14, color: _color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            estado.displayName,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _color),
          ),
        ),
      ],
    );
  }
}
