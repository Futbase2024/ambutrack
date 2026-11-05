import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/contratos/presentation/widgets/gestion/contratos_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del contrato seleccionado
class ContratosDetailPanel extends StatelessWidget {
  const ContratosDetailPanel({
    required this.contrato,
    required this.hospitales,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ContratoEntity? contrato;
  final Map<String, String> hospitales;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ContratoEntity? c = contrato;
    if (c == null) {
      return const GestionDetailEmpty(message: 'Selecciona un contrato para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(c.id),
      title: c.codigo,
      badges: <Widget>[
        if (c.tipoContrato?.trim().isNotEmpty ?? false) ContratoTipoDot(tipo: c.tipoContrato),
        ContratoVigenciaDot(contrato: c),
        ContratoEstadoDot(activo: c.activo),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _ContratoGeneralTab(contrato: c, hospital: hospitales[c.hospitalId]),
        ),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ContratoGeneralTab extends StatelessWidget {
  const _ContratoGeneralTab({required this.contrato, required this.hospital});

  final ContratoEntity contrato;
  final String? hospital;

  @override
  Widget build(BuildContext context) {
    final ContratoEntity c = contrato;
    final Map<String, dynamic> condiciones = c.condicionesEspeciales ?? const <String, dynamic>{};
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Código', value: c.codigo),
        GestionDetailField(label: 'Centro', value: hospital),
        GestionDetailField(label: 'Tipo', child: ContratoTipoDot(tipo: c.tipoContrato)),
        GestionDetailField(label: 'Estado', child: ContratoEstadoDot(activo: c.activo)),
        const GestionDetailSection(title: 'Vigencia'),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(c.fechaInicio)),
        GestionDetailField(
          label: 'Fin',
          value: c.fechaFin == null ? 'Indefinido' : GestionFormatters.fecha(c.fechaFin),
        ),
        GestionDetailField(label: 'Situación', child: ContratoVigenciaDot(contrato: c)),
        const GestionDetailSection(title: 'Económico'),
        GestionDetailField(label: 'Importe mensual', value: contratoImporte(c)),
        const GestionDetailSection(title: 'Descripción'),
        _DetailText(text: c.descripcion),
        if (condiciones.isNotEmpty) ...<Widget>[
          const GestionDetailSection(title: 'Condiciones especiales'),
          for (final MapEntry<String, dynamic> e in condiciones.entries)
            GestionDetailField(label: e.key, value: '${e.value}'),
        ],
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(c.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(c.updatedAt)),
      ],
    );
  }
}

class _DetailText extends StatelessWidget {
  const _DetailText({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final bool hasText = text?.trim().isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(text),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: hasText ? AppColors.gray800 : AppColors.gray300,
        ),
      ),
    );
  }
}
