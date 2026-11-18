import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_export_columns_picker.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Qué se exporta
enum VehiculoExportAlcance { listado, ficha, completo }

/// En qué formato se exporta
enum VehiculoExportFormato {
  pdfImprimir('PDF', 'Vista previa e imprimir', Icons.print_outlined),
  pdfDescargar('PDF', 'Descargar archivo', Icons.picture_as_pdf_outlined),
  excel('Excel', 'Descargar .xlsx', Icons.table_view_outlined);

  const VehiculoExportFormato(this.label, this.detalle, this.icon);

  final String label;
  final String detalle;
  final IconData icon;
}

/// Selección de contenido y formato del diálogo de exportación
class VehiculoExportOptions extends StatelessWidget {
  const VehiculoExportOptions({
    required this.alcance,
    required this.formato,
    required this.totalVehiculos,
    required this.seleccionado,
    required this.filtros,
    required this.enabled,
    required this.onAlcance,
    required this.onFormato,
    required this.horizontal,
    required this.onHorizontal,
    required this.columnLabels,
    required this.columnas,
    required this.onColumnas,
    super.key,
  });

  final VehiculoExportAlcance alcance;
  final VehiculoExportFormato formato;
  final int totalVehiculos;
  final VehiculoEntity? seleccionado;
  final String filtros;
  final bool enabled;
  final ValueChanged<VehiculoExportAlcance> onAlcance;
  final ValueChanged<VehiculoExportFormato> onFormato;

  /// Orientación del PDF (true = horizontal)
  final bool horizontal;
  final ValueChanged<bool> onHorizontal;

  /// Columnas exportables del listado y las marcadas (índices)
  final List<String> columnLabels;
  final Set<int> columnas;
  final ValueChanged<Set<int>> onColumnas;

  @override
  Widget build(BuildContext context) {
    final VehiculoEntity? sel = seleccionado;
    final bool excel = formato == VehiculoExportFormato.excel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Contenido', first: true),
        _OptionCard(
          icon: Icons.list_alt,
          title: 'Listado de vehículos ($totalVehiculos)',
          subtitle: excel
              ? '$filtros · igual que la rejilla + hoja con todos los datos'
              : '$filtros · igual que la rejilla, con totales',
          selected: alcance == VehiculoExportAlcance.listado,
          onTap: enabled && totalVehiculos > 0 ? () => onAlcance(VehiculoExportAlcance.listado) : null,
        ),
        _OptionCard(
          icon: Icons.description_outlined,
          title: sel == null ? 'Ficha del vehículo' : 'Ficha del vehículo · ${sel.matricula}',
          subtitle: sel == null
              ? 'Selecciona un vehículo en la rejilla para exportar su ficha'
              : 'Datos generales, ITV, documentación, reparaciones y equipamiento',
          selected: alcance == VehiculoExportAlcance.ficha,
          onTap: enabled && sel != null ? () => onAlcance(VehiculoExportAlcance.ficha) : null,
        ),
        _OptionCard(
          icon: Icons.library_books_outlined,
          title: 'Informe completo ($totalVehiculos vehículos)',
          subtitle: excel
              ? 'Libro con hojas: Vehículos, ITV, Documentación, Reparaciones y Equipamiento'
              : 'Una ficha completa por vehículo, cada una en página nueva',
          selected: alcance == VehiculoExportAlcance.completo,
          onTap: enabled && totalVehiculos > 0 ? () => onAlcance(VehiculoExportAlcance.completo) : null,
        ),
        const GestionFormSection(title: 'Formato'),
        Row(
          children: <Widget>[
            for (final VehiculoExportFormato f in VehiculoExportFormato.values)
              Expanded(
                child: _OptionCard(
                  icon: f.icon,
                  title: f.label,
                  subtitle: f.detalle,
                  selected: formato == f,
                  compact: true,
                  onTap: enabled ? () => onFormato(f) : null,
                ),
              ),
          ],
        ),
        if (!excel) ...<Widget>[
          const GestionFormSection(title: 'Orientación del PDF'),
          Row(
            children: <Widget>[
              Expanded(
                child: _OptionCard(
                  icon: Icons.stay_current_portrait,
                  title: 'Vertical',
                  subtitle: 'A4 en vertical',
                  selected: !horizontal,
                  compact: true,
                  onTap: enabled ? () => onHorizontal(false) : null,
                ),
              ),
              Expanded(
                child: _OptionCard(
                  icon: Icons.stay_current_landscape,
                  title: 'Horizontal',
                  subtitle: 'A4 apaisado (más columnas)',
                  selected: horizontal,
                  compact: true,
                  onTap: enabled ? () => onHorizontal(true) : null,
                ),
              ),
            ],
          ),
        ],
        if (alcance == VehiculoExportAlcance.listado) ...<Widget>[
          const GestionFormSection(title: 'Columnas del listado'),
          GestionExportColumnsPicker(
            labels: columnLabels,
            selected: columnas,
            enabled: enabled,
            onChanged: onColumnas,
          ),
        ],
      ],
    );
  }
}

/// Tarjeta seleccionable (estilo radio)
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null && !selected;
    final Color accent = disabled ? AppColors.gray400 : AppColors.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: 8, right: compact ? 8 : 0),
      child: Material(
        color: selected ? AppColors.primarySurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: selected ? AppColors.primary : AppColors.gray200, width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 22, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: disabled ? AppColors.gray400 : AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.gray500)),
                    ],
                  ),
                ),
                if (selected) const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso mientras se generan los documentos
class VehiculoExportProgress extends StatelessWidget {
  const VehiculoExportProgress({required this.progreso, required this.alcance, super.key});

  final double? progreso;
  final VehiculoExportAlcance alcance;

  @override
  Widget build(BuildContext context) {
    final double? p = progreso;
    final String texto = alcance == VehiculoExportAlcance.completo && p != null
        ? 'Cargando equipamiento de los vehículos... ${(p * 100).round()} %'
        : 'Preparando el documento...';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LinearProgressIndicator(
            value: p,
            minHeight: 4,
            color: AppColors.primary,
            backgroundColor: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 6),
          Text(texto, style: const TextStyle(fontSize: 11.5, color: AppColors.gray600)),
        ],
      ),
    );
  }
}
