import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Filtro por tipo de fichaje
enum FichajeTipoFiltro { todos, entradas, salidas }

final DateFormat _hora = DateFormat('HH:mm');

/// Formatea fecha y hora como "28/10/2026 08:15"
String fichajeFechaHora(DateTime value) =>
    '${GestionFormatters.fecha(value)} ${_hora.format(value.toLocal())}';

/// Formatea solo la hora "08:15"
String fichajeHora(DateTime value) => _hora.format(value.toLocal());

bool esEntrada(RegistroHorarioEntity r) => r.tipo.toLowerCase() == 'entrada';

/// Color asociado al tipo de fichaje
Color fichajeTipoColor(RegistroHorarioEntity r) => esEntrada(r) ? AppColors.success : AppColors.error;

/// Indicador Entrada / Salida
class FichajeTipoDot extends StatelessWidget {
  const FichajeTipoDot({required this.registro, super.key});

  final RegistroHorarioEntity registro;

  @override
  Widget build(BuildContext context) {
    return GestionDotLabel(
      label: esEntrada(registro) ? 'Entrada' : 'Salida',
      color: fichajeTipoColor(registro),
    );
  }
}

/// Precisión GPS con punto verde (≤ 20 m) o naranja
class FichajePrecisionDot extends StatelessWidget {
  const FichajePrecisionDot({required this.precision, super.key});

  final double? precision;

  @override
  Widget build(BuildContext context) {
    final double? p = precision;
    if (p == null) {
      return const FichajeCellText(GestionFormatters.vacio);
    }
    return GestionDotLabel(
      label: '${p.toStringAsFixed(0)} m',
      color: p <= 20 ? AppColors.success : AppColors.warning,
    );
  }
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class FichajeCellText extends StatelessWidget {
  const FichajeCellText(this.value, {this.bold = false, super.key});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : null,
      ),
    );
  }
}

/// Columnas de la rejilla de fichajes
final List<GestionColumn<RegistroHorarioEntity>> fichajesColumns =
    <GestionColumn<RegistroHorarioEntity>>[
  GestionColumn<RegistroHorarioEntity>(
    label: 'Personal',
    flex: 3,
    sortValue: (RegistroHorarioEntity r) => (r.nombrePersonal ?? '').toLowerCase(),
    cell: (RegistroHorarioEntity r) =>
        FichajeCellText(GestionFormatters.texto(r.nombrePersonal), bold: true),
  ),
  GestionColumn<RegistroHorarioEntity>(
    label: 'Tipo',
    width: 100,
    sortValue: (RegistroHorarioEntity r) => r.tipo.toLowerCase(),
    cell: (RegistroHorarioEntity r) => FichajeTipoDot(registro: r),
  ),
  GestionColumn<RegistroHorarioEntity>(
    label: 'Fecha/Hora',
    width: 140,
    sortValue: (RegistroHorarioEntity r) => r.fechaHora,
    cell: (RegistroHorarioEntity r) => FichajeCellText(fichajeFechaHora(r.fechaHora)),
  ),
  GestionColumn<RegistroHorarioEntity>(
    label: 'Ubicación',
    flex: 3,
    sortValue: (RegistroHorarioEntity r) => (r.ubicacion ?? '').toLowerCase(),
    cell: (RegistroHorarioEntity r) => FichajeCellText(GestionFormatters.texto(r.ubicacion)),
  ),
  GestionColumn<RegistroHorarioEntity>(
    label: 'Vehículo',
    width: 110,
    sortValue: (RegistroHorarioEntity r) => (r.vehiculoMatricula ?? '').toLowerCase(),
    cell: (RegistroHorarioEntity r) =>
        FichajeCellText(GestionFormatters.texto(r.vehiculoMatricula)),
  ),
  GestionColumn<RegistroHorarioEntity>(
    label: 'Precisión GPS',
    width: 120,
    sortValue: (RegistroHorarioEntity r) => r.precisionGps ?? 999.0,
    cell: (RegistroHorarioEntity r) => FichajePrecisionDot(precision: r.precisionGps),
  ),
];

/// Filtra por nombre, tipo y rango de fechas (ambos extremos incluidos)
List<RegistroHorarioEntity> filtrarFichajes(
  List<RegistroHorarioEntity> registros, {
  required String query,
  required FichajeTipoFiltro tipo,
  required DateTime? desde,
  required DateTime? hasta,
}) {
  final String q = query.trim().toLowerCase();
  return registros.where((RegistroHorarioEntity r) {
    final bool matchesSearch =
        q.isEmpty || (r.nombrePersonal?.toLowerCase().contains(q) ?? false);
    final bool matchesTipo = tipo == FichajeTipoFiltro.todos ||
        (tipo == FichajeTipoFiltro.entradas ? esEntrada(r) : !esEntrada(r));
    final bool matchesFechas =
        (desde == null || r.fechaHora.isAfter(desde.subtract(const Duration(days: 1)))) &&
            (hasta == null || r.fechaHora.isBefore(hasta.add(const Duration(days: 1))));
    return matchesSearch && matchesTipo && matchesFechas;
  }).toList();
}

/// Resumen para la barra de estado
List<String> resumenFichajes(List<RegistroHorarioEntity> todos, int filtrados) {
  final DateTime hoy = DateTime.now();
  final int deHoy = todos
      .where((RegistroHorarioEntity r) =>
          r.fechaHora.year == hoy.year && r.fechaHora.month == hoy.month && r.fechaHora.day == hoy.day)
      .length;
  final int entradas = todos.where(esEntrada).length;
  return <String>[
    if (filtrados == todos.length)
      '${todos.length} fichajes'
    else
      '$filtrados de ${todos.length} fichajes',
    'Hoy $deHoy',
    'Entradas $entradas',
    'Salidas ${todos.length - entradas}',
    'Últimos 30 días',
  ];
}

/// Imprime el listado de fichajes (filtrado y ordenado)
Future<void> imprimirFichajes(List<RegistroHorarioEntity> registros) {
  return GestionPrint.listado(
    title: 'Fichajes del Personal',
    headers: const <String>['Personal', 'Tipo', 'Fecha/Hora', 'Ubicación', 'Vehículo', 'Precisión GPS'],
    rows: registros
        .map(
          (RegistroHorarioEntity r) => <String>[
            GestionFormatters.texto(r.nombrePersonal),
            if (esEntrada(r)) 'Entrada' else 'Salida',
            fichajeFechaHora(r.fechaHora),
            GestionFormatters.texto(r.ubicacion),
            GestionFormatters.texto(r.vehiculoMatricula),
            if (r.precisionGps == null) GestionFormatters.vacio else '${r.precisionGps!.toStringAsFixed(0)} m',
          ],
        )
        .toList(),
  );
}
