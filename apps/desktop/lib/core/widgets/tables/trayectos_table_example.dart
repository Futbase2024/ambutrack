import 'package:flutter/material.dart';
import 'trayectos_table.dart';

/// Ejemplo de uso del widget TrayectosTable
///
/// Este archivo muestra cómo integrar la tabla de trayectos
/// en diferentes contextos de la aplicación.
class TrayectosTableExample extends StatelessWidget {
  const TrayectosTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final List<TrayectoTableData> trayectos = <TrayectoTableData>[
      TrayectoTableData(
        id: '1',
        fecha: DateTime(2026, 1, 5),
        estado: 'Pendiente',
        tipo: 'VUELTA',
        hora: '10:35',
      ),
      TrayectoTableData(
        id: '2',
        fecha: DateTime(2026, 1, 6),
        estado: 'Pendiente',
        tipo: 'IDA',
        hora: '09:35',
      ),
      TrayectoTableData(
        id: '3',
        fecha: DateTime(2026, 1, 6),
        estado: 'En Curso',
        tipo: 'VUELTA',
        hora: '10:35',
        horaRecogida: '10:32',
        vehiculo: 'AMB-001',
        conductor: 'Juan García',
      ),
      TrayectoTableData(
        id: '4',
        fecha: DateTime(2026, 1, 7),
        estado: 'Completado',
        tipo: 'IDA',
        hora: '09:35',
        horaRecogida: '09:33',
        horaLlegada: '10:15',
        vehiculo: 'AMB-002',
        conductor: 'María López',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo TrayectosTable'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Tabla de Trayectos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Tabla completa con todas las funcionalidades
            Expanded(
              child: TrayectosTable(
                trayectos: trayectos,
                onView: (TrayectoTableData trayecto) {
                  debugPrint('Ver trayecto: ${trayecto.id}');
                  // Navegar a pantalla de detalles
                },
                onEdit: (TrayectoTableData trayecto) {
                  debugPrint('Editar trayecto: ${trayecto.id}');
                  // Mostrar formulario de edición
                },
                onAssign: (TrayectoTableData trayecto) {
                  debugPrint('Asignar recursos a: ${trayecto.id}');
                  // Mostrar diálogo para asignar vehículo y conductor
                },
                onCancel: (TrayectoTableData trayecto) {
                  debugPrint('Cancelar trayecto: ${trayecto.id}');
                  // Mostrar confirmación de cancelación
                },
                onDelete: (TrayectoTableData trayecto) {
                  debugPrint('Eliminar trayecto: ${trayecto.id}');
                  // Mostrar confirmación de eliminación
                },
                onSelectionChanged: (List<TrayectoTableData> selected) {
                  debugPrint('${selected.length} trayectos seleccionados');
                },
              ),
            ),

            const SizedBox(height: 16),

            // Ejemplo con tabla vacía
            // TrayectosTable(
            //   trayectos: const <TrayectoTableData>[],
            //   emptyMessage: 'No hay trayectos programados para este servicio',
            // ),

            // Ejemplo sin acciones
            // TrayectosTable(
            //   trayectos: trayectos,
            //   sortable: false,
            //   selectable: false,
            // ),
          ],
        ),
      ),
    );
  }
}

/// Ejemplo de integración en un BlocBuilder
///
/// ```dart
/// BlocBuilder<TrayectosBloc, TrayectosState>(
///   builder: (context, state) {
///     return state.when(
///       initial: () => const CircularProgressIndicator(),
///       loading: () => const CircularProgressIndicator(),
///       loaded: (trayectos) => TrayectosTable(
///         trayectos: trayectos.map((t) => TrayectoTableData(
///           id: t.id,
///           fecha: t.fecha,
///           estado: t.estado,
///           tipo: t.tipo,
///           hora: t.hora,
///           horaRecogida: t.horaRecogida,
///           horaLlegada: t.horaLlegada,
///           vehiculo: t.vehiculo?.matricula,
///           conductor: t.conductor?.nombre,
///         )).toList(),
///         onEdit: (trayecto) => context.read<TrayectosBloc>().add(
///           TrayectosEvent.editRequested(trayecto.id),
///         ),
///         onDelete: (trayecto) => context.read<TrayectosBloc>().add(
///           TrayectosEvent.deleteRequested(trayecto.id),
///         ),
///       ),
///       error: (message) => Text('Error: $message'),
///     );
///   },
/// )
/// ```
