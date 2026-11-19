import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/caducidades_bloc.dart';
import '../bloc/caducidades_event.dart';
import '../bloc/caducidades_state.dart';
import '../widgets/dialogs/solicitud_reposicion_dialog.dart';
import '../widgets/dialogs/registrar_incidencia_dialog.dart';
import '../widgets/dialogs/editar_caducidad_dialog.dart';

/// Página de detalle de un item con caducidad
///
/// Muestra información completa del item:
/// - Producto (nombre + nombre comercial + categoría)
/// - Fecha de caducidad + días restantes
/// - Lote, ubicación, cantidad
/// - Estado de caducidad con badge
/// - Botones de acción (Solicitar Reposición, Registrar Incidencia)
class DetalleCaducidadPage extends StatelessWidget {
  const DetalleCaducidadPage({
    super.key,
    required this.item,
    required this.vehiculoId,
  });

  final StockVehiculoEntity item;
  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text(
          'Detalle de Caducidad',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<CaducidadesBloc, CaducidadesState>(
        listener: (context, state) {
          state.maybeWhen(
            accionExitosa: (mensaje, vehiculoIdEstado) {
              // Recargar datos después de una acción exitosa
              context.read<CaducidadesBloc>().add(
                    CaducidadesEvent.cargarCaducidades(vehiculoId: vehiculoId),
                  );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (items, alertas, vehiculoIdEstado, filtroActual, total, ok, proximos, criticos, caducados, isRefreshing) {
              // Buscar el item actualizado en la lista
              final itemActualizado = items.firstWhere(
                (i) => i.id == item.id,
                orElse: () => item, // Si no se encuentra, usar el original
              );

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con nombre del producto
                      _ProductoHeader(item: itemActualizado),
                      const SizedBox(height: 20),

                      // Card de información principal
                      _InformacionPrincipalCard(item: itemActualizado),
                      const SizedBox(height: 16),

                      // Card de caducidad
                      _CaducidadCard(item: itemActualizado),
                      const SizedBox(height: 16),

                      // Card de ubicación y lote
                      _UbicacionLoteCard(item: itemActualizado),
                      const SizedBox(height: 24),

                      // Botones de acción principales (Editar, Eliminar)
                      _AccionesPrincipalesSection(
                        item: itemActualizado,
                        vehiculoId: vehiculoId,
                      ),
                      const SizedBox(height: 16),

                      // Botones de acción secundarias (solo si crítico o caducado)
                      if (_mostrarBotonesAccion(itemActualizado)) ...[
                        _AccionesSecundariasSection(
                          item: itemActualizado,
                          vehiculoId: vehiculoId,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
            orElse: () {
              // Mostrar el item original mientras se carga
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductoHeader(item: item),
                      const SizedBox(height: 20),
                      _InformacionPrincipalCard(item: item),
                      const SizedBox(height: 16),
                      _CaducidadCard(item: item),
                      const SizedBox(height: 16),
                      _UbicacionLoteCard(item: item),
                      const SizedBox(height: 24),
                      _AccionesPrincipalesSection(
                        item: item,
                        vehiculoId: vehiculoId,
                      ),
                      const SizedBox(height: 16),
                      if (_mostrarBotonesAccion(item)) ...[
                        _AccionesSecundariasSection(
                          item: item,
                          vehiculoId: vehiculoId,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _mostrarBotonesAccion(StockVehiculoEntity itemToCheck) {
    return itemToCheck.estadoCaducidad == 'critico' ||
        itemToCheck.estadoCaducidad == 'caducado';
  }
}

/// Widget para el header con nombre del producto
class _ProductoHeader extends StatelessWidget {
  const _ProductoHeader({required this.item});

  final StockVehiculoEntity item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.categoriaNombre != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.categoriaNombre!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            item.productoNombre ?? 'Sin nombre',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              height: 1.2,
              letterSpacing: -0.8,
            ),
          ),
          if (item.nombreComercial != null) ...[
            const SizedBox(height: 8),
            Text(
              item.nombreComercial!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card con información principal (cantidad, stock mínimo)
class _InformacionPrincipalCard extends StatelessWidget {
  const _InformacionPrincipalCard({required this.item});

  final StockVehiculoEntity item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoFieldBoxed(
                    label: 'Cantidad Actual',
                    value: '${item.cantidadActual}',
                    unit: 'uds',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoFieldBoxed(
                    label: 'Cantidad Mínima',
                    value: '${item.cantidadMinima ?? 0}',
                    unit: 'uds',
                    icon: Icons.warning_amber_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card con información de caducidad
class _CaducidadCard extends StatelessWidget {
  const _CaducidadCard({required this.item});

  final StockVehiculoEntity item;

  @override
  Widget build(BuildContext context) {
    final diasRestantes = _calcularDiasRestantes();
    final color = _getColorDiasRestantes();
    final estado = _getEstadoTexto();

    return Card(
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withValues(alpha: 0.03),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estado de Caducidad',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    letterSpacing: -0.5,
                  ),
                ),
                _EstadoBadge(estadoCaducidad: item.estadoCaducidad),
              ],
            ),
            const SizedBox(height: 20),
            _InfoField(
              label: 'Fecha de Caducidad',
              value: _formatFechaCaducidad(),
              icon: Icons.calendar_today_outlined,
              color: AppColors.gray900,
            ),
            const SizedBox(height: 16),
            _InfoField(
              label: 'Días Restantes',
              value: diasRestantes < 0 ? 'Caducado' : '$diasRestantes días',
              icon: Icons.timelapse_outlined,
              color: AppColors.gray900,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getEstadoIcono(),
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      estado,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFechaCaducidad() {
    if (item.fechaCaducidad == null) return 'No disponible';
    final fecha = item.fechaCaducidad!;
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  int _calcularDiasRestantes() {
    if (item.fechaCaducidad == null) return 0;
    return item.fechaCaducidad!.difference(DateTime.now()).inDays;
  }

  Color _getColorDiasRestantes() {
    if (item.fechaCaducidad == null) return AppColors.gray700;
    final dias = _calcularDiasRestantes();
    if (dias < 0) return AppColors.emergency;
    if (dias <= 7) return AppColors.error;
    if (dias <= 30) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getEstadoIcono() {
    final estado = item.estadoCaducidad ?? 'sin_caducidad';
    switch (estado) {
      case 'ok':
        return Icons.check_circle;
      case 'proximo':
        return Icons.warning_amber;
      case 'critico':
        return Icons.error;
      case 'caducado':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getEstadoTexto() {
    final dias = _calcularDiasRestantes();
    if (dias < 0) {
      return 'Este producto ya ha caducado. Debe ser retirado inmediatamente.';
    } else if (dias <= 7) {
      return 'Estado crítico: Caducidad inminente. Planificar reposición urgente.';
    } else if (dias <= 30) {
      return 'Próximo a caducar. Considerar solicitar reposición pronto.';
    } else {
      return 'Estado correcto. Caducidad dentro del plazo normal.';
    }
  }
}

/// Card con información de ubicación y lote
class _UbicacionLoteCard extends StatelessWidget {
  const _UbicacionLoteCard({required this.item});

  final StockVehiculoEntity item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.info.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles Adicionales',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            _InfoField(
              label: 'Ubicación',
              value: item.ubicacion ?? 'No especificada',
              icon: Icons.location_on_outlined,
              color: AppColors.gray900,
            ),
            const SizedBox(height: 16),
            _InfoField(
              label: 'Lote',
              value: item.lote ?? 'No especificado',
              icon: Icons.qr_code_outlined,
              color: AppColors.gray900,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de campo de información
class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.gray600),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Widget de campo de información con caja de color
class _InfoFieldBoxed extends StatelessWidget {
  const _InfoFieldBoxed({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para badge de estado de caducidad
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estadoCaducidad});

  final String? estadoCaducidad;

  @override
  Widget build(BuildContext context) {
    final estado = estadoCaducidad ?? 'sin_caducidad';
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (estado) {
      case 'ok':
        backgroundColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle;
        label = 'OK';
        break;
      case 'proximo':
        backgroundColor = AppColors.warning;
        textColor = AppColors.gray900;
        icon = Icons.warning_amber;
        label = 'Próximo';
        break;
      case 'critico':
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.error;
        label = 'Crítico';
        break;
      case 'caducado':
        backgroundColor = AppColors.emergency;
        textColor = Colors.white;
        icon = Icons.cancel;
        label = 'Caducado';
        break;
      default:
        backgroundColor = AppColors.gray500;
        textColor = Colors.white;
        icon = Icons.info;
        label = 'N/A';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de acciones principales (Editar, Eliminar)
class _AccionesPrincipalesSection extends StatelessWidget {
  const _AccionesPrincipalesSection({
    required this.item,
    required this.vehiculoId,
  });

  final StockVehiculoEntity item;
  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _mostrarDialogoEditar(context),
                icon: const Icon(Icons.edit, size: 20),
                label: const Text(
                  'Editar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _mostrarDialogoEliminar(context),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text(
                  'Eliminar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.error, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoEditar(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Capturar el BLoC antes de abrir el diálogo
    final caducidadesBloc = context.read<CaducidadesBloc>();

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => EditarCaducidadDialog(
        item: item,
        onGuardar: ({
          required cantidadActual,
          fechaCaducidad,
          lote,
          ubicacion,
          observaciones,
        }) async {
          // Disparar evento en el BLoC
          caducidadesBloc.add(
                CaducidadesEvent.actualizarItem(
                  itemId: item.id,
                  cantidadActual: cantidadActual,
                  fechaCaducidad: fechaCaducidad,
                  lote: lote,
                  ubicacion: ubicacion,
                  observaciones: observaciones,
                ),
              );
        },
      ),
    );
  }

  Future<void> _mostrarDialogoEliminar(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Capturar el BLoC antes de abrir el diálogo
    final caducidadesBloc = context.read<CaducidadesBloc>();

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Eliminar item?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '¿Estás seguro de que deseas eliminar "${item.productoNombre ?? 'este item'}"?\n\nEsta acción no se puede deshacer.',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmar == true && context.mounted) {
      // Disparar evento de eliminación
      caducidadesBloc.add(
            CaducidadesEvent.eliminarItem(
              itemId: item.id,
              vehiculoId: vehiculoId,
              productoNombre: item.productoNombre ?? 'Sin nombre',
              usuarioId: authState.user.id,
            ),
          );

      // Volver a la página anterior
      Navigator.of(context).pop();
    }
  }
}

/// Sección de acciones secundarias (Solicitar Reposición, Registrar Incidencia)
class _AccionesSecundariasSection extends StatelessWidget {
  const _AccionesSecundariasSection({
    required this.item,
    required this.vehiculoId,
  });

  final StockVehiculoEntity item;
  final String vehiculoId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Adicionales',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _mostrarDialogoSolicitudReposicion(context),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Solicitar Reposición',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _mostrarDialogoRegistrarIncidencia(context),
            icon: const Icon(Icons.report_problem_outlined, size: 20),
            label: const Text(
              'Registrar Incidencia',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.error, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoSolicitudReposicion(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SolicitudReposicionDialog(
        productoNombre: item.productoNombre ?? 'Sin nombre',
        cantidadActual: item.cantidadActual,
        onSolicitar: (cantidad, motivo) async {
          // Disparar evento en el BLoC
          context.read<CaducidadesBloc>().add(
                CaducidadesEvent.solicitarReposicion(
                  vehiculoId: vehiculoId,
                  productoId: item.productoId,
                  productoNombre: item.productoNombre ?? 'Sin nombre',
                  cantidadSolicitada: cantidad,
                  motivo: motivo,
                  usuarioId: authState.user.id,
                ),
              );
        },
      ),
    );
  }

  Future<void> _mostrarDialogoRegistrarIncidencia(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) return;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RegistrarIncidenciaDialog(
        productoNombre: item.productoNombre ?? 'Sin nombre',
        onRegistrar: (titulo, descripcion) async {
          // Disparar evento en el BLoC
          context.read<CaducidadesBloc>().add(
                CaducidadesEvent.registrarIncidencia(
                  vehiculoId: vehiculoId,
                  titulo: titulo,
                  descripcion: descripcion,
                  reportadoPor: authState.user.id,
                  reportadoPorNombre: authState.personal!.nombreCompleto,
                  empresaId: authState.personal!.empresaId ?? '',
                ),
              );
        },
      ),
    );
  }
}
