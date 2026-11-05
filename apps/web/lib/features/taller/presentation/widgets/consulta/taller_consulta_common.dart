import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';

/// Valor "sin filtro" de los desplegables de consulta
const String tallerFiltroTodos = '';

/// Opciones de desplegable a partir de los valores presentes en los datos
Map<String, String> tallerOpcionesDe(Iterable<String?> valores, {String todos = 'Todos'}) {
  final List<String> unicos = valores
      .whereType<String>()
      .where((String v) => v.trim().isNotEmpty)
      .toSet()
      .toList()
    ..sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return <String, String>{tallerFiltroTodos: todos, for (final String v in unicos) v: v};
}

/// Indica si [fecha] (día local) está dentro de [rango] (ambos extremos incluidos)
bool tallerEnRango(DateTime? fecha, DateTimeRange? rango) {
  if (rango == null) {
    return true;
  }
  if (fecha == null) {
    return false;
  }
  final DateTime l = fecha.toLocal();
  final DateTime dia = DateTime(l.year, l.month, l.day);
  return !dia.isBefore(rango.start) && !dia.isAfter(rango.end);
}

/// Texto del rango para subtítulos de impresión
String? tallerRangoTexto(DateTimeRange? rango) => rango == null
    ? null
    : 'Del ${GestionFormatters.fecha(rango.start)} al ${GestionFormatters.fecha(rango.end)}';

/// Barra de herramientas de las pantallas de consulta (sin CRUD)
class TallerConsultaToolbar extends StatelessWidget {
  const TallerConsultaToolbar({
    required this.title,
    required this.icon,
    required this.onRefresh,
    required this.onPrint,
    this.extraActions = const <GestionToolbarAction>[],
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback onRefresh;
  final VoidCallback? onPrint;
  final List<GestionToolbarAction> extraActions;

  @override
  Widget build(BuildContext context) {
    return GestionToolbar(
      title: title,
      icon: icon,
      groups: <List<GestionToolbarAction>>[
        <GestionToolbarAction>[
          GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar', onPressed: onRefresh),
          GestionToolbarAction(
            icon: Icons.print_outlined,
            label: 'Imprimir',
            tooltip: 'Imprimir o guardar como PDF el listado filtrado',
            onPressed: onPrint,
          ),
        ],
        if (extraActions.isNotEmpty) extraActions,
      ],
    );
  }
}

/// Barra de filtros con desplazamiento horizontal (admite muchos filtros)
class TallerConsultaFilterBar extends StatelessWidget {
  const TallerConsultaFilterBar({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 12),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Filtro compacto de rango de fechas: "Fechas: [01/10/2026 – 31/10/2026 ✕]"
class TallerDateRangeFilter extends StatelessWidget {
  const TallerDateRangeFilter({
    required this.rango,
    required this.onChanged,
    this.label = 'Fechas',
    super.key,
  });

  final DateTimeRange? rango;
  final ValueChanged<DateTimeRange?> onChanged;
  final String label;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5, 12, 31),
      initialDateRange: rango,
      helpText: 'Selecciona el rango de fechas',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      saveText: 'Aplicar',
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTimeRange? r = rango;
    final String texto = r == null
        ? 'Todas'
        : '${GestionFormatters.fecha(r.start)} – ${GestionFormatters.fecha(r.end)}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$label:', style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
        const SizedBox(width: 6),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppColors.gray300),
          ),
          child: InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.date_range, size: 15, color: AppColors.gray500),
                  const SizedBox(width: 6),
                  Text(texto, style: const TextStyle(fontSize: 13, color: AppColors.gray900)),
                  if (r != null) ...<Widget>[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => onChanged(null),
                      child: const Icon(Icons.close, size: 14, color: AppColors.gray500),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón de la ficha lateral que navega a otra pantalla
class TallerDetailNavButton extends StatelessWidget {
  const TallerDetailNavButton({
    required this.label,
    required this.onPressed,
    this.icon = Icons.open_in_new,
    this.tooltip,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? label,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 34),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
