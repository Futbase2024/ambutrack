import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/bloc/servicios_state.dart';
import 'package:flutter/material.dart';

/// Servicio seleccionado en el estado del BLoC (o null)
ServicioEntity? servicioSeleccionado(ServiciosState state) {
  return state.maybeWhen(
    loaded: (
      List<ServicioEntity> servicios,
      String searchQuery,
      int? yearFilter,
      String? estadoFilter,
      bool isRefreshing,
      ServicioEntity? selectedServicio,
      bool isLoadingDetails,
    ) =>
        selectedServicio,
    orElse: () => null,
  );
}

/// Barra de herramientas de servicios: alta + acciones sobre el seleccionado
class ServiciosToolbar extends StatelessWidget {
  const ServiciosToolbar({
    required this.state,
    required this.onNuevo,
    required this.onEditar,
    required this.onEliminar,
    required this.onFinalizar,
    required this.onSuspender,
    required this.onReanudar,
    required this.onExcluir,
    super.key,
  });

  final ServiciosState state;
  final VoidCallback onNuevo;
  final ValueChanged<ServicioEntity> onEditar;
  final ValueChanged<ServicioEntity> onEliminar;
  final ValueChanged<ServicioEntity> onFinalizar;
  final ValueChanged<ServicioEntity> onSuspender;
  final ValueChanged<ServicioEntity> onReanudar;
  final ValueChanged<ServicioEntity> onExcluir;

  @override
  Widget build(BuildContext context) {
    final ServicioEntity? sel = servicioSeleccionado(state);
    final bool isActive = sel != null && sel.estado == 'ACTIVO';
    final bool isSuspended = sel != null && sel.estado == 'SUSPENDIDO';

    VoidCallback? on(ValueChanged<ServicioEntity> action, {bool enabled = true}) =>
        enabled && sel != null ? () => action(sel) : null;

    return GestionToolbar(
      title: 'Gestión de Servicios',
      icon: Icons.medical_services,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.add, label: 'Nuevo', primary: true, onPressed: onNuevo),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.edit_outlined, label: 'Editar', onPressed: on(onEditar)),
          GestionToolbarAction(
            icon: Icons.delete_outline,
            label: 'Eliminar',
            destructive: true,
            onPressed: on(onEliminar),
          ),
        ],
        <GestionToolbarAction>[
          GestionToolbarAction(
            icon: Icons.done_all,
            label: 'Finalizar',
            onPressed: on(onFinalizar, enabled: isActive),
          ),
          GestionToolbarAction(
            icon: Icons.pause_circle_outline,
            label: 'Suspender',
            onPressed: on(onSuspender, enabled: isActive),
          ),
          GestionToolbarAction(
            icon: Icons.play_circle_outline,
            label: 'Reanudar',
            onPressed: on(onReanudar, enabled: isSuspended),
          ),
          GestionToolbarAction(
            icon: Icons.block,
            label: 'Excluir',
            onPressed: on(onExcluir, enabled: isActive),
          ),
        ],
      ],
    );
  }
}

/// Barra de filtros de servicios: búsqueda, año y estado
class ServiciosFilterBar extends StatelessWidget {
  const ServiciosFilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.year,
    required this.onYearChanged,
    required this.estado,
    required this.onEstadoChanged,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final int? year;
  final ValueChanged<int> onYearChanged;

  /// Estado seleccionado (null = todos)
  final String? estado;
  final ValueChanged<String?> onEstadoChanged;

  static const String _todos = 'TODOS';

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar servicio...',
          width: 260,
        ),
        GestionFilterDropdown<int>(
          label: 'Año',
          value: year ?? currentYear,
          options: <int, String>{
            for (int i = 0; i < 5; i++) currentYear - i: '${currentYear - i}',
          },
          onChanged: onYearChanged,
        ),
        GestionFilterDropdown<String>(
          label: 'Estado',
          value: estado ?? _todos,
          options: const <String, String>{
            _todos: 'Todos',
            'ACTIVO': 'Activo',
            'SUSPENDIDO': 'Suspendido',
            'FINALIZADO': 'Finalizado',
            'ELIMINADO': 'Eliminado',
          },
          onChanged: (String v) => onEstadoChanged(v == _todos ? null : v),
        ),
      ],
    );
  }
}

/// Barra de estado con el resumen de servicios (antes estadísticas del header)
class ServiciosStatusBar extends StatelessWidget {
  const ServiciosStatusBar({required this.state, super.key});

  final ServiciosState state;

  @override
  Widget build(BuildContext context) {
    final List<String> items = state.maybeWhen(
      loaded: (
        List<ServicioEntity> servicios,
        String searchQuery,
        int? yearFilter,
        String? estadoFilter,
        bool isRefreshing,
        ServicioEntity? selectedServicio,
        bool isLoadingDetails,
      ) {
        int count(String estado) => servicios.where((ServicioEntity s) => s.estado == estado).length;
        return <String>[
          '${servicios.length} servicios',
          'Activos: ${count('ACTIVO')}',
          'Suspendidos: ${count('SUSPENDIDO')}',
          if (selectedServicio?.codigo != null) 'Seleccionado: ${selectedServicio!.codigo}',
        ];
      },
      orElse: () => const <String>['Cargando servicios...'],
    );
    return GestionStatusBar(items: items);
  }
}
