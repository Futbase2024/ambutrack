import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/domain/repositories/equipamiento_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_estado.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Pestaña "Equipamiento" de la ficha del vehículo: resumen de la dotación.
///
/// Carga solo este vehículo (1 consulta) y guarda el resultado en memoria
/// para que volver a un vehículo ya visto sea instantáneo.
class VehiculoEquipamientoTab extends StatefulWidget {
  const VehiculoEquipamientoTab({required this.vehiculoId, required this.onOpen, super.key});

  final String vehiculoId;
  final VoidCallback onOpen;

  @override
  State<VehiculoEquipamientoTab> createState() => _VehiculoEquipamientoTabState();
}

class _VehiculoEquipamientoTabState extends State<VehiculoEquipamientoTab> {
  /// Caché compartida entre fichas (se refresca en segundo plano al volver)
  static final Map<String, List<StockVehiculoEntity>> _cache = <String, List<StockVehiculoEntity>>{};

  List<StockVehiculoEntity>? _lineas;
  String? _error;

  @override
  void initState() {
    super.initState();
    _lineas = _cache[widget.vehiculoId];
    unawaited(_cargar());
  }

  Future<void> _cargar() async {
    try {
      final List<StockVehiculoEntity> lineas =
          await getIt<EquipamientoVehiculoRepository>().getDotacion(widget.vehiculoId);
      _cache[widget.vehiculoId] = lineas;
      if (mounted) {
        setState(() {
          _lineas = lineas;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('❌ VehiculoEquipamientoTab: $e');
      if (mounted && _lineas == null) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<StockVehiculoEntity>? lineas = _lineas;
    if (_error != null) {
      return FlotaEmptyNote('No se pudo cargar el equipamiento: $_error');
    }
    if (lineas == null) {
      return const _ResumenSkeleton();
    }
    return GestionDetailBody(
      children: <Widget>[
        if (lineas.isEmpty)
          const FlotaEmptyNote('Este vehículo no tiene plantilla de equipamiento para su tipo')
        else
          _ResumenDotacion(lineas: lineas),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FlotaPanelButton(
            icon: Icons.medical_services_outlined,
            label: 'Abrir equipamiento del vehículo',
            onPressed: widget.onOpen,
          ),
        ),
      ],
    );
  }
}

/// Progreso, contadores por estado y próxima caducidad
class _ResumenDotacion extends StatelessWidget {
  const _ResumenDotacion({required this.lineas});

  final List<StockVehiculoEntity> lineas;

  @override
  Widget build(BuildContext context) {
    final List<StockVehiculoEntity> activas = lineas.where((StockVehiculoEntity l) => !l.excluido).toList();
    int count(EstadoDotacion e) => activas.where((StockVehiculoEntity l) => EstadoDotacion.of(l) == e).length;
    final int ok = activas.where((StockVehiculoEntity l) => EstadoDotacion.of(l).correcto).length;
    final List<StockVehiculoEntity> conFecha = activas
        .where((StockVehiculoEntity l) => l.fechaCaducidad != null)
        .toList()
      ..sort((StockVehiculoEntity a, StockVehiculoEntity b) => a.fechaCaducidad!.compareTo(b.fechaCaducidad!));
    final StockVehiculoEntity? proxima = conFecha.isEmpty ? null : conFecha.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionDetailSection(title: 'Dotación'),
        GestionDetailField(label: 'Completado', value: '$ok de ${activas.length} items OK'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: activas.isEmpty ? 0 : ok / activas.length,
              minHeight: 6,
              backgroundColor: AppColors.gray200,
              color: AppColors.success,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Pendiente'),
        for (final EstadoDotacion e in EstadoDotacion.values)
          if (!e.correcto && e != EstadoDotacion.excluido && count(e) > 0)
            GestionDetailField(label: e.label, child: GestionDotLabel(label: '${count(e)}', color: e.color)),
        if (activas.every((StockVehiculoEntity l) => EstadoDotacion.of(l).correcto))
          const GestionDetailField(label: 'Estado', value: 'Todo al día'),
        const GestionDetailSection(title: 'Próxima caducidad'),
        GestionDetailField(
          label: 'Fecha',
          value: proxima == null ? 'Sin fechas registradas' : GestionFormatters.fecha(proxima.fechaCaducidad),
        ),
        if (proxima != null) GestionDetailField(label: 'Item', value: proxima.productoNombre),
      ],
    );
  }
}

/// Esqueleto con la forma del resumen mientras carga
class _ResumenSkeleton extends StatelessWidget {
  const _ResumenSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Barra(width: 90, height: 12),
          SizedBox(height: 14),
          _Barra(width: double.infinity, height: 14),
          SizedBox(height: 10),
          _Barra(width: double.infinity, height: 6),
          SizedBox(height: 22),
          _Barra(width: 80, height: 12),
          SizedBox(height: 14),
          _Barra(width: 200, height: 14),
          SizedBox(height: 10),
          _Barra(width: 170, height: 14),
          SizedBox(height: 22),
          _Barra(width: 120, height: 12),
          SizedBox(height: 14),
          _Barra(width: 220, height: 14),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(4)),
    );
  }
}
