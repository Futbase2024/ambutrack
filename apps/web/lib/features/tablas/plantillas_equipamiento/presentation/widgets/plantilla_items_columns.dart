import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:flutter/material.dart';

/// Filtro de estado de los items
enum ItemEstadoFiltro {
  activos('Activos'),
  inactivos('Inactivos'),
  todos('Todos');

  const ItemEstadoFiltro(this.label);

  final String label;
}

/// Etiqueta del tipo de item
String itemTipoLabel(PlantillaEquipamientoItemEntity i) => i.esDocumento ? 'Documento' : 'Material';

/// Icono de "sí" para columnas booleanas (vacío si no)
class _Check extends StatelessWidget {
  const _Check({required this.value, required this.icon});

  final bool value;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      value ? Icon(icon, size: 16, color: AppColors.primary) : const SizedBox.shrink();
}

/// Activo / Inactivo
class ItemEstadoDot extends StatelessWidget {
  const ItemEstadoDot({required this.item, super.key});

  final PlantillaEquipamientoItemEntity item;

  @override
  Widget build(BuildContext context) => GestionDotLabel(
        label: item.activo ? 'Activo' : 'Inactivo',
        color: item.activo ? AppColors.success : AppColors.gray500,
      );
}

String _ordenKey(PlantillaEquipamientoItemEntity i) =>
    '${i.seccionOrden.toString().padLeft(3, '0')}${i.orden.toString().padLeft(4, '0')}';

/// Columnas de la rejilla de items de una plantilla
final List<GestionColumn<PlantillaEquipamientoItemEntity>> plantillaItemsColumns =
    <GestionColumn<PlantillaEquipamientoItemEntity>>[
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Sección',
    flex: 2,
    sortValue: _ordenKey,
    cell: (PlantillaEquipamientoItemEntity i) => FlotaCellText(i.seccion),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Item',
    flex: 3,
    sortValue: (PlantillaEquipamientoItemEntity i) => (i.productoNombre ?? '').toLowerCase(),
    cell: (PlantillaEquipamientoItemEntity i) => FlotaCellText(
      GestionFormatters.texto(i.productoNombre),
      bold: i.activo,
      color: i.activo ? null : AppColors.gray400,
    ),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Tipo',
    width: 96,
    sortValue: itemTipoLabel,
    cell: (PlantillaEquipamientoItemEntity i) => FlotaCellText(itemTipoLabel(i)),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Cant.',
    width: 60,
    alignment: Alignment.centerRight,
    sortValue: (PlantillaEquipamientoItemEntity i) => i.cantidadRequerida,
    cell: (PlantillaEquipamientoItemEntity i) => FlotaCellText('${i.cantidadRequerida}', bold: true),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Requisito',
    width: 96,
    sortValue: (PlantillaEquipamientoItemEntity i) => i.obligatorio ? 0 : 1,
    cell: (PlantillaEquipamientoItemEntity i) => FlotaCellText(
      i.obligatorio ? 'Obligatorio' : 'Opcional',
      color: i.obligatorio ? null : AppColors.gray500,
    ),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Cad.',
    width: 52,
    alignment: Alignment.center,
    sortValue: (PlantillaEquipamientoItemEntity i) => i.requiereCaducidad ? 0 : 1,
    cell: (PlantillaEquipamientoItemEntity i) => _Check(value: i.requiereCaducidad, icon: Icons.event),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Adj.',
    width: 52,
    alignment: Alignment.center,
    sortValue: (PlantillaEquipamientoItemEntity i) => i.requiereAdjunto ? 0 : 1,
    cell: (PlantillaEquipamientoItemEntity i) => _Check(value: i.requiereAdjunto, icon: Icons.attach_file),
  ),
  GestionColumn<PlantillaEquipamientoItemEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (PlantillaEquipamientoItemEntity i) => i.activo ? 0 : 1,
    cell: (PlantillaEquipamientoItemEntity i) => ItemEstadoDot(item: i),
  ),
];

/// Filtra por texto, sección, tipo y estado
List<PlantillaEquipamientoItemEntity> filtrarItems(
  List<PlantillaEquipamientoItemEntity> items, {
  required String query,
  required String? seccion,
  required TipoItemEquipamiento? tipo,
  required ItemEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return items.where((PlantillaEquipamientoItemEntity i) {
    final bool texto = q.isEmpty ||
        (i.productoNombre?.toLowerCase().contains(q) ?? false) ||
        (i.productoCodigo?.toLowerCase().contains(q) ?? false) ||
        (i.notas?.toLowerCase().contains(q) ?? false);
    final bool porEstado = switch (estado) {
      ItemEstadoFiltro.activos => i.activo,
      ItemEstadoFiltro.inactivos => !i.activo,
      ItemEstadoFiltro.todos => true,
    };
    return texto && porEstado && (seccion == null || i.seccion == seccion) && (tipo == null || i.tipoItem == tipo);
  }).toList();
}

/// Secciones de la plantilla en orden (nombre → orden)
Map<String, int> seccionesPlantilla(List<PlantillaEquipamientoItemEntity> items) {
  final List<PlantillaEquipamientoItemEntity> ordenados = List<PlantillaEquipamientoItemEntity>.of(items)
    ..sort((PlantillaEquipamientoItemEntity a, PlantillaEquipamientoItemEntity b) =>
        a.seccionOrden.compareTo(b.seccionOrden));
  return <String, int>{for (final PlantillaEquipamientoItemEntity i in ordenados) i.seccion: i.seccionOrden};
}

/// Resumen para la barra de estado
List<String> resumenItems(List<PlantillaEquipamientoItemEntity> todos, int filtrados) {
  final List<PlantillaEquipamientoItemEntity> activos =
      todos.where((PlantillaEquipamientoItemEntity i) => i.activo).toList();
  return <String>[
    flotaResumenRegistros(todos.length, filtrados),
    'Activos ${activos.length}',
    'Material ${activos.where((PlantillaEquipamientoItemEntity i) => !i.esDocumento).length}',
    'Documentos ${activos.where((PlantillaEquipamientoItemEntity i) => i.esDocumento).length}',
  ];
}

/// Imprime los items filtrados de la plantilla
Future<void> imprimirItems(List<PlantillaEquipamientoItemEntity> items, String titulo) {
  return GestionPrint.listado(
    title: titulo,
    headers: const <String>['Sección', 'Item', 'Tipo', 'Cant.', 'Requisito', 'Caducidad', 'Adjunto', 'Notas'],
    rows: items
        .map(
          (PlantillaEquipamientoItemEntity i) => <String>[
            i.seccion,
            GestionFormatters.texto(i.productoNombre),
            itemTipoLabel(i),
            '${i.cantidadRequerida}',
            _requisito(i),
            _siNo(value: i.requiereCaducidad),
            _siNo(value: i.requiereAdjunto),
            GestionFormatters.texto(i.notas),
          ],
        )
        .toList(),
  );
}

String _requisito(PlantillaEquipamientoItemEntity i) => i.obligatorio ? 'Obligatorio' : 'Opcional';

String _siNo({required bool value}) => value ? 'Sí' : 'No';
