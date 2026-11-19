import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_detail_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Diálogo para ver detalles de ITV/Revisión (ficha de solo consulta)
class ItvRevisionViewDialog extends StatelessWidget {
  const ItvRevisionViewDialog({required this.itvRevision, super.key});

  final ItvRevisionEntity itvRevision;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');
  static const double _labelWidth = 120;

  @override
  Widget build(BuildContext context) {
    final bool tieneTaller = itvRevision.taller != null || itvRevision.numeroDocumento != null;
    final bool tieneObservaciones =
        itvRevision.observaciones != null && itvRevision.observaciones!.isNotEmpty;

    return GestionFormDialog(
      title: 'Detalle de ITV / Revisión',
      subtitle: itvRevision.tipo.displayName,
      icon: Icons.fact_check_outlined,
      formKey: GlobalKey<FormState>(),
      readOnly: true,
      onSave: () => Navigator.of(context).pop(),
      children: <Widget>[
        const GestionDetailSection(title: 'Información general'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionDetailField(
                  label: 'Tipo',
                  value: itvRevision.tipo.displayName,
                  labelWidth: _labelWidth,
                ),
                GestionDetailField(
                  label: 'Resultado',
                  labelWidth: _labelWidth,
                  child: _ValorColor(
                    texto: itvRevision.resultado.displayName,
                    color: _resultadoColor(itvRevision.resultado),
                  ),
                ),
                GestionDetailField(
                  label: 'Estado',
                  value: itvRevision.estado.displayName,
                  labelWidth: _labelWidth,
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionDetailField(
                  label: 'Fecha',
                  value: _fecha.format(itvRevision.fecha),
                  labelWidth: _labelWidth,
                ),
                if (itvRevision.fechaVencimiento != null)
                  GestionDetailField(
                    label: 'Vencimiento',
                    value: _fecha.format(itvRevision.fechaVencimiento!),
                    labelWidth: _labelWidth,
                  ),
                GestionDetailField(
                  label: 'Kilometraje',
                  value: '${itvRevision.kmVehiculo.toStringAsFixed(0)} km',
                  labelWidth: _labelWidth,
                ),
                GestionDetailField(
                  label: 'Coste total',
                  value: '${itvRevision.costoTotal.toStringAsFixed(2)} €',
                  labelWidth: _labelWidth,
                ),
              ],
            ),
          ],
        ),
        if (tieneTaller) ...<Widget>[
          const GestionDetailSection(title: 'Datos del taller'),
          if (itvRevision.taller != null)
            GestionDetailField(label: 'Taller', value: itvRevision.taller, labelWidth: _labelWidth),
          if (itvRevision.numeroDocumento != null)
            GestionDetailField(
              label: 'Nº documento',
              value: itvRevision.numeroDocumento,
              labelWidth: _labelWidth,
            ),
        ],
        if (tieneObservaciones) ...<Widget>[
          const GestionDetailSection(title: 'Observaciones'),
          GestionDetailField(
            label: 'Observaciones',
            value: itvRevision.observaciones,
            labelWidth: _labelWidth,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Color _resultadoColor(ResultadoItvRevision resultado) {
    switch (resultado) {
      case ResultadoItvRevision.favorable:
        return AppColors.success;
      case ResultadoItvRevision.desfavorable:
        return AppColors.warning;
      case ResultadoItvRevision.negativo:
        return AppColors.error;
      case ResultadoItvRevision.pendiente:
        return AppColors.gray600;
    }
  }
}

/// Valor de la ficha resaltado con color (p.ej. resultado)
class _ValorColor extends StatelessWidget {
  const _ValorColor({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color),
    );
  }
}
