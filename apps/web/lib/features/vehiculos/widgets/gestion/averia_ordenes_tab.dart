import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/taller/domain/repositories/orden_reparacion_repository.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/ordenes/orden_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pestaña "Taller" de la ficha de avería: órdenes de reparación vinculadas.
///
/// Se recarga cuando cambia [refreshToken] (p.ej. tras crear una orden).
class AveriaOrdenesTab extends StatefulWidget {
  const AveriaOrdenesTab({required this.averia, required this.refreshToken, super.key});

  final IncidenciaVehiculoEntity averia;
  final int refreshToken;

  @override
  State<AveriaOrdenesTab> createState() => _AveriaOrdenesTabState();
}

class _AveriaOrdenesTabState extends State<AveriaOrdenesTab> {
  late Future<List<OrdenReparacionEntity>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(AveriaOrdenesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken || oldWidget.averia.id != widget.averia.id) {
      _future = _load();
    }
  }

  Future<List<OrdenReparacionEntity>> _load() async {
    final List<OrdenReparacionEntity> ordenes =
        await getIt<OrdenReparacionRepository>().getByVehiculo(widget.averia.vehiculoId);
    return ordenes.where((OrdenReparacionEntity o) => o.incidenciaId == widget.averia.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrdenReparacionEntity>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<OrdenReparacionEntity>> snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: AppLoadingIndicator(message: 'Cargando órdenes...'),
          );
        }
        if (snap.hasError) {
          debugPrint('❌ AveriaOrdenesTab: ${snap.error}');
          return const GestionDetailBody(
            children: <Widget>[
              GestionDetailField(label: 'Órdenes', value: 'No se pudieron cargar las órdenes'),
            ],
          );
        }
        return _OrdenesList(ordenes: snap.data ?? <OrdenReparacionEntity>[]);
      },
    );
  }
}

class _OrdenesList extends StatelessWidget {
  const _OrdenesList({required this.ordenes});

  final List<OrdenReparacionEntity> ordenes;

  @override
  Widget build(BuildContext context) {
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Órdenes de reparación'),
        if (ordenes.isEmpty)
          const GestionDetailField(label: 'Órdenes', value: 'Sin órdenes. Usa "Crear orden" para enviarla al taller.')
        else
          for (final OrdenReparacionEntity o in ordenes) _OrdenResumen(orden: o),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.go('/taller/ordenes-reparacion'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Ver en Órdenes de Reparación'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _OrdenResumen extends StatelessWidget {
  const _OrdenResumen({required this.orden});

  final OrdenReparacionEntity orden;

  @override
  Widget build(BuildContext context) {
    final OrdenReparacionEntity o = orden;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestionDetailField(
          label: o.numeroOrden,
          child: GestionDotLabel(label: o.estado.displayName, color: estadoOrdenColor(o.estado)),
        ),
        GestionDetailField(label: 'Taller', value: o.tallerNombre),
        GestionDetailField(label: 'Entrada', value: formatFecha(o.fechaEntrada)),
        GestionDetailField(label: 'Coste total', value: formatEuros(o.costoTotal)),
        const Divider(height: 16, color: AppColors.gray200),
      ],
    );
  }
}
