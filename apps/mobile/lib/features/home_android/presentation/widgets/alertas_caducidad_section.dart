import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../caducidades/presentation/bloc/caducidades_bloc.dart';
import '../../../caducidades/presentation/bloc/caducidades_event.dart';
import '../../../caducidades/presentation/bloc/caducidades_state.dart';
import '../../../checklist_ambulancia/data/services/vehiculo_cache_service.dart';
import '../../../checklist_ambulancia/domain/repositories/checklist_repository.dart';
import 'dialogs/alertas_caducidad_dialog.dart';

/// Franja de avisos de caducidad del vehículo asignado
///
/// Solo ocupa espacio si hay productos caducados, críticos o próximos a caducar.
/// Al pulsarla se abre el detalle agrupado por categoría.
class AlertasCaducidadHomeSection extends StatefulWidget {
  const AlertasCaducidadHomeSection({super.key});

  @override
  State<AlertasCaducidadHomeSection> createState() => _AlertasCaducidadHomeSectionState();
}

class _AlertasCaducidadHomeSectionState extends State<AlertasCaducidadHomeSection> {
  String? _vehiculoId;

  @override
  void initState() {
    super.initState();
    _cargarVehiculo();
  }

  Future<void> _cargarVehiculo() async {
    final AuthState authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) {
      return;
    }

    final String personalId = authState.personal!.id;
    final VehiculoCacheService cache = VehiculoCacheService.instance;
    String? vehiculoId = cache.getVehiculoAsignado(personalId);

    if (vehiculoId == null) {
      try {
        vehiculoId = await getIt<ChecklistRepository>().getVehiculoAsignadoHoy(personalId);
        if (vehiculoId != null) {
          cache.setVehiculoAsignado(personalId, vehiculoId);
        }
      } catch (e) {
        debugPrint('❌ AlertasCaducidad: error al obtener vehículo asignado: $e');
      }
    }

    if (mounted && vehiculoId != null) {
      setState(() => _vehiculoId = vehiculoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? vehiculoId = _vehiculoId;
    if (vehiculoId == null) {
      return const SizedBox.shrink();
    }

    return BlocProvider<CaducidadesBloc>(
      create: (_) => getIt<CaducidadesBloc>()..add(CaducidadesEvent.started(vehiculoId: vehiculoId)),
      child: BlocBuilder<CaducidadesBloc, CaducidadesState>(
        builder: (context, state) {
          final List<StockVehiculoEntity> items = state.maybeWhen(
            loaded: (items, _, _, _, _, _, _, _, _, _) => items,
            orElse: () => const <StockVehiculoEntity>[],
          );
          final _ResumenAlertas resumen = _ResumenAlertas.desde(items);
          if (resumen.total == 0) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AlertasBanner(resumen: resumen, vehiculoId: vehiculoId),
          );
        },
      ),
    );
  }
}

/// Conteo de productos con aviso de caducidad
class _ResumenAlertas {
  const _ResumenAlertas({required this.items, required this.caducados, required this.criticos});

  factory _ResumenAlertas.desde(List<StockVehiculoEntity> todos) {
    final List<StockVehiculoEntity> items = <StockVehiculoEntity>[];
    int caducados = 0;
    int criticos = 0;
    for (final StockVehiculoEntity item in todos) {
      final String estado = _estado(item);
      if (estado == 'caducado' || estado == 'critico' || estado == 'proximo') {
        items.add(item);
        if (estado == 'caducado') {
          caducados++;
        } else if (estado == 'critico') {
          criticos++;
        }
      }
    }
    return _ResumenAlertas(items: items, caducados: caducados, criticos: criticos);
  }

  final List<StockVehiculoEntity> items;
  final int caducados;
  final int criticos;

  int get total => items.length;
  int get proximos => total - caducados - criticos;

  /// Usa el estado calculado en BD o lo deduce de la fecha de caducidad
  static String _estado(StockVehiculoEntity item) {
    final String? estado = item.estadoCaducidad;
    if (estado != null && estado != 'null') {
      return estado;
    }
    final DateTime? fecha = item.fechaCaducidad;
    if (fecha == null) {
      return 'sin_caducidad';
    }
    final int dias = fecha.difference(DateTime.now()).inDays;
    if (dias < 0) {
      return 'caducado';
    }
    if (dias <= 7) {
      return 'critico';
    }
    return dias <= 30 ? 'proximo' : 'ok';
  }
}

/// Franja visual con el resumen de avisos
class _AlertasBanner extends StatelessWidget {
  const _AlertasBanner({required this.resumen, required this.vehiculoId});

  final _ResumenAlertas resumen;
  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    final bool grave = resumen.caducados > 0 || resumen.criticos > 0;
    final Color color = grave ? AppColors.error : AppColors.warning;

    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => AlertasCaducidadDialog(items: resumen.items, vehiculoId: vehiculoId),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: <Widget>[
              Icon(grave ? Icons.error_outline_rounded : Icons.warning_amber_rounded, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(child: _AlertasTexto(resumen: resumen)),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Título y desglose de la franja
class _AlertasTexto extends StatelessWidget {
  const _AlertasTexto({required this.resumen});

  final _ResumenAlertas resumen;

  @override
  Widget build(BuildContext context) {
    final int total = resumen.total;
    final List<String> partes = <String>[
      if (resumen.caducados > 0) '${resumen.caducados} caducado${resumen.caducados == 1 ? '' : 's'}',
      if (resumen.criticos > 0) '${resumen.criticos} crítico${resumen.criticos == 1 ? '' : 's'}',
      if (resumen.proximos > 0) '${resumen.proximos} próximo${resumen.proximos == 1 ? '' : 's'}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$total producto${total == 1 ? '' : 's'} con caducidad a revisar',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        const SizedBox(height: 2),
        Text(
          partes.join(' · '),
          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
        ),
      ],
    );
  }
}
