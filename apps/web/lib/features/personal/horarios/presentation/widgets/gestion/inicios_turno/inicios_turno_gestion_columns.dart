import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Filtro rápido por estado de validación
enum InicioTurnoFiltro { pendientes, todos }

bool esPendiente(InicioTurnoEntity i) => i.estadoValidacion == EstadoValidacionInicio.pendiente;

/// Fecha/hora del inicio (created_at)
String inicioFechaHora(InicioTurnoEntity i) =>
    i.createdAt == null ? GestionFormatters.vacio : fichajeFechaHora(i.createdAt!);

String inicioKm(int? km) => km == null ? GestionFormatters.vacio : '$km km';

String inicioDistancia(int? metros) {
  if (metros == null) {
    return GestionFormatters.vacio;
  }
  return metros >= 1000 ? '${(metros / 1000).toStringAsFixed(1)} km' : '$metros m';
}

/// Color del estado de validación
Color estadoValidacionColor(EstadoValidacionInicio e) {
  switch (e) {
    case EstadoValidacionInicio.pendiente:
      return AppColors.warning;
    case EstadoValidacionInicio.aprobado:
      return AppColors.success;
    case EstadoValidacionInicio.rechazado:
      return AppColors.error;
    case EstadoValidacionInicio.noRequiere:
      return AppColors.gray500;
  }
}

/// Badge ajustado al ancho del texto
class InicioTurnoBadge extends StatelessWidget {
  const InicioTurnoBadge({required this.label, required this.color, this.inCell = true, super.key});

  final String label;
  final Color color;

  /// En celdas de tabla se alinea a la izquierda (Align + IntrinsicWidth);
  /// fuera de ellas (cabecera de la ficha, Wrap) solo se ajusta al texto.
  final bool inCell;

  @override
  Widget build(BuildContext context) {
    final Widget badge = IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
    return inCell ? Align(alignment: Alignment.centerLeft, child: badge) : badge;
  }
}

/// Badge del estado de validación
class InicioEstadoBadge extends StatelessWidget {
  const InicioEstadoBadge({required this.estado, this.inCell = true, super.key});

  final EstadoValidacionInicio estado;
  final bool inCell;

  @override
  Widget build(BuildContext context) {
    return InicioTurnoBadge(label: estado.label, color: estadoValidacionColor(estado), inCell: inCell);
  }
}

/// Badge "Fuera de base" / "En base"
class InicioFueraBaseBadge extends StatelessWidget {
  const InicioFueraBaseBadge({required this.fueraDeBase, this.inCell = true, super.key});

  final bool fueraDeBase;
  final bool inCell;

  @override
  Widget build(BuildContext context) {
    return fueraDeBase
        ? InicioTurnoBadge(label: 'Fuera de base', color: AppColors.warning, inCell: inCell)
        : InicioTurnoBadge(label: 'En base', color: AppColors.success, inCell: inCell);
  }
}

