import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/dialogs/dialogs.dart';
import '../bloc/notificaciones_bloc.dart';
import '../bloc/notificaciones_event.dart';
import '../bloc/notificaciones_state.dart';
import '../widgets/notificacion_card.dart';
import '../widgets/notificaciones_empty_state.dart';

/// Página de notificaciones
///
/// Muestra la lista de notificaciones del usuario con:
/// - Pull-to-refresh
/// - Marcar todas como leídas
/// - Swipe-to-delete
/// - Estado vacío
class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificacionesBloc>()..add(const NotificacionesEvent.started()),
      child: const _NotificacionesView(),
    );
  }
}

class _NotificacionesView extends StatefulWidget {
  const _NotificacionesView();

  @override
  State<_NotificacionesView> createState() => _NotificacionesViewState();
}

class _NotificacionesViewState extends State<_NotificacionesView> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<NotificacionEntity> notificaciones) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(notificaciones.map((n) => n.id));
    });
  }

  Future<void> _confirmarEliminarTodas(BuildContext context) async {
    final confirmed = await showProfessionalConfirmDialog(
      context,
      title: '¿Eliminar todas las notificaciones?',
      message: 'Esta acción eliminará TODAS tus notificaciones y no se puede deshacer.',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      confirmLabel: 'Eliminar todas',
      cancelLabel: 'Cancelar',
    );

    if (confirmed == true && context.mounted) {
      context.read<NotificacionesBloc>().add(
            const NotificacionesEvent.eliminarTodas(),
          );

      // Mostrar resultado con diálogo profesional
      if (context.mounted) {
        await showProfessionalResultDialog(
          context,
          title: 'Notificaciones eliminadas',
          message: 'Todas las notificaciones han sido eliminadas correctamente.',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
        );
      }
    }
  }

  Future<void> _confirmarEliminarSeleccionadas(BuildContext context) async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final confirmed = await showProfessionalConfirmDialog(
      context,
      title: '¿Eliminar notificaciones seleccionadas?',
      message: 'Se eliminarán $count notificación${count > 1 ? 'es' : ''}. Esta acción no se puede deshacer.',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      confirmLabel: 'Eliminar',
      cancelLabel: 'Cancelar',
    );

    if (confirmed == true && context.mounted) {
      final idsToDelete = _selectedIds.toList();
      context.read<NotificacionesBloc>().add(
            NotificacionesEvent.eliminarSeleccionadas(idsToDelete),
          );
      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });

      // Mostrar resultado con diálogo profesional
      if (context.mounted) {
        await showProfessionalResultDialog(
          context,
          title: 'Notificaciones eliminadas',
          message: '$count notificación${count > 1 ? 'es' : ''} eliminada${count > 1 ? 's' : ''} correctamente.',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
        );
      }
    }
  }

  /// Muestra el menú de opciones con diseño profesional
  Future<void> _mostrarMenuOpciones(BuildContext context, int conteoNoLeidas) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Opciones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Marcar todas como leídas
            if (conteoNoLeidas > 0)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.done_all_rounded, color: Colors.green, size: 20),
                ),
                title: const Text('Marcar todas como leídas'),
                subtitle: Text('$conteoNoLeidas notificaciones sin leer'),
                onTap: () async {
                  Navigator.pop(context);
                  this.context.read<NotificacionesBloc>().add(
                        const NotificacionesEvent.marcarTodasLeidas(),
                      );

                  // Mostrar resultado con diálogo profesional
                  if (this.context.mounted) {
                    await showProfessionalResultDialog(
                      this.context,
                      title: 'Notificaciones marcadas',
                      message: 'Todas las notificaciones han sido marcadas como leídas.',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                    );
                  }
                },
              ),

            // Seleccionar
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.checklist_rounded, color: Colors.blue, size: 20),
              ),
              title: const Text('Seleccionar'),
              subtitle: const Text('Seleccionar múltiples notificaciones'),
              onTap: () {
                Navigator.pop(context);
                _toggleSelectionMode();
              },
            ),

            // Eliminar todas
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 20),
              ),
              title: const Text(
                'Eliminar todas',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Eliminar todas las notificaciones'),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarTodas(this.context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedIds.length} seleccionadas' : 'Notificaciones'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: [
          if (!_isSelectionMode)
            BlocBuilder<NotificacionesBloc, NotificacionesState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (notificaciones, conteoNoLeidas, isRefreshing) {
                    if (notificaciones.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      tooltip: 'Opciones',
                      onPressed: () => _mostrarMenuOpciones(context, conteoNoLeidas),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                );
              },
            )
          else
            TextButton(
              onPressed: () {
                final state = context.read<NotificacionesBloc>().state;
                state.maybeWhen(
                  loaded: (notificaciones, _, __) {
                    if (_selectedIds.length == notificaciones.length) {
                      setState(() => _selectedIds.clear());
                    } else {
                      _selectAll(notificaciones);
                    }
                  },
                  orElse: () {},
                );
              },
              child: BlocBuilder<NotificacionesBloc, NotificacionesState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    loaded: (notificaciones, _, __) {
                      final allSelected = _selectedIds.length == notificaciones.length;
                      return Text(allSelected ? 'Deseleccionar todo' : 'Seleccionar todo');
                    },
                    orElse: () => const Text('Seleccionar todo'),
                  );
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<NotificacionesBloc, NotificacionesState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (notificaciones, conteoNoLeidas, isRefreshing) {
                if (notificaciones.isEmpty) {
                  return const NotificacionesEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<NotificacionesBloc>().add(
                          const NotificacionesEvent.refreshRequested(),
                        );
                    // Esperar un momento para que se complete la recarga
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    itemCount: notificaciones.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemBuilder: (context, index) {
                      final notificacion = notificaciones[index];
                      final isSelected = _selectedIds.contains(notificacion.id);

                      // Modo selección
                      if (_isSelectionMode) {
                        return InkWell(
                          onTap: () => _toggleSelection(notificacion.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelection(notificacion.id),
                                ),
                                Expanded(
                                  child: NotificacionCard(
                                    notificacion: notificacion,
                                    onTap: () => _toggleSelection(notificacion.id),
                                    showSwipeActions: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Modo normal
                      return NotificacionCard(
                        notificacion: notificacion,
                        onTap: () {
                          // Marcar como leída al hacer tap
                          if (!notificacion.leida) {
                            context.read<NotificacionesBloc>().add(
                                  NotificacionesEvent.marcarComoLeida(
                                    notificacion.id,
                                  ),
                                );
                          }

                          // Navegar según el tipo de notificación
                          _navegarSegunTipo(context, notificacion);
                        },
                        onDelete: () async {
                          context.read<NotificacionesBloc>().add(
                                NotificacionesEvent.eliminar(notificacion.id),
                              );

                          // Mostrar resultado con diálogo profesional
                          if (context.mounted) {
                            await showProfessionalResultDialog(
                              context,
                              title: 'Notificación eliminada',
                              message: 'La notificación ha sido eliminada correctamente.',
                              icon: Icons.check_circle_outline,
                              iconColor: AppColors.success,
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
              error: (message, notificacionesPrevias, conteoNoLeidasPrevio) {
                // Si hay datos previos, mostrarlos con un mensaje de error
                if (notificacionesPrevias != null && notificacionesPrevias.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error al cargar notificaciones',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<NotificacionesBloc>().add(
                                      const NotificacionesEvent.loadRequested(),
                                    );
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: notificacionesPrevias.length,
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          itemBuilder: (context, index) {
                            final notificacion = notificacionesPrevias[index];
                            return NotificacionCard(
                              notificacion: notificacion,
                              onTap: () => _navegarSegunTipo(context, notificacion),
                              onDelete: () {
                                context.read<NotificacionesBloc>().add(
                                      NotificacionesEvent.eliminar(notificacion.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                // Sin datos previos, mostrar error completo
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar notificaciones',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<NotificacionesBloc>().add(
                                  const NotificacionesEvent.loadRequested(),
                                );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _isSelectionMode && _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _confirmarEliminarSeleccionadas(context),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete_rounded),
              label: Text('Eliminar (${_selectedIds.length})'),
            )
          : null,
    );
  }

  /// Navega a la pantalla correspondiente según el tipo de notificación
  void _navegarSegunTipo(BuildContext context, NotificacionEntity notificacion) {
    switch (notificacion.tipo) {
      case NotificacionTipo.trasladoAsignado:
      case NotificacionTipo.trasladoIniciado:
      case NotificacionTipo.trasladoFinalizado:
      case NotificacionTipo.trasladoCancelado:
        // Navegar a la lista general de Mis Servicios
        debugPrint('📍 [Notificaciones] Navegando a Mis Servicios');
        context.push('/servicios');
        break;

      case NotificacionTipo.trasladoDesadjudicado:
        // No navegar porque el traslado ya no está asignado al usuario
        // Solo se marca como leída (ya se hizo antes de llamar a esta función)
        break;

      case NotificacionTipo.checklistPendiente:
        // Navegar a checklist de ambulancia
        context.push('/checklist-ambulancia');
        break;

      case NotificacionTipo.vacacionSolicitada:
      case NotificacionTipo.vacacionAprobada:
      case NotificacionTipo.vacacionRechazada:
        // Por ahora mostrar mensaje (feature de vacaciones no implementado en mobile)
        _mostrarMensaje(
          context,
          'Las vacaciones se gestionan desde la aplicación web',
        );
        break;

      case NotificacionTipo.ausenciaSolicitada:
      case NotificacionTipo.ausenciaAprobada:
      case NotificacionTipo.ausenciaRechazada:
        // Por ahora mostrar mensaje (feature de ausencias no implementado en mobile)
        _mostrarMensaje(
          context,
          'Las ausencias se gestionan desde la aplicación web',
        );
        break;

      case NotificacionTipo.cambioTurno:
        // Por ahora mostrar mensaje (feature de turnos no implementado en mobile)
        _mostrarMensaje(
          context,
          'Los turnos se gestionan desde la aplicación web',
        );
        break;

      case NotificacionTipo.incidenciaVehiculoReportada:
        // Las incidencias de vehículos se gestionan desde la aplicación web
        _mostrarMensaje(
          context,
          'Las incidencias de vehículos se gestionan desde la aplicación web',
        );
        break;

      case NotificacionTipo.alerta:
      case NotificacionTipo.info:
        // Solo marcar como leída, sin navegación adicional
        break;
    }
  }

  Future<void> _mostrarMensaje(BuildContext context, String mensaje) async {
    await showProfessionalResultDialog(
      context,
      title: 'Información',
      message: mensaje,
      icon: Icons.info_outline,
      iconColor: AppColors.info,
    );
  }
}
