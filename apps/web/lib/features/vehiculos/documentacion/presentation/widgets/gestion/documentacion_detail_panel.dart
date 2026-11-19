import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/documentacion/presentation/widgets/gestion/documentacion_gestion_columns.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del documento seleccionado
class DocumentacionDetailPanel extends StatelessWidget {
  const DocumentacionDetailPanel({
    required this.documento,
    required this.todos,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DocumentacionVehiculoEntity? documento;

  /// Todos los documentos (para la pestaña del vehículo)
  final List<DocumentacionVehiculoEntity> todos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final DocumentacionVehiculoEntity? d = documento;
    if (d == null) {
      return const GestionDetailEmpty(message: 'Selecciona un documento para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(d.id),
      title: '${docTipoLabel(d)} · ${GestionFormatters.texto(d.vehiculoMatricula)}',
      badges: <Widget>[DocEstadoDot(estado: d.estado)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _DocGeneralTab(documento: d)),
        GestionDetailTab(label: 'Vehículo', child: _DocVehiculoTab(documento: d, todos: todos)),
      ],
      actions: <Widget>[
        FlotaPanelButton.edit(onPressed: onEdit),
        FlotaPanelButton.delete(onPressed: onDelete),
      ],
    );
  }
}

class _DocGeneralTab extends StatelessWidget {
  const _DocGeneralTab({required this.documento});

  final DocumentacionVehiculoEntity documento;

  @override
  Widget build(BuildContext context) {
    final DocumentacionVehiculoEntity d = documento;
    final int dias = docDiasRestantes(d);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Documento'),
        GestionDetailField(label: 'Tipo', value: docTipoLabel(d)),
        GestionDetailField(label: 'Código tipo', value: d.tipoDocumentoCodigo),
        GestionDetailField(label: 'Categoría', value: d.tipoDocumentoCategoria),
        GestionDetailField(label: 'Nº póliza', value: d.numeroPoliza),
        GestionDetailField(label: 'Compañía', value: d.compania),
        GestionDetailField(label: 'Coste anual', value: _opt(flotaMoneda(d.costeAnual))),
        const GestionDetailSection(title: 'Vigencia'),
        GestionDetailField(label: 'Estado', child: DocEstadoDot(estado: d.estado)),
        GestionDetailField(label: 'Emisión', value: GestionFormatters.fecha(d.fechaEmision)),
        GestionDetailField(label: 'Vencimiento', child: VehiculoFechaVencimiento(fecha: d.fechaVencimiento)),
        GestionDetailField(label: 'Días restantes', value: dias < 0 ? 'Vencido' : '$dias'),
        GestionDetailField(
          label: 'Próx. vencim.',
          value: d.fechaProximoVencimiento == null
              ? null
              : GestionFormatters.fecha(d.fechaProximoVencimiento),
        ),
        GestionDetailField(label: 'Días de alerta', value: '${d.diasAlerta}'),
        GestionDetailField(label: 'Renovación auto.', value: flotaSiNo(value: d.requiereRenovacion)),
        const GestionDetailSection(title: 'Archivos'),
        GestionDetailField(label: 'Documento 1', value: _adjunto(d.documentoUrl)),
        GestionDetailField(label: 'Documento 2', value: _adjunto(d.documentoUrl2)),
        const GestionDetailSection(title: 'Observaciones'),
        FlotaNotes(d.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: _fecha(d.createdAt)),
        GestionDetailField(label: 'Modificado', value: _fecha(d.updatedAt)),
      ],
    );
  }

  static String? _opt(String s) => s == GestionFormatters.vacio ? null : s;

  static String? _fecha(DateTime? f) => f == null ? null : GestionFormatters.fecha(f);

  static String? _adjunto(String? url) =>
      url == null || url.trim().isEmpty ? null : 'Adjunto (ver detalle)';
}

class _DocVehiculoTab extends StatelessWidget {
  const _DocVehiculoTab({required this.documento, required this.todos});

  final DocumentacionVehiculoEntity documento;
  final List<DocumentacionVehiculoEntity> todos;

  @override
  Widget build(BuildContext context) {
    final DocumentacionVehiculoEntity d = documento;
    final List<DocumentacionVehiculoEntity> docs = todos
        .where((DocumentacionVehiculoEntity x) => x.vehiculoId == d.vehiculoId)
        .toList()
      ..sort((DocumentacionVehiculoEntity a, DocumentacionVehiculoEntity b) =>
          a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Vehículo'),
        GestionDetailField(label: 'Matrícula', value: d.vehiculoMatricula),
        GestionDetailField(label: 'Marca', value: d.vehiculoMarca),
        GestionDetailField(label: 'Modelo', value: d.vehiculoModelo),
        GestionDetailSection(title: 'Documentos del vehículo (${docs.length})'),
        ...docs.map(
          (DocumentacionVehiculoEntity x) => FlotaMiniRow(
            leading: docTipoLabel(x),
            leadingWidth: 120,
            middle: GestionDotLabel(
              label: x.id == d.id ? '${docEstadoLabel(x.estado)} (actual)' : docEstadoLabel(x.estado),
              color: docEstadoColor(x.estado),
              fontSize: 11.5,
            ),
            trailing: GestionFormatters.fecha(x.fechaVencimiento),
          ),
        ),
      ],
    );
  }
}
