import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la empresa
enum EmpresaEstadoFiltro { todas, activas, inactivas }

/// Fila de la rejilla: empresa + nº de usuarios asignados
class EmpresaRow {
  const EmpresaRow({required this.empresa, required this.usuarios});

  final EmpresaTenantEntity empresa;
  final int usuarios;
}

/// Indicador de estado activa/inactiva
class EmpresaEstadoDot extends StatelessWidget {
  const EmpresaEstadoDot({required this.activa, super.key});

  final bool activa;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activa ? 'Activa' : 'Inactiva',
      color: activa ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Columnas de la rejilla de empresas
final List<GestionColumn<EmpresaRow>> multicentroColumns = <GestionColumn<EmpresaRow>>[
  GestionColumn<EmpresaRow>(
    label: 'Nombre',
    flex: 3,
    sortValue: (EmpresaRow r) => r.empresa.nombre.toLowerCase(),
    cell: (EmpresaRow r) => AdminCellText(r.empresa.nombre, bold: true),
  ),
  GestionColumn<EmpresaRow>(
    label: 'CIF',
    width: 120,
    sortValue: (EmpresaRow r) => (r.empresa.cif ?? '').toLowerCase(),
    cell: (EmpresaRow r) => AdminCellText(GestionFormatters.texto(r.empresa.cif)),
  ),
  GestionColumn<EmpresaRow>(
    label: 'Razón social',
    flex: 3,
    sortValue: (EmpresaRow r) => (r.empresa.razonSocial ?? '').toLowerCase(),
    cell: (EmpresaRow r) => AdminCellText(GestionFormatters.texto(r.empresa.razonSocial)),
  ),
  GestionColumn<EmpresaRow>(
    label: 'Teléfono',
    width: 130,
    cell: (EmpresaRow r) => AdminCellText(GestionFormatters.telefono(r.empresa.telefono)),
  ),
  GestionColumn<EmpresaRow>(
    label: 'Email',
    flex: 2,
    sortValue: (EmpresaRow r) => (r.empresa.email ?? '').toLowerCase(),
    cell: (EmpresaRow r) => AdminCellText(GestionFormatters.texto(r.empresa.email)),
  ),
  GestionColumn<EmpresaRow>(
    label: 'Usuarios',
    width: 90,
    alignment: Alignment.centerRight,
    sortValue: (EmpresaRow r) => r.usuarios,
    cell: (EmpresaRow r) => AdminCellText('${r.usuarios}'),
  ),
  GestionColumn<EmpresaRow>(
    label: 'Estado',
    width: 100,
    sortValue: (EmpresaRow r) => r.empresa.activo ? 0 : 1,
    cell: (EmpresaRow r) => EmpresaEstadoDot(activa: r.empresa.activo),
  ),
];

/// Aplica búsqueda y filtro de estado
List<EmpresaRow> filtrarEmpresas(
  List<EmpresaRow> rows, {
  required String query,
  required EmpresaEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return rows.where((EmpresaRow r) {
    final EmpresaTenantEntity e = r.empresa;
    final bool matchesEstado = estado == EmpresaEstadoFiltro.todas ||
        (estado == EmpresaEstadoFiltro.activas && e.activo) ||
        (estado == EmpresaEstadoFiltro.inactivas && !e.activo);
    if (!matchesEstado) {
      return false;
    }
    if (q.isEmpty) {
      return true;
    }
    return <String?>[e.nombre, e.cif, e.razonSocial, e.email, e.telefono]
        .any((String? v) => v != null && v.toLowerCase().contains(q));
  }).toList();
}

/// Barra de filtros de empresas
class MulticentroFilters extends StatelessWidget {
  const MulticentroFilters({
    required this.searchController,
    required this.onSearchChanged,
    required this.estado,
    required this.onEstadoChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final EmpresaEstadoFiltro estado;
  final ValueChanged<EmpresaEstadoFiltro> onEstadoChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestionFilterBar(
      children: <Widget>[
        GestionSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hint: 'Buscar por nombre, CIF, email...',
        ),
        GestionFilterDropdown<EmpresaEstadoFiltro>(
          label: 'Estado',
          value: estado,
          options: const <EmpresaEstadoFiltro, String>{
            EmpresaEstadoFiltro.todas: 'Todas',
            EmpresaEstadoFiltro.activas: 'Activas',
            EmpresaEstadoFiltro.inactivas: 'Inactivas',
          },
          onChanged: onEstadoChanged,
        ),
        GestionClearFiltersButton(onPressed: onClear),
      ],
    );
  }
}