/// Columnas de la rejilla de inicios de turno
final List<GestionColumn<InicioTurnoEntity>> iniciosTurnoColumns = <GestionColumn<InicioTurnoEntity>>[
  GestionColumn<InicioTurnoEntity>(
    label: 'Fecha/Hora',
    width: 140,
    sortValue: (InicioTurnoEntity i) => i.createdAt ?? DateTime(2000),
    cell: (InicioTurnoEntity i) => FichajeCellText(inicioFechaHora(i)),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Técnico',
    flex: 3,
    sortValue: (InicioTurnoEntity i) => (i.personalNombre ?? '').toLowerCase(),
    cell: (InicioTurnoEntity i) => FichajeCellText(GestionFormatters.texto(i.personalNombre), bold: true),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Vehículo',
    width: 110,
    filterValue: (InicioTurnoEntity i) => i.vehiculoMatricula ?? '',
    sortValue: (InicioTurnoEntity i) => (i.vehiculoMatricula ?? '').toLowerCase(),
    cell: (InicioTurnoEntity i) => FichajeCellText(GestionFormatters.texto(i.vehiculoMatricula)),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Rol',
    width: 130,
    filterValue: (InicioTurnoEntity i) => i.rol?.label ?? '',
    sortValue: (InicioTurnoEntity i) => i.rol?.label ?? '',
    cell: (InicioTurnoEntity i) => FichajeCellText(GestionFormatters.texto(i.rol?.label)),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Km',
    width: 100,
    sortValue: (InicioTurnoEntity i) => i.kmInicial ?? -1,
    cell: (InicioTurnoEntity i) => FichajeCellText(inicioKm(i.kmInicial)),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Combustible',
    width: 105,
    filterValue: (InicioTurnoEntity i) => i.combustible?.label ?? '',
    sortValue: (InicioTurnoEntity i) => i.combustible?.index ?? -1,
    cell: (InicioTurnoEntity i) => FichajeCellText(GestionFormatters.texto(i.combustible?.label)),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Ubicación',
    width: 125,
    filterValue: (InicioTurnoEntity i) => i.fueraDeBase ? 'Fuera de base' : 'En base',
    sortValue: (InicioTurnoEntity i) => i.fueraDeBase ? 1 : 0,
    cell: (InicioTurnoEntity i) => InicioFueraBaseBadge(fueraDeBase: i.fueraDeBase),
  ),
  GestionColumn<InicioTurnoEntity>(
    label: 'Validación',
    width: 120,
    filterValue: (InicioTurnoEntity i) => i.estadoValidacion.label,
    sortValue: (InicioTurnoEntity i) => i.estadoValidacion.index,
    cell: (InicioTurnoEntity i) => InicioEstadoBadge(estado: i.estadoValidacion),
  ),
];

/// Filtra por texto (técnico, matrícula, compañero) y por estado rápido
List<InicioTurnoEntity> filtrarIniciosTurno(
  List<InicioTurnoEntity> inicios, {
  required String query,
  required InicioTurnoFiltro filtro,
}) {
  final String q = query.trim().toLowerCase();
  return inicios.where((InicioTurnoEntity i) {
    final bool matchesSearch =
        q.isEmpty ||
        <String?>[
          i.personalNombre,
          i.vehiculoMatricula,
          i.companeroNombre,
        ].any((String? v) => v?.toLowerCase().contains(q) ?? false);
    final bool matchesFiltro = filtro == InicioTurnoFiltro.todos || esPendiente(i);
    return matchesSearch && matchesFiltro;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenIniciosTurno(List<InicioTurnoEntity> todos, int filtrados) {
  final int pendientes = todos.where(esPendiente).length;
  final int fuera = todos.where((InicioTurnoEntity i) => i.fueraDeBase).length;
  return <String>[
    if (filtrados == todos.length) '${todos.length} inicios' else '$filtrados de ${todos.length} inicios',
    'Pendientes $pendientes',
    'Fuera de base $fuera',
    'Últimos 30 días',
  ];
}

/// Imprime el listado de inicios de turno (filtrado y ordenado)
Future<void> imprimirIniciosTurno(List<InicioTurnoEntity> inicios) {
  return GestionPrint.listado(
    title: 'Inicios de turno',
    headers: const <String>['Fecha/Hora', 'Técnico', 'Vehículo', 'Rol', 'Km', 'Combustible', 'Ubicación', 'Validación'],
    rows: inicios
        .map(
          (InicioTurnoEntity i) => <String>[
            inicioFechaHora(i),
            GestionFormatters.texto(i.personalNombre),
            GestionFormatters.texto(i.vehiculoMatricula),
            GestionFormatters.texto(i.rol?.label),
            inicioKm(i.kmInicial),
            GestionFormatters.texto(i.combustible?.label),
            if (i.fueraDeBase) 'Fuera de base' else 'En base',
            i.estadoValidacion.label,
          ],
        )
        .toList(),
  );
}
