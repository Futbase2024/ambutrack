import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/domain/entities/categoria_servicio.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:flutter/material.dart';

/// Filtro por estado del empleado
enum PersonalEstadoFiltro { todos, activos, inactivos }

/// Color asociado a la categoría profesional
Color personalCategoriaColor(String? categoria) {
  switch ((categoria ?? '').toLowerCase()) {
    case 'médico':
    case 'medico':
      return AppColors.primary;
    case 'enfermero':
    case 'enfermera':
      return AppColors.success;
    case 'técnico':
    case 'tecnico':
    case 'técnico sanitario':
    case 'tecnico sanitario':
    case 'tes':
      return AppColors.info;
    case 'conductor':
    case 'conductora':
      return AppColors.warning;
    case 'administrativo':
    case 'administrativa':
      return AppColors.secondary;
    default:
      return AppColors.gray400;
  }
}

/// Teléfono principal (móvil o fijo)
String? personalTelefono(PersonalEntity p) =>
    (p.movil?.trim().isNotEmpty ?? false) ? p.movil : p.telefono;

/// Indicador de categoría profesional
class PersonalCategoriaDot extends StatelessWidget {
  const PersonalCategoriaDot({required this.categoria, super.key});

  final String? categoria;

  @override
  Widget build(BuildContext context) {
    if (categoria == null || categoria!.trim().isEmpty) {
      return const GestionCellText(GestionFormatters.vacio);
    }
    return GestionDotLabel(label: categoria!, color: personalCategoriaColor(categoria));
  }
}

/// Indicador de categoría de servicio (urgencias / programado)
class PersonalServicioDot extends StatelessWidget {
  const PersonalServicioDot({required this.servicio, super.key});

  final CategoriaServicio servicio;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: servicio.nombre,
      color: servicio == CategoriaServicio.urgencias ? AppColors.emergency : AppColors.info,
    );
  }
}

/// Indicador de estado activo/inactivo del empleado
class PersonalEstadoDot extends StatelessWidget {
  const PersonalEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return CatalogoEstadoDot(activo: activo);
  }
}

/// Columnas de la rejilla de personal
final List<GestionColumn<PersonalEntity>> personalGestionColumns = <GestionColumn<PersonalEntity>>[
  GestionColumn<PersonalEntity>(
    label: 'Personal',
    flex: 4,
    sortValue: (PersonalEntity p) => p.nombreCompleto.toLowerCase(),
    cell: (PersonalEntity p) => GestionCellText(p.nombreCompleto, bold: true),
  ),
  GestionColumn<PersonalEntity>(
    label: 'DNI',
    width: 110,
    sortValue: (PersonalEntity p) => (p.dni ?? '').toLowerCase(),
    cell: (PersonalEntity p) => GestionCellText(GestionFormatters.texto(p.dni)),
  ),
  GestionColumn<PersonalEntity>(
    label: 'Categoría',
    flex: 2,
    sortValue: (PersonalEntity p) => (p.categoria ?? '').toLowerCase(),
    cell: (PersonalEntity p) => PersonalCategoriaDot(categoria: p.categoria),
  ),
  GestionColumn<PersonalEntity>(
    label: 'Servicio',
    width: 120,
    sortValue: (PersonalEntity p) => p.categoriaServicio.nombre,
    cell: (PersonalEntity p) => PersonalServicioDot(servicio: p.categoriaServicio),
  ),
  GestionColumn<PersonalEntity>(
    label: 'Teléfono',
    width: 120,
    cell: (PersonalEntity p) => GestionCellText(GestionFormatters.telefono(personalTelefono(p))),
  ),
  GestionColumn<PersonalEntity>(
    label: 'Email',
    flex: 3,
    sortValue: (PersonalEntity p) => (p.email ?? '').toLowerCase(),
    cell: (PersonalEntity p) => GestionCellText(GestionFormatters.texto(p.email)),
  ),
  GestionColumn<PersonalEntity>(
    label: 'Fecha alta',
    width: 110,
    sortValue: (PersonalEntity p) => p.fechaAlta ?? DateTime(9999),
    cell: (PersonalEntity p) => GestionCellText(GestionFormatters.fecha(p.fechaAlta)),
  ),
  GestionColumn<PersonalEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (PersonalEntity p) => p.activo ? 0 : 1,
    cell: (PersonalEntity p) => PersonalEstadoDot(activo: p.activo),
  ),
];

/// Filtra el personal por texto (nombre, apellidos, DNI, teléfono, email), categoría y estado
List<PersonalEntity> filtrarPersonal(
  List<PersonalEntity> personal, {
  required String query,
  required String? categoriaId,
  required PersonalEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  final String qDigits = q.replaceAll(RegExp(r'\D'), '');
  bool phone(String? v) => qDigits.isNotEmpty && (v?.replaceAll(RegExp(r'\D'), '').contains(qDigits) ?? false);
  return personal.where((PersonalEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.nombreCompleto.toLowerCase().contains(q) ||
        (p.dni?.toLowerCase().contains(q) ?? false) ||
        (p.email?.toLowerCase().contains(q) ?? false) ||
        phone(p.telefono) ||
        phone(p.movil);
    final bool matchesCategoria = categoriaId == null || p.categoriaId == categoriaId;
    final bool matchesEstado = estado == PersonalEstadoFiltro.todos ||
        (estado == PersonalEstadoFiltro.activos ? p.activo : !p.activo);
    return matchesSearch && matchesCategoria && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenPersonal(List<PersonalEntity> todos, int filtrados) {
  final int activos = todos.where((PersonalEntity p) => p.activo).length;
  final int urgencias =
      todos.where((PersonalEntity p) => p.categoriaServicio == CategoriaServicio.urgencias).length;
  return <String>[
    gestionResumenRegistros(todos.length, filtrados),
    '$activos activos',
    '${todos.length - activos} inactivos',
    'Urgencias $urgencias',
    'Programado ${todos.length - urgencias}',
  ];
}

/// Imprime el listado de personal (filtrado y ordenado)
Future<void> imprimirPersonal(List<PersonalEntity> personal) {
  return GestionPrint.listado(
    title: 'Personal',
    headers: const <String>[
      'Apellidos', 'Nombre', 'DNI', 'Categoría', 'Servicio', 'Teléfono', 'Email', 'Fecha alta', 'Estado',
    ],
    rows: personal
        .map(
          (PersonalEntity p) => <String>[
            p.apellidos,
            p.nombre,
            GestionFormatters.texto(p.dni),
            GestionFormatters.texto(p.categoria),
            p.categoriaServicio.nombre,
            GestionFormatters.telefono(personalTelefono(p)),
            GestionFormatters.texto(p.email),
            GestionFormatters.fecha(p.fechaAlta),
            if (p.activo) 'Activo' else 'Inactivo',
          ],
        )
        .toList(),
  );
}
