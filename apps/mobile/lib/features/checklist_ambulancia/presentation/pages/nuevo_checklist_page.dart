import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/checklist_bloc.dart';
import '../bloc/checklist_event.dart';
import '../bloc/checklist_state.dart';
import '../widgets/categoria_section.dart';
import '../widgets/item_checklist_tile.dart';
import '../widgets/tipo_checklist_selector.dart';

/// Página para crear un nuevo checklist
///
/// Permite al usuario:
/// 1. Seleccionar tipo de checklist
/// 2. Verificar todos los items
/// 3. Ingresar kilometraje
/// 4. Guardar el checklist
class NuevoChecklistPage extends StatefulWidget {
  const NuevoChecklistPage({
    super.key,
    required this.vehiculoId,
  });

  /// ID del vehículo para el que se crea el checklist
  final String vehiculoId;

  @override
  State<NuevoChecklistPage> createState() => _NuevoChecklistPageState();
}

class _NuevoChecklistPageState extends State<NuevoChecklistPage> {
  TipoChecklist _tipoSeleccionado = TipoChecklist.preServicio;
  final _kilometrajeController = TextEditingController();
  final _observacionesController = TextEditingController();
  bool _cargandoPlantilla = false;

  @override
  void initState() {
    super.initState();
    _cargarPlantilla();
  }

