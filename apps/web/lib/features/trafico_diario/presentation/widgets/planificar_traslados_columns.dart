import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/context_menu/custom_context_menu.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/operativa/presentation/widgets/common/traslado_gestion_helpers.dart';
import 'package:ambutrack_web/features/trafico_diario/presentation/widgets/planificar_traslado_valores.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _hhmm = DateFormat('HH:mm');

int _minutos(DateTime? d) => d == null ? 99999 : d.toLocal().hour * 60 + d.toLocal().minute;

String _hora(DateTime? d) => d == null ? '' : _hhmm.format(d.toLocal());

/// Columnas de la rejilla de "Planificar Servicios".
///
/// Las columnas de texto son flexibles con un ancho mínimo: se reparten el
/// ancho disponible y, si no caben, la rejilla se desplaza en horizontal.
/// Cada celda abre el menú contextual del traslado con el botón derecho.
List<GestionColumn<TrasladoEntity>> planificarTrasladosColumns({
  required PlanificarTrasladoValores valores,
  required List<ContextMenuOption> Function(TrasladoEntity t) menu,
}) {
  GestionColumn<TrasladoEntity> texto(
    String label,
    String Function(TrasladoEntity t) valor, {
    double minWidth = 90,
    bool bold = false,
    bool filtrable = true,
  }) {
    return GestionColumn<TrasladoEntity>(
      label: label,
      // flex proporcional al mínimo: la rejilla reparte el ancho por flex, así
      // ninguna columna queda por debajo de su mínimo cuando la rejilla cabe
      flex: minWidth ~/ 10,
      minWidth: minWidth,
      sortValue: valor,
      filterValue: filtrable ? valor : null,
      cell: (TrasladoEntity t) => _MenuCell(
        options: menu(t),
        child: TrasladoCellText(GestionFormatters.texto(valor(t)), bold: bold),
      ),
    );
  }

  GestionColumn<TrasladoEntity> requisito(String label, IconData icon, bool? Function(TrasladoEntity t) valor) {
    return GestionColumn<TrasladoEntity>(
      label: label,
      width: 40,
      headerIcon: icon,
      headerIconOnly: true,
      alignment: Alignment.center,
      // Sin ordenación: en 40px solo cabe el icono de la cabecera
      cell: (TrasladoEntity t) => _MenuCell(
        options: menu(t),
        alignment: Alignment.center,
        child: (valor(t) ?? false)
            ? const Icon(Icons.check_circle, size: 16, color: AppColors.success)
            : const SizedBox.shrink(),
      ),
    );
  }

  GestionColumn<TrasladoEntity> hito(String label, DateTime? Function(TrasladoEntity t) valor) {
    return GestionColumn<TrasladoEntity>(
      label: label,
      width: 56,
      alignment: Alignment.center,
      sortValue: (TrasladoEntity t) => _minutos(valor(t)),
      cell: (TrasladoEntity t) => _MenuCell(
        options: menu(t),
        alignment: Alignment.center,
        child: TrasladoCellText(GestionFormatters.texto(_hora(valor(t)))),
      ),
    );
  }

  return <GestionColumn<TrasladoEntity>>[
    GestionColumn<TrasladoEntity>(
      label: 'I/V',
      // Título + flecha de orden + embudo de filtro
      width: 76,
      alignment: Alignment.center,
      sortValue: valores.tipo,
      filterValue: valores.tipo,
      cell: (TrasladoEntity t) => _MenuCell(
        options: menu(t),
        alignment: Alignment.center,
        child: _TipoTrasladoIcon(ida: valores.esIda(t), tipo: valores.tipo(t)),
      ),
    ),
    GestionColumn<TrasladoEntity>(
      label: 'Hora',
      width: 64,
      alignment: Alignment.center,
      sortValue: (TrasladoEntity t) => _minutos(t.horaProgramada),
      cell: (TrasladoEntity t) => _MenuCell(
        options: menu(t),
        alignment: Alignment.center,
        child: _HoraProgramadaText(hora: _hora(t.horaProgramada)),
      ),
    ),
    texto('Paciente', valores.paciente, minWidth: 140, bold: true),
    texto('Dom. Origen', valores.domicilioOrigen, minWidth: 120, filtrable: false),
    texto('Loc. Origen', valores.localidadOrigen),
    texto('Origen', valores.origen),
    texto('Dom. Destino', valores.domicilioDestino, minWidth: 120, filtrable: false),
    texto('Loc. Destino', valores.localidadDestino),
    texto('Destino', valores.destino),
    texto('Terapia', valores.terapia),
    GestionColumn<TrasladoEntity>(
      label: 'Estado',
      width: 130,
      sortValue: (TrasladoEntity t) => TrasladoGestion.todosLosEstados.indexOf(t.estado ?? ''),
      filterValue: (TrasladoEntity t) => TrasladoGestion.estadoLabel(t.estado),
      cell: (TrasladoEntity t) => _MenuCell(
        options: menu(t),
        child: TrasladoEstadoDot(estado: t.estado),
      ),
    ),
    texto('Conductor', valores.conductor, minWidth: 110, bold: true),
    requisito('Silla de ruedas', Icons.accessible, (TrasladoEntity t) => t.requiereSillaRuedas),
    requisito('Camilla', Icons.airline_seat_flat, (TrasladoEntity t) => t.requiereCamilla),
    requisito('Ayuda', Icons.back_hand_outlined, (TrasladoEntity t) => t.requiereAyuda),
    requisito('Acompañante', Icons.people_outline, (TrasladoEntity t) => t.requiereAcompanante),
    texto('Matrícula', valores.matricula),
    hito('H. Env', (TrasladoEntity t) => t.fechaEnviado),
    hito('H. Rec', (TrasladoEntity t) => t.fechaRecibidoConductor),
    hito('H. Org', (TrasladoEntity t) => t.fechaEnOrigen),
    hito('H. Sal', (TrasladoEntity t) => t.fechaSaliendoOrigen),
    hito('H. Dst', (TrasladoEntity t) => t.fechaEnDestino),
    hito('H. Fin', (TrasladoEntity t) => t.fechaFinalizado),
  ];
}

/// Celda que ocupa todo su hueco y abre el menú contextual con clic derecho
class _MenuCell extends StatelessWidget {
  const _MenuCell({
    required this.options,
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final List<ContextMenuOption> options;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return CustomContextMenu(
      menuOptions: options,
      child: SizedBox.expand(child: Align(alignment: alignment, child: child)),
    );
  }
}

/// Flecha de ida (verde) o vuelta (roja)
class _TipoTrasladoIcon extends StatelessWidget {
  const _TipoTrasladoIcon({required this.ida, required this.tipo});

  final bool ida;
  final String tipo;

  @override
  Widget build(BuildContext context) {
    final Color color = ida ? AppColors.success : AppColors.error;
    return Tooltip(
      message: tipo.isEmpty ? 'Sin tipo' : tipo,
      child: Container(
        width: 26,
        height: 20,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(
          ida ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
          size: 15,
          color: color,
        ),
      ),
    );
  }
}

/// Hora programada destacada
class _HoraProgramadaText extends StatelessWidget {
  const _HoraProgramadaText({required this.hora});

  final String hora;

  @override
  Widget build(BuildContext context) {
    return Text(
      hora,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
    );
  }
}
