import 'package:ambutrack_desktop/core/widgets/context_menu/custom_context_menu.dart';
import 'package:flutter/material.dart';

/// Ejemplo de uso del menú contextual personalizado
///
/// Este ejemplo muestra cómo envolver cualquier widget para añadir
/// un menú contextual personalizado al hacer clic derecho.
class ContextMenuExample extends StatelessWidget {
  const ContextMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContextMenu(
      // Opciones del menú contextual
      menuOptions: <ContextMenuOption>[
        ContextMenuOption(
          label: 'Editar',
          icon: Icons.edit,
          onTap: () {
            debugPrint('Editar seleccionado');
            // Acción de editar
          },
        ),
        ContextMenuOption(
          label: 'Duplicar',
          icon: Icons.content_copy,
          onTap: () {
            debugPrint('Duplicar seleccionado');
            // Acción de duplicar
          },
        ),
        ContextMenuOption(
          label: 'Eliminar',
          icon: Icons.delete,
          onTap: () {
            debugPrint('Eliminar seleccionado');
            // Acción de eliminar
          },
        ),
        ContextMenuOption(
          label: 'Opción deshabilitada',
          icon: Icons.block,
          onTap: () {},
          enabled: false, // Esta opción aparece pero no se puede seleccionar
        ),
      ],

      // Widget que tendrá el menú contextual
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue[100],
        child: const Center(
          child: Text(
            'Haz clic derecho aquí para ver el menú contextual',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

/// Ejemplo de uso en una tabla
class TableContextMenuExample extends StatelessWidget {
  const TableContextMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return CustomContextMenu(
          menuOptions: <ContextMenuOption>[
            ContextMenuOption(
              label: 'Ver detalles',
              icon: Icons.visibility,
              onTap: () => _showDetails(context, index),
            ),
            ContextMenuOption(
              label: 'Editar fila $index',
              icon: Icons.edit,
              onTap: () => _editRow(context, index),
            ),
            ContextMenuOption(
              label: 'Eliminar fila $index',
              icon: Icons.delete,
              onTap: () => _deleteRow(context, index),
            ),
          ],
          child: ListTile(
            title: Text('Fila $index'),
            subtitle: const Text('Haz clic derecho para ver opciones'),
            leading: CircleAvatar(child: Text('$index')),
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mostrando detalles de fila $index')),
    );
  }

  void _editRow(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando fila $index')),
    );
  }

  void _deleteRow(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Eliminando fila $index')),
    );
  }
}