  @override
  void dispose() {
    _kilometrajeController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  /// Carga la plantilla de items para el tipo seleccionado
  void _cargarPlantilla() {
    setState(() {
      _cargandoPlantilla = true;
    });

    context.read<ChecklistBloc>().add(
          ChecklistEvent.iniciarNuevoChecklist(
            vehiculoId: widget.vehiculoId,
            tipo: _tipoSeleccionado,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Nuevo Checklist'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Botón cancelar
          TextButton(
            onPressed: () {
              _mostrarDialogoCancelar();
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ChecklistBloc, ChecklistState>(
          listener: (context, state) {
            state.maybeWhen(
              creandoChecklist: (vehiculoId, tipo, items, resultados, obs) {
                if (_cargandoPlantilla) {
                  setState(() {
                    _cargandoPlantilla = false;
                  });
                }
              },
              error: (mensaje, vehiculoId) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mensaje),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              guardando: () {
                // Mostrar indicador de guardado
              },
              checklistGuardado: (checklist) {
                debugPrint('✅ [NuevoChecklist] Checklist guardado, recargando historial y cerrando...');

                // Usar addPostFrameCallback para asegurar que todo se ejecute correctamente
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    debugPrint('🔙 [NuevoChecklist] Ejecutando Navigator.pop()');
                    // Cerrar la página y retornar true para indicar éxito
                    Navigator.of(context).pop(true);
                  }
                });
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              creandoChecklist: (
                vehiculoId,
                tipo,
                items,
                resultados,
                observaciones,
              ) {
                return _buildFormulario(
                  items: items,
                  resultados: resultados,
                  observaciones: observaciones,
                );
              },
              guardando: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Guardando checklist...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
              checklistGuardado: (checklist) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppColors.success,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Checklist guardado exitosamente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              orElse: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<ChecklistBloc, ChecklistState>(
        builder: (context, state) {
          return state.maybeWhen(
            creandoChecklist: (vehiculoId, tipo, items, resultados, obs) {
              final todosVerificados = resultados.length == items.length;
              return FloatingActionButton.extended(
                onPressed: todosVerificados ? () => _guardarChecklist(context) : null,
                backgroundColor: todosVerificados ? AppColors.success : AppColors.gray400,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Checklist'),
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// Construye el formulario de checklist
  Widget _buildFormulario({
    required List<ItemChecklistEntity> items,
    required Map<int, ResultadoItem> resultados,
    required Map<int, String> observaciones,
  }) {
    // Agrupar items por categoría
    final itemsPorCategoria = <CategoriaChecklist, List<int>>{};
    for (var i = 0; i < items.length; i++) {
      final categoria = items[i].categoria;
      if (!itemsPorCategoria.containsKey(categoria)) {
        itemsPorCategoria[categoria] = [];
      }
      itemsPorCategoria[categoria]!.add(i);
    }

    final totalItems = items.length;
    final itemsCompletados = resultados.length;
    final progreso = totalItems > 0 ? itemsCompletados / totalItems : 0.0;

    return Column(
      children: [
        // Barra de progreso fija
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de tipo
              TipoChecklistSelector(
                tipoSeleccionado: _tipoSeleccionado,
                onTipoChanged: (tipo) {
                  setState(() {
                    _tipoSeleccionado = tipo;
                  });
                  _cargarPlantilla();
                },
              ),
              const SizedBox(height: 16),

              // Progreso
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progreso: $itemsCompletados/$totalItems items',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progreso,
                            backgroundColor: AppColors.gray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progreso == 1.0
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(progreso * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: progreso == 1.0
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de items scrollable
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Items agrupados por categoría
              for (final entry in itemsPorCategoria.entries) ...[
                CategoriaSection(
                  categoria: entry.key,
                  initiallyExpanded: true,
                  children: [
                    for (final index in entry.value)
                      ItemChecklistTile(
                        item: items[index],
                        index: index,
                        resultado: resultados[index],
                        observaciones: observaciones[index],
                        onResultadoChanged: (resultado) {
                          context.read<ChecklistBloc>().add(
                                ChecklistEvent.actualizarItem(
                                  index: index,
                                  resultado: resultado,
                                ),
                              );
                        },
                        onObservacionesChanged: (obs) {
                          context.read<ChecklistBloc>().add(
                                ChecklistEvent.actualizarItem(
                                  index: index,
                                  resultado: resultados[index]!,
                                  observaciones: obs,
                                ),
                              );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Datos adicionales
              const SizedBox(height: 8),
              _DatosAdicionalesSection(
                kilometrajeController: _kilometrajeController,
                observacionesController: _observacionesController,
              ),
              const SizedBox(height: 80), // Espacio para el botón flotante
            ],
          ),
        ),
      ],
    );
  }

  /// Muestra diálogo de confirmación para cancelar
  Future<void> _mostrarDialogoCancelar() {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cancelar checklist?'),
        content: const Text(
          'Se perderán todos los datos no guardados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<ChecklistBloc>()
                  .add(const ChecklistEvent.cancelarChecklist());
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  /// Guarda el checklist
  void _guardarChecklist(BuildContext context) {
    // Validar kilometraje
    final kilometrajeText = _kilometrajeController.text.trim();
    if (kilometrajeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar el kilometraje'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final kilometraje = double.tryParse(kilometrajeText);
    if (kilometraje == null || kilometraje <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kilometraje inválido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Obtener datos del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) {
      debugPrint('❌ Error: Usuario no autenticado o sin datos de personal');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Obtener datos del usuario para el checklist
    final personal = authState.personal!;
    final empresaId = personal.empresaId;
    final realizadoPor = personal.usuarioId;

    // 🔍 Debug: Mostrar datos del personal
    debugPrint('📋 [NuevoChecklist] Datos del personal:');
    debugPrint('   - ID: ${personal.id}');
    debugPrint('   - Nombre: ${personal.nombreCompleto}');
    debugPrint('   - Usuario ID: $realizadoPor');
    debugPrint('   - Empresa ID: $empresaId');
    debugPrint('   - DNI: ${personal.dni}');

    // Validar que tenga empresa y usuario asignados
    if (empresaId == null || empresaId.isEmpty) {
      debugPrint('❌ Error: empresaId es null o vacío');
      debugPrint('   Datos completos del personal: $personal');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tu usuario no tiene empresa asignada.\n\n'
            'Contacta con el administrador para que te asigne una empresa.\n\n'
            'Usuario: ${personal.nombreCompleto} (${personal.dni ?? "sin DNI"})',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    if (realizadoPor == null || realizadoPor.isEmpty) {
      debugPrint('❌ Error: usuarioId es null o vacío');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error: Usuario sin ID asignado.\n'
            'Contacta con el administrador.',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final realizadoPorNombre = personal.nombreCompleto.toUpperCase();

    // Guardar
    context.read<ChecklistBloc>().add(
          ChecklistEvent.guardarChecklist(
            kilometraje: kilometraje,
            empresaId: empresaId,
            realizadoPor: realizadoPor,
            realizadoPorNombre: realizadoPorNombre,
            observacionesGenerales: _observacionesController.text.trim().isEmpty
                ? null
                : _observacionesController.text.trim(),
          ),
        );
  }
}

/// Sección de datos adicionales (kilometraje y observaciones)
class _DatosAdicionalesSection extends StatelessWidget {
  const _DatosAdicionalesSection({
    required this.kilometrajeController,
    required this.observacionesController,
  });

  final TextEditingController kilometrajeController;
  final TextEditingController observacionesController;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos Adicionales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 16),

            // Kilometraje
            TextField(
              controller: kilometrajeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kilometraje *',
                hintText: 'Ej: 45230',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.speed),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Observaciones generales
            TextField(
              controller: observacionesController,
              decoration: InputDecoration(
                labelText: 'Observaciones generales (opcional)',
                hintText: 'Añade comentarios adicionales...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.comment),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
