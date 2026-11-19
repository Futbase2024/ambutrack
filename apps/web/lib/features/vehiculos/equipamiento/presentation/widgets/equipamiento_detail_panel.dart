import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_columns.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_estado.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Acciones disponibles sobre la línea seleccionada (null = no disponible)
class EquipamientoAcciones {
  const EquipamientoAcciones({
    this.onRegistrar,
    this.onAdjuntar,
    this.onVerAdjunto,
    this.onQuitarAdjunto,
    this.onExcluir,
    this.onEliminarExtra,
  });

  final VoidCallback? onRegistrar;
  final VoidCallback? onAdjuntar;
  final VoidCallback? onVerAdjunto;
  final VoidCallback? onQuitarAdjunto;

  /// Excluir / volver a incluir (solo admin / jefe y líneas de plantilla)
  final VoidCallback? onExcluir;

  /// Eliminar (solo admin / jefe y líneas extra)
  final VoidCallback? onEliminarExtra;
}

/// Ficha lateral de la línea de equipamiento seleccionada
class EquipamientoDetailPanel extends StatelessWidget {
  const EquipamientoDetailPanel({required this.linea, required this.acciones, super.key});

  final StockVehiculoEntity? linea;
  final EquipamientoAcciones acciones;

  @override
  Widget build(BuildContext context) {
    final StockVehiculoEntity? l = linea;
    if (l == null) {
      return const GestionDetailEmpty(message: 'Selecciona un item para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(l.id),
      title: GestionFormatters.texto(l.productoNombre),
      badges: <Widget>[EquipamientoEstadoDot(linea: l), EquipamientoOrigenBadge(linea: l)],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _GeneralTab(linea: l, acciones: acciones)),
      ],
      actions: <Widget>[
        if (acciones.onRegistrar != null)
          FlotaPanelButton(icon: Icons.edit_note, label: 'Registrar', onPressed: acciones.onRegistrar),
        if (acciones.onAdjuntar != null)
          FlotaPanelButton(
            icon: Icons.upload_file,
            label: l.tieneAdjunto ? 'Sustituir doc.' : 'Adjuntar',
            onPressed: acciones.onAdjuntar,
          ),
        if (acciones.onExcluir != null)
          FlotaPanelButton(
            icon: l.excluido ? Icons.undo : Icons.block,
            label: l.excluido ? 'Incluir' : 'Excluir',
            color: l.excluido ? AppColors.primary : AppColors.warning,
            onPressed: acciones.onExcluir,
          ),
        if (acciones.onEliminarExtra != null) FlotaPanelButton.delete(onPressed: acciones.onEliminarExtra),
      ],
    );
  }
}

class _GeneralTab extends StatelessWidget {
  const _GeneralTab({required this.linea, required this.acciones});

  final StockVehiculoEntity linea;
  final EquipamientoAcciones acciones;

  @override
  Widget build(BuildContext context) {
    final StockVehiculoEntity l = linea;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Item'),
        GestionDetailField(label: 'Sección', value: equipamientoSeccion(l)),
        GestionDetailField(label: 'Tipo', value: l.esDocumento ? 'Documento' : 'Material'),
        GestionDetailField(label: 'Plantilla', value: l.plantillaNombre),
        GestionDetailField(
          label: 'Requisito',
          value: l.esDePlantilla ? (l.obligatorio ? 'Obligatorio' : 'Opcional') : 'Extra del vehículo',
        ),
        const GestionDetailSection(title: 'Dotación'),
        GestionDetailField(label: 'Requerida', value: l.cantidadMinima?.toString()),
        GestionDetailField(label: 'Actual', value: '${l.cantidadActual}'),
        GestionDetailField(label: 'Estado', child: EquipamientoEstadoDot(linea: l)),
        GestionDetailField(
          label: 'Caducidad',
          value: l.fechaCaducidad != null
              ? GestionFormatters.fecha(l.fechaCaducidad)
              : (l.requiereCaducidad ? 'Pendiente de registrar' : null),
        ),
        GestionDetailField(label: 'Lote', value: l.lote),
        const GestionDetailSection(title: 'Documento adjunto'),
        _AdjuntoField(linea: l, onVer: acciones.onVerAdjunto, onQuitar: acciones.onQuitarAdjunto),
        const GestionDetailSection(title: 'Observaciones'),
        FlotaNotes(l.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Actualizado', value: GestionFormatters.fecha(l.updatedAt)),
      ],
    );
  }
}

/// Nombre del adjunto (o aviso si falta) con acciones Ver / Quitar
class _AdjuntoField extends StatelessWidget {
  const _AdjuntoField({required this.linea, required this.onVer, required this.onQuitar});

  final StockVehiculoEntity linea;
  final VoidCallback? onVer;
  final VoidCallback? onQuitar;

  @override
  Widget build(BuildContext context) {
    if (!linea.tieneAdjunto) {
      return GestionDetailField(
        label: 'Archivo',
        value: linea.requiereAdjunto ? 'Falta adjuntar documento' : 'Sin documento',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestionDetailField(label: 'Archivo', value: linea.documentoNombre ?? 'Documento'),
        Row(
          children: <Widget>[
            if (onVer != null)
              TextButton.icon(
                onPressed: onVer,
                icon: const Icon(Icons.open_in_new, size: 15),
                label: const Text('Ver'),
              ),
            if (onQuitar != null)
              TextButton.icon(
                onPressed: onQuitar,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                icon: const Icon(Icons.link_off, size: 15),
                label: const Text('Quitar'),
              ),
          ],
        ),
      ],
    );
  }
}
