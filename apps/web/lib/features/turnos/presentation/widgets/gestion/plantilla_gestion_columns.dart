import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Filtro por estado de la plantilla
enum PlantillaEstadoFiltro { todos, activas, inactivas }

/// Convierte un color "#RRGGBB" (dato de la plantilla) en [Color]
Color plantillaHexColor(String hex) {
  final int? value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? AppColors.gray400 : Color(value | 0xFF000000);
}

/// Duración legible: "1 día" / "3 días"
String plantillaDuracion(PlantillaTurnoEntity p) =>
    p.duracionDias == 1 ? '1 día' : '${p.duracionDias} días';

/// Horario "07:00 - 15:00"
String plantillaHorario(PlantillaTurnoEntity p) => '${p.horaInicio} - ${p.horaFin}';

/// Indicador de estado activa/inactiva
class PlantillaEstadoDot extends StatelessWidget {
  const PlantillaEstadoDot({required this.activo, super.key});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: activo ? 'Activa' : 'Inactiva',
      color: activo ? AppColors.success : AppColors.inactive,
    );
  }
}

/// Muestra del color de la plantilla con su código
class PlantillaColorSwatch extends StatelessWidget {
  const PlantillaColorSwatch({required this.hex, super.key});

  final String hex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: plantillaHexColor(hex),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.gray300),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          hex.toUpperCase(),
          style: const TextStyle(fontSize: 12, color: AppColors.gray600, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class PlantillaCellText extends StatelessWidget {
  const PlantillaCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de plantillas de turnos
final List<GestionColumn<PlantillaTurnoEntity>> plantillaGestionColumns =
    <GestionColumn<PlantillaTurnoEntity>>[
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Nombre',
    flex: 3,
    sortValue: (PlantillaTurnoEntity p) => p.nombre.toLowerCase(),
    cell: (PlantillaTurnoEntity p) => PlantillaCellText(p.nombre, bold: true),
  ),
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Descripción',
    flex: 3,
    sortValue: (PlantillaTurnoEntity p) => (p.descripcion ?? '').toLowerCase(),
    cell: (PlantillaTurnoEntity p) => PlantillaCellText(GestionFormatters.texto(p.descripcion)),
  ),
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Tipo',
    width: 130,
    sortValue: (PlantillaTurnoEntity p) => p.tipoTurno.nombre,
    cell: (PlantillaTurnoEntity p) => GestionDotLabel(
      label: p.tipoTurno.nombre,
      color: plantillaHexColor(p.tipoTurno.colorHex),
    ),
  ),
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Horario',
    width: 120,
    sortValue: (PlantillaTurnoEntity p) => p.horaInicio,
    cell: (PlantillaTurnoEntity p) => PlantillaCellText(plantillaHorario(p)),
  ),
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Duración',
    width: 90,
    sortValue: (PlantillaTurnoEntity p) => p.duracionDias,
    cell: (PlantillaTurnoEntity p) => PlantillaCellText(plantillaDuracion(p)),
  ),
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Color',
    width: 110,
    cell: (PlantillaTurnoEntity p) => PlantillaColorSwatch(hex: p.getColorHex()),
  ),
  GestionColumn<PlantillaTurnoEntity>(
    label: 'Estado',
    width: 100,
    sortValue: (PlantillaTurnoEntity p) => p.activo ? 0 : 1,
    cell: (PlantillaTurnoEntity p) => PlantillaEstadoDot(activo: p.activo),
  ),
];

/// Filtra plantillas por texto (nombre, tipo, descripción), tipo y estado
List<PlantillaTurnoEntity> filtrarPlantillas(
  List<PlantillaTurnoEntity> plantillas, {
  required String query,
  required TipoTurno? tipo,
  required PlantillaEstadoFiltro estado,
}) {
  final String q = query.trim().toLowerCase();
  return plantillas.where((PlantillaTurnoEntity p) {
    final bool matchesSearch = q.isEmpty ||
        p.nombre.toLowerCase().contains(q) ||
        p.tipoTurno.nombre.toLowerCase().contains(q) ||
        (p.descripcion?.toLowerCase().contains(q) ?? false);
    final bool matchesTipo = tipo == null || p.tipoTurno == tipo;
    final bool matchesEstado = estado == PlantillaEstadoFiltro.todos ||
        (estado == PlantillaEstadoFiltro.activas ? p.activo : !p.activo);
    return matchesSearch && matchesTipo && matchesEstado;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenPlantillas(List<PlantillaTurnoEntity> todas, int filtradas) {
  int count(TipoTurno t) => todas.where((PlantillaTurnoEntity p) => p.tipoTurno == t).length;
  final int activas = todas.where((PlantillaTurnoEntity p) => p.activo).length;
  return <String>[
    if (filtradas == todas.length) '${todas.length} registros' else '$filtradas de ${todas.length} registros',
    '$activas activas',
    for (final TipoTurno t in TipoTurno.values) '${t.nombre} ${count(t)}',
  ];
}

/// Imprime el listado de plantillas (filtrado y ordenado)
Future<void> imprimirPlantillas(List<PlantillaTurnoEntity> plantillas) {
  return GestionPrint.listado(
    title: 'Plantillas de Turnos',
    headers: const <String>['Nombre', 'Descripción', 'Tipo', 'Horario', 'Duración', 'Color', 'Estado'],
    rows: plantillas
        .map(
          (PlantillaTurnoEntity p) => <String>[
            p.nombre,
            GestionFormatters.texto(p.descripcion),
            p.tipoTurno.nombre,
            plantillaHorario(p),
            plantillaDuracion(p),
            p.getColorHex().toUpperCase(),
            if (p.activo) 'Activa' else 'Inactiva',
          ],
        )
        .toList(),
  );
}
