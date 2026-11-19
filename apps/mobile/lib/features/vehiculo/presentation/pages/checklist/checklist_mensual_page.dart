import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/checklist/checklist_bloc.dart';
import '../../bloc/checklist/checklist_event.dart';
import '../../bloc/checklist/checklist_state.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../../bloc/vehiculo_asignado/vehiculo_asignado_state.dart';

/// Página para realizar checklist mensual del vehículo (Protocolo A2)
class ChecklistMensualPage extends StatelessWidget {
  const ChecklistMensualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ChecklistBloc>()),
        BlocProvider(
          create: (context) =>
              getIt<VehiculoAsignadoBloc>()..add(const LoadVehiculoAsignado()),
        ),
      ],
      child: const _ChecklistMensualView(),
    );
  }
}

class _ChecklistMensualView extends StatefulWidget {
  const _ChecklistMensualView();

  @override
  State<_ChecklistMensualView> createState() => _ChecklistMensualViewState();
}

class _ChecklistMensualViewState extends State<_ChecklistMensualView> {
  final _kilometrajeController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void dispose() {
    _kilometrajeController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

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
          'Checklist Mensual',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<ChecklistBloc, ChecklistState>(
            builder: (context, state) {
              if (state is ChecklistTemplateLoaded) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _guardarChecklist(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ChecklistBloc, ChecklistState>(
          listener: (context, state) {
            if (state is ChecklistSaved) {
              _mostrarDialogoExito(context);
            } else if (state is ChecklistError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, checklistState) {
            return BlocBuilder<VehiculoAsignadoBloc, VehiculoAsignadoState>(
              builder: (context, vehiculoState) {
                if (checklistState is ChecklistLoading ||
                    vehiculoState is VehiculoAsignadoLoading) {
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

                // Cargar plantilla si aún no está cargada
                if (checklistState is ChecklistInitial) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.read<ChecklistBloc>().add(
                            LoadChecklistTemplate(
                              TipoChecklist.mensual,
                              vehiculo.id,
                            ),
                          );
                    }
                  });
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (checklistState is! ChecklistTemplateLoaded) {
                  return const SizedBox.shrink();
                }

                final items = checklistState.items;

                // Agrupar items por categoría
                final itemsPorCategoria = <CategoriaChecklist, List<ItemChecklistEntity>>{};
                for (final item in items) {
                  if (!itemsPorCategoria.containsKey(item.categoria)) {
                    itemsPorCategoria[item.categoria] = [];
                  }
                  itemsPorCategoria[item.categoria]!.add(item);
                }

                return Column(
                  children: [
                    _ChecklistHeader(vehiculo: vehiculo),
                    _KilometrajeInput(controller: _kilometrajeController),
                    Expanded(
                      child: itemsPorCategoria.isEmpty
                          ? const _EmptyItemsView()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: itemsPorCategoria.length + 1,
                              itemBuilder: (context, index) {
                                if (index == itemsPorCategoria.length) {
                                  return _ObservacionesInput(
                                    controller: _observacionesController,
                                  );
                                }

                                final categoria =
                                    itemsPorCategoria.keys.elementAt(index);
                                final categoryItems =
                                    itemsPorCategoria[categoria]!;

                                return _CategoriaSection(
                                  categoria: categoria,
                                  items: categoryItems,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _guardarChecklist(BuildContext context) {
    final state = context.read<ChecklistBloc>().state;
    if (state is! ChecklistTemplateLoaded) return;

    final vehiculoState = context.read<VehiculoAsignadoBloc>().state;
    if (vehiculoState is! VehiculoAsignadoLoaded) return;

    // Validar kilometraje
    final kilometrajeText = _kilometrajeController.text.trim();
    if (kilometrajeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el kilometraje actual'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final kilometraje = double.tryParse(kilometrajeText);
    if (kilometraje == null || kilometraje <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El kilometraje debe ser un número válido'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Verificar que todos los items tengan un resultado
    final itemsSinResultado = state.items.where(
      (item) => item.resultado == ResultadoItem.presente,
    );

    if (itemsSinResultado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, verifica al menos un item'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<ChecklistBloc>().add(
          SaveChecklist(
            vehiculoId: vehiculoState.vehiculo.id,
            tipo: TipoChecklist.mensual,
            kilometraje: kilometraje,
            items: state.items,
            observacionesGenerales: _observacionesController.text.trim().isEmpty
                ? null
                : _observacionesController.text.trim(),
          ),
        );
  }

  Future<void> _mostrarDialogoExito(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Checklist Guardado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'El checklist mensual ha sido completado y guardado exitosamente.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop(); // Volver a la página anterior
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header con información del vehículo
class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({required this.vehiculo});

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
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: AppColors.gray600,
              ),
              const SizedBox(width: 8),
              const Text(
                'Protocolo A2 - Día 1 del mes',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Input de kilometraje
class _KilometrajeInput extends StatelessWidget {
  const _KilometrajeInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: 'Kilometraje actual *',
          hintText: 'Ej: 125000',
          prefixIcon: const Icon(Icons.speed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Sección de categoría con items
class _CategoriaSection extends StatelessWidget {
  const _CategoriaSection({
    required this.categoria,
    required this.items,
  });

  final CategoriaChecklist categoria;
  final List<ItemChecklistEntity> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoriaIcon(categoria),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  categoria.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ItemChecklistTile(item: item);
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoriaIcon(CategoriaChecklist categoria) {
    switch (categoria) {
      case CategoriaChecklist.equiposTraslado:
        return Icons.airline_seat_flat;
      case CategoriaChecklist.equipoVentilacion:
        return Icons.air;
      case CategoriaChecklist.equipoDiagnostico:
        return Icons.monitor_heart;
      case CategoriaChecklist.equipoInfusion:
        return Icons.water_drop;
      case CategoriaChecklist.equipoEmergencia:
        return Icons.emergency;
      case CategoriaChecklist.vendajesAsistencia:
        return Icons.healing;
      case CategoriaChecklist.documentacion:
        return Icons.description;
    }
  }
}

/// Tile de item individual del checklist
class _ItemChecklistTile extends StatelessWidget {
  const _ItemChecklistTile({required this.item});

  final ItemChecklistEntity item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _mostrarDialogoVerificar(context, item),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Checkbox o icono de estado
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getResultadoColor(item.resultado),
                  width: 2,
                ),
                color: item.resultado != ResultadoItem.presente
                    ? _getResultadoColor(item.resultado).withValues(alpha: 0.1)
                    : null,
              ),
              child: item.resultado == ResultadoItem.presente
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: _getResultadoColor(item.resultado),
                    )
                  : item.resultado == ResultadoItem.ausente
                      ? Icon(
                          Icons.close,
                          size: 16,
                          color: _getResultadoColor(item.resultado),
                        )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemNombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (item.cantidadRequerida != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${item.cantidadRequerida}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                  if (item.observaciones != null && item.observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.observaciones!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getResultadoColor(ResultadoItem resultado) {
    switch (resultado) {
      case ResultadoItem.presente:
        return AppColors.success;
      case ResultadoItem.ausente:
        return AppColors.error;
      case ResultadoItem.noAplica:
        return AppColors.gray500;
    }
  }

  void _mostrarDialogoVerificar(BuildContext context, ItemChecklistEntity item) {
    final resultadoController = ValueNotifier<ResultadoItem>(item.resultado);
    final observacionesController = TextEditingController(
      text: item.observaciones ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.checklist,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Verificar Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  item.itemNombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                if (item.cantidadRequerida != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Cantidad requerida: ${item.cantidadRequerida}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Resultado de la verificación:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<ResultadoItem>(
                  valueListenable: resultadoController,
                  builder: (context, resultado, child) {
                    return Column(
                      children: [
                        _ResultadoOption(
                          label: 'Presente',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          isSelected: resultado == ResultadoItem.presente,
                          onTap: () => resultadoController.value =
                              ResultadoItem.presente,
                        ),
                        const SizedBox(height: 8),
                        _ResultadoOption(
                          label: 'Ausente',
                          icon: Icons.cancel,
                          color: AppColors.error,
                          isSelected: resultado == ResultadoItem.ausente,
                          onTap: () =>
                              resultadoController.value = ResultadoItem.ausente,
                        ),
                        const SizedBox(height: 8),
                        _ResultadoOption(
                          label: 'No Aplica',
                          icon: Icons.remove_circle,
                          color: AppColors.gray500,
                          isSelected: resultado == ResultadoItem.noAplica,
                          onTap: () =>
                              resultadoController.value = ResultadoItem.noAplica,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: observacionesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    hintText: 'Notas adicionales sobre el item...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          observacionesController.dispose();
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.gray300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ChecklistBloc>().add(
                                UpdateItemResultado(
                                  itemId: item.id,
                                  resultado: resultadoController.value,
                                  observaciones:
                                      observacionesController.text.trim().isEmpty
                                          ? null
                                          : observacionesController.text.trim(),
                                ),
                              );
                          observacionesController.dispose();
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opción de resultado (Presente/Ausente/No Aplica)
class _ResultadoOption extends StatelessWidget {
  const _ResultadoOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.gray50,
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.gray600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.gray700,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Input de observaciones generales
class _ObservacionesInput extends StatelessWidget {
  const _ObservacionesInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 80),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Observaciones Generales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Notas adicionales sobre el checklist...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista vacía cuando no hay items
class _EmptyItemsView extends StatelessWidget {
  const _EmptyItemsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay items en la plantilla',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ],
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
