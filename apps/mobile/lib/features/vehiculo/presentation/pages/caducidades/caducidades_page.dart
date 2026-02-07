import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';

/// Clase auxiliar para representar items con caducidad
class _CaducidadItem {
  final String nombre;
  final DateTime? fechaCaducidad;

  const _CaducidadItem({
    required this.nombre,
    this.fechaCaducidad,
  });

  bool get estaVencido {
    if (fechaCaducidad == null) return false;
    return fechaCaducidad!.isBefore(DateTime.now());
  }

  int? get diasHastaVencimiento {
    if (fechaCaducidad == null) return null;
    final diferencia = fechaCaducidad!.difference(DateTime.now());
    return diferencia.inDays;
  }
}

/// Función auxiliar para obtener datos de ejemplo
List<_CaducidadItem> _getCaducidadesEjemplo() {
  final hoy = DateTime.now();
  return [
    _CaducidadItem(
      nombre: 'Desfibrilador',
      fechaCaducidad: hoy.add(const Duration(days: 90)),
    ),
    _CaducidadItem(
      nombre: 'Baterías DEA',
      fechaCaducidad: hoy.add(const Duration(days: 15)),
    ),
    _CaducidadItem(
      nombre: 'Suero fisiológico',
      fechaCaducidad: hoy.subtract(const Duration(days: 5)),
    ),
    _CaducidadItem(
      nombre: 'Gasas estériles',
      fechaCaducidad: hoy.add(const Duration(days: 45)),
    ),
    _CaducidadItem(
      nombre: 'Vendas',
      fechaCaducidad: hoy.add(const Duration(days: 120)),
    ),
  ];
}

/// Página de control de caducidades del vehículo
class CaducidadesPage extends StatelessWidget {
  const CaducidadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<VehiculoAsignadoBloc>()..add(const LoadVehiculoAsignado()),
      child: const _CaducidadesView(),
    );
  }
}

class _CaducidadesView extends StatefulWidget {
  const _CaducidadesView();

  @override
  State<_CaducidadesView> createState() => _CaducidadesViewState();
}

class _CaducidadesViewState extends State<_CaducidadesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Control de Caducidades',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<VehiculoAsignadoBloc, VehiculoAsignadoState>(
          builder: (context, vehiculoState) {
            if (vehiculoState is VehiculoAsignadoLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (vehiculoState is VehiculoAsignadoError) {
              return _ErrorView(message: vehiculoState.message);
            }

            if (vehiculoState is! VehiculoAsignadoLoaded) {
              return const _ErrorView(
                message: 'No se pudo cargar información del vehículo',
              );
            }

            final vehiculo = vehiculoState.vehiculo;

            // TODO: Implementar carga de caducidades desde datasource
            // Por ahora, mostrar datos de ejemplo
            final List<_CaducidadItem> itemsConCaducidad = _getCaducidadesEjemplo();

            return Column(
              children: [
                _VehiculoHeader(vehiculo: vehiculo),
                _ResumenCaducidades(items: itemsConCaducidad),
                Expanded(
                  child: itemsConCaducidad.isEmpty
                      ? const _EmptyView()
                      : _CaducidadesList(items: itemsConCaducidad),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Header con información del vehículo
class _VehiculoHeader extends StatelessWidget {
  const _VehiculoHeader({required this.vehiculo});

  final VehiculoEntity vehiculo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehiculo.matricula,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${vehiculo.marca} ${vehiculo.modelo}',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Resumen de caducidades
class _ResumenCaducidades extends StatelessWidget {
  const _ResumenCaducidades({required this.items});

  final List<_CaducidadItem> items;

  @override
  Widget build(BuildContext context) {
    final vencidos = items.where((item) => item.estaVencido).length;
    final proximosAVencer = items
        .where((item) =>
            !item.estaVencido &&
            item.diasHastaVencimiento != null &&
            item.diasHastaVencimiento! <= 30)
        .length;
    final vigentes = items.length - vencidos - proximosAVencer;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResumenItem(
              label: 'Vencidos',
              count: vencidos,
              color: AppColors.error,
              icon: Icons.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ResumenItem(
              label: 'Por vencer',
              count: proximosAVencer,
              color: AppColors.warning,
              icon: Icons.warning_amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ResumenItem(
              label: 'Vigentes',
              count: vigentes,
              color: AppColors.success,
              icon: Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item individual del resumen
class _ResumenItem extends StatelessWidget {
  const _ResumenItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Lista de caducidades
class _CaducidadesList extends StatelessWidget {
  const _CaducidadesList({required this.items});

  final List<_CaducidadItem> items;

  @override
  Widget build(BuildContext context) {
    // Ordenar por fecha de caducidad (más próximo primero)
    final sortedItems = List<_CaducidadItem>.from(items)
      ..sort((a, b) {
        if (a.fechaCaducidad == null) return 1;
        if (b.fechaCaducidad == null) return -1;
        return a.fechaCaducidad!.compareTo(b.fechaCaducidad!);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        return _CaducidadCard(item: item);
      },
    );
  }
}

/// Card de item con caducidad
class _CaducidadCard extends StatelessWidget {
  const _CaducidadCard({required this.item});

  final _CaducidadItem item;

  @override
  Widget build(BuildContext context) {
    final estaVencido = item.estaVencido;
    final diasRestantes = item.diasHastaVencimiento;
    final color = _getStatusColor(estaVencido, diasRestantes);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  _getStatusIcon(estaVencido, diasRestantes),
                  color: color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(estaVencido, diasRestantes),
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.fechaCaducidad != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Vence: ${_formatFecha(item.fechaCaducidad!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(bool estaVencido, int? diasRestantes) {
    if (estaVencido) return AppColors.error;
    if (diasRestantes != null && diasRestantes <= 7) return AppColors.error;
    if (diasRestantes != null && diasRestantes <= 30) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon(bool estaVencido, int? diasRestantes) {
    if (estaVencido) return Icons.error;
    if (diasRestantes != null && diasRestantes <= 30) {
      return Icons.warning_amber;
    }
    return Icons.check_circle;
  }

  String _getStatusText(bool estaVencido, int? diasRestantes) {
    if (estaVencido) return 'VENCIDO';
    if (diasRestantes == null) return 'Sin fecha de caducidad';
    if (diasRestantes == 0) return 'Vence hoy';
    if (diasRestantes == 1) return 'Vence mañana';
    if (diasRestantes <= 7) return 'Vence en $diasRestantes días';
    if (diasRestantes <= 30) return 'Vence en $diasRestantes días';
    return 'Vigente';
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

/// Vista vacía cuando no hay caducidades
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Todo en orden',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No hay material con caducidad próxima o vencida',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
