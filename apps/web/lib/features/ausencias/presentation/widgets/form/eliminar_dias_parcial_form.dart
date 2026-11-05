import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/eliminar_dias_parcial_preview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Diálogo común (ausencias y vacaciones) para seleccionar un rango de días
/// a eliminar de una solicitud. Devuelve la selección mediante [onConfirmar].
class EliminarDiasParcialSolicitudDialog extends StatefulWidget {
  const EliminarDiasParcialSolicitudDialog({
    required this.entidad,
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasTotales,
    required this.nombrePersonal,
    required this.onConfirmar,
    super.key,
  });

  /// Nombre de la solicitud en minúsculas ("ausencia", "vacación")
  final String entidad;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int diasTotales;
  final String nombrePersonal;
  final void Function(DateTime fechaInicioEliminar, DateTime fechaFinEliminar) onConfirmar;

  @override
  State<EliminarDiasParcialSolicitudDialog> createState() => _EliminarDiasParcialSolicitudDialogState();
}

class _EliminarDiasParcialSolicitudDialogState extends State<EliminarDiasParcialSolicitudDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  late DateTime _fechaInicioEliminar;
  late DateTime _fechaFinEliminar;

  @override
  void initState() {
    super.initState();
    // Por defecto, seleccionar todo el rango
    _fechaInicioEliminar = widget.fechaInicio;
    _fechaFinEliminar = widget.fechaFin;
  }

  int get _diasAEliminar {
    return _fechaFinEliminar.difference(_fechaInicioEliminar).inDays + 1;
  }

  int get _diasRestantes {
    return widget.diasTotales - _diasAEliminar;
  }

  /// Calcula los periodos que quedarán después de eliminar
  List<PeriodoRestante> get _periodosRestantes {
    final DateTime inicioOrig = widget.fechaInicio;
    final DateTime finOrig = widget.fechaFin;

    final List<PeriodoRestante> periodos = <PeriodoRestante>[];

    // Verificar si queda periodo antes
    if (_fechaInicioEliminar.isAfter(inicioOrig)) {
      final DateTime finAntes = _fechaInicioEliminar.subtract(const Duration(days: 1));
      final int dias = finAntes.difference(inicioOrig).inDays + 1;
      periodos.add(PeriodoRestante(fechaInicio: inicioOrig, fechaFin: finAntes, dias: dias));
    }

    // Verificar si queda periodo después
    if (_fechaFinEliminar.isBefore(finOrig)) {
      final DateTime inicioDespues = _fechaFinEliminar.add(const Duration(days: 1));
      final int dias = finOrig.difference(inicioDespues).inDays + 1;
      periodos.add(PeriodoRestante(fechaInicio: inicioDespues, fechaFin: finOrig, dias: dias));
    }

    return periodos;
  }

  void _onInicioChanged(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() {
      _fechaInicioEliminar = picked;
      // Si la fecha fin es anterior, ajustarla
      if (_fechaFinEliminar.isBefore(picked)) {
        _fechaFinEliminar = picked;
      }
    });
  }

  void _onFinChanged(DateTime? picked) {
    if (picked == null) {
      return;
    }
    setState(() {
      _fechaFinEliminar = picked;
      // Si la fecha inicio es posterior, ajustarla
      if (_fechaInicioEliminar.isAfter(picked)) {
        _fechaInicioEliminar = picked;
      }
    });
  }

  void _confirmarEliminacion() {
    widget.onConfirmar(_fechaInicioEliminar, _fechaFinEliminar);
  }

  @override
  Widget build(BuildContext context) {
    final String entidadTitulo = '${widget.entidad[0].toUpperCase()}${widget.entidad.substring(1)}';

    return GestionFormDialog(
      title: 'Eliminar días parciales',
      subtitle: widget.nombrePersonal,
      icon: Icons.content_cut,
      formKey: _formKey,
      size: GestionFormSize.small,
      destructive: true,
      saveLabel: 'Eliminar $_diasAEliminar días',
      onSave: () {
        if (_diasAEliminar > 0) {
          _confirmarEliminacion();
        }
      },
      children: <Widget>[
        GestionFormSection(title: '$entidadTitulo original', first: true),
        GestionFormRow(label: 'Personal', child: GestionFormReadOnly(value: widget.nombrePersonal)),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Periodo',
              child: GestionFormReadOnly(
                value: '${_fmt.format(widget.fechaInicio)} - ${_fmt.format(widget.fechaFin)}',
              ),
            ),
            GestionFormRow(
              label: 'Días totales',
              labelWidth: 96,
              child: GestionFormReadOnly(value: '${widget.diasTotales} días'),
            ),
          ],
        ),
        const GestionFormSection(title: 'Días a eliminar'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Desde',
              required: true,
              child: GestionDateField(
                // La clave fuerza el refresco al ajustarse desde el otro extremo
                key: ValueKey<DateTime>(_fechaInicioEliminar),
                value: _fechaInicioEliminar,
                required: true,
                firstDate: widget.fechaInicio,
                lastDate: widget.fechaFin,
                onChanged: _onInicioChanged,
              ),
            ),
            GestionFormRow(
              label: 'Hasta',
              required: true,
              labelWidth: 96,
              child: GestionDateField(
                key: ValueKey<DateTime>(_fechaFinEliminar),
                value: _fechaFinEliminar,
                required: true,
                firstDate: widget.fechaInicio,
                lastDate: widget.fechaFin,
                onChanged: _onFinChanged,
              ),
            ),
          ],
        ),
        EliminarDiasAviso(
          icon: Icons.delete_outline,
          color: AppColors.error,
          texto: 'Se eliminarán $_diasAEliminar días',
        ),
        const GestionFormSection(title: 'Resultado'),
        EliminarDiasPreview(
          entidad: widget.entidad,
          periodos: _periodosRestantes,
          diasRestantes: _diasRestantes,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
