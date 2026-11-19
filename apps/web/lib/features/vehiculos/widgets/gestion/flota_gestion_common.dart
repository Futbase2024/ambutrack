import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilidades compartidas por las pantallas de gestión del módulo de Flota
/// (vehículos, ITV, documentación, averías, consumo y stock).

final NumberFormat _enteroFormat = NumberFormat('#,##0', 'es_ES');
final NumberFormat _decimalFormat = NumberFormat('#,##0.0', 'es_ES');
final NumberFormat _decimal2Format = NumberFormat('#,##0.00', 'es_ES');

/// Kilómetros: "123.456 km"
String flotaKm(num? value) =>
    value == null ? GestionFormatters.vacio : '${_enteroFormat.format(value)} km';

/// Número entero con separador de miles
String flotaEntero(num? value) =>
    value == null ? GestionFormatters.vacio : _enteroFormat.format(value);

/// Número con 1 decimal (litros, consumos...)
String flotaDecimal(num? value, {String sufijo = ''}) =>
    value == null ? GestionFormatters.vacio : '${_decimalFormat.format(value)}$sufijo';

/// Número con 2 decimales (precios unitarios...)
String flotaDecimal2(num? value, {String sufijo = ''}) =>
    value == null ? GestionFormatters.vacio : '${_decimal2Format.format(value)}$sufijo';

/// Importe opcional en euros
String flotaMoneda(double? value) =>
    value == null ? GestionFormatters.vacio : GestionFormatters.moneda(value);

/// "Sí" / "No"
String flotaSiNo({required bool value}) => value ? 'Sí' : 'No';

/// Primer texto de resumen de la barra de estado
String flotaResumenRegistros(int total, int filtrados) =>
    filtrados == total ? '$total registros' : '$filtrados de $total registros';

/// Devuelve la página [page] (base 0) de [rows]
List<T> flotaPageOf<T>(List<T> rows, int page, int pageSize) {
  final int start = (page * pageSize).clamp(0, rows.length);
  final int end = (start + pageSize).clamp(0, rows.length);
  return rows.sublist(start, end);
}

/// Texto de celda que pinta el marcador de vacío en gris claro
class FlotaCellText extends StatelessWidget {
  const FlotaCellText(this.value, {this.bold = false, this.color, super.key});

  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool empty = value == GestionFormatters.vacio;
    return Text(
      value,
      style: TextStyle(
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: empty ? AppColors.gray300 : color,
      ),
    );
  }
}

/// Bloque de texto libre (observaciones, descripciones...) en la ficha
class FlotaNotes extends StatelessWidget {
  const FlotaNotes(this.text, {super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final bool hasText = text?.trim().isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(text),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: hasText ? AppColors.gray800 : AppColors.gray300,
        ),
      ),
    );
  }
}

/// Texto informativo gris dentro de una pestaña de la ficha
class FlotaEmptyNote extends StatelessWidget {
  const FlotaEmptyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.gray500)),
    );
  }
}

/// Indicador de carga pequeño para pestañas de la ficha
class FlotaTabLoading extends StatelessWidget {
  const FlotaTabLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Botón de acción de la parte inferior de la ficha lateral
class FlotaPanelButton extends StatelessWidget {
  const FlotaPanelButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    super.key,
  });

  const FlotaPanelButton.edit({required this.onPressed, super.key})
      : icon = Icons.edit_outlined,
        label = 'Editar',
        color = AppColors.primary;

  const FlotaPanelButton.delete({required this.onPressed, super.key})
      : icon = Icons.delete_outline,
        label = 'Eliminar',
        color = AppColors.error;

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        minimumSize: const Size(0, 34),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Error de carga inicial con botón "Reintentar"
class FlotaLoadError extends StatelessWidget {
  const FlotaLoadError({
    required this.title,
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.gray600),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zona central de la pantalla: carga inicial, error o rejilla (con barra de
/// progreso fina durante las recargas para que la rejilla no parpadee)
class FlotaGridArea extends StatelessWidget {
  const FlotaGridArea({
    required this.hasData,
    required this.loading,
    required this.errorTitle,
    required this.onRetry,
    required this.child,
    this.errorMessage,
    super.key,
  });

  /// Hay datos en caché que mostrar
  final bool hasData;

  /// Hay una recarga en curso
  final bool loading;

  /// Mensaje de error (solo se muestra si no hay datos en caché)
  final String? errorMessage;
  final String errorTitle;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!hasData && errorMessage != null) {
      return FlotaLoadError(title: errorTitle, message: errorMessage!, onRetry: onRetry);
    }
    if (!hasData) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(child: child),
        if (loading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

/// Fila compacta de las listas de las pestañas de la ficha
class FlotaMiniRow extends StatelessWidget {
  const FlotaMiniRow({
    required this.leading,
    required this.middle,
    required this.trailing,
    this.leadingWidth = 96,
    super.key,
  });

  final String leading;
  final Widget middle;
  final String trailing;
  final double leadingWidth;

  @override
  Widget build(BuildContext context) {
    const TextStyle base = TextStyle(fontSize: 12, color: AppColors.gray800);
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: leadingWidth,
            child: Text(
              leading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: base.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: middle),
          const SizedBox(width: 6),
          Text(trailing, style: base.copyWith(color: AppColors.gray500, fontSize: 11.5)),
        ],
      ),
    );
  }
}
