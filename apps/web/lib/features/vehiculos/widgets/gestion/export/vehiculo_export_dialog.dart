import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report_excel.dart';
import 'package:ambutrack_web/core/widgets/gestion/export/gestion_report_pdf.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_grid_column.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_export_options.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_ficha_data.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/export/vehiculo_reports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Abre el diálogo para exportar vehículos a PDF o Excel.
///
/// [vehiculos] son los visibles (filtrados y ordenados) y [seleccionado]
/// el vehículo marcado en la rejilla, si lo hay.
Future<void> showVehiculoExportDialog(
  BuildContext context, {
  required List<VehiculoEntity> vehiculos,
  required VehiculoEntity? seleccionado,
  required String filtros,
  VehiculoExportAlcance? alcance,
}) {
  final VehiculoFichaLoader loader = VehiculoFichaLoader.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext _) => VehiculoExportDialog(
      vehiculos: vehiculos,
      seleccionado: seleccionado,
      filtros: filtros,
      loader: loader,
      alcanceInicial: alcance ?? (seleccionado != null ? VehiculoExportAlcance.ficha : VehiculoExportAlcance.listado),
    ),
  );
}

/// Diálogo de exportación: qué exportar (listado, ficha, informe completo) y en qué formato
class VehiculoExportDialog extends StatefulWidget {
  const VehiculoExportDialog({
    required this.vehiculos,
    required this.seleccionado,
    required this.filtros,
    required this.loader,
    required this.alcanceInicial,
    super.key,
  });

  final List<VehiculoEntity> vehiculos;
  final VehiculoEntity? seleccionado;
  final String filtros;
  final VehiculoFichaLoader loader;
  final VehiculoExportAlcance alcanceInicial;

  @override
  State<VehiculoExportDialog> createState() => _VehiculoExportDialogState();
}

class _VehiculoExportDialogState extends State<VehiculoExportDialog> {
  /// Última selección de columnas (se recuerda mientras la app está abierta)
  static Set<int>? _ultimasColumnas;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<GestionColumn<VehiculoEntity>> _exportables = VehiculoReports.columnasExportables;
  late Set<int> _columnas = _ultimasColumnas ?? <int>{for (int i = 0; i < _exportables.length; i++) i};
  late VehiculoExportAlcance _alcance = widget.alcanceInicial;

  /// El listado sale en horizontal por defecto; la ficha, en vertical
  late bool _horizontal = widget.alcanceInicial == VehiculoExportAlcance.listado;
  VehiculoExportFormato _formato = VehiculoExportFormato.pdfImprimir;
  bool _exportando = false;
  double? _progreso;

  Future<void> _exportar() async {
    if (_alcance == VehiculoExportAlcance.listado && _columnas.isEmpty) {
      return;
    }
    setState(() {
      _exportando = true;
      _progreso = null;
    });
    try {
      final List<GestionReport> reports = (await _informes())
          .map((GestionReport r) => r.withOrientation(landscape: _horizontal))
          .toList();
      final String nombre = _nombreArchivo();
      switch (_formato) {
        case VehiculoExportFormato.pdfImprimir:
          await GestionReportPdf.imprimir(reports, fileName: nombre);
        case VehiculoExportFormato.pdfDescargar:
          await GestionReportPdf.descargar(reports, fileName: nombre);
        case VehiculoExportFormato.excel:
          await GestionReportExcel.descargar(reports, fileName: nombre);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ VehiculoExportDialog: $e');
      if (!mounted) {
        return;
      }
      setState(() => _exportando = false);
      await showResultDialog(
        context: context,
        title: 'Error al exportar',
        message: 'No se pudo generar el documento.',
        details: e.toString(),
        type: ResultType.error,
      );
    }
  }

  Future<List<GestionReport>> _informes() async {
    final bool excel = _formato == VehiculoExportFormato.excel;
    switch (_alcance) {
      case VehiculoExportAlcance.listado:
        _ultimasColumnas = _columnas;
        return <GestionReport>[
          VehiculoReports.listado(
            widget.vehiculos,
            filtros: widget.filtros,
            todosLosDatos: excel,
            columnas: <GestionColumn<VehiculoEntity>>[
              for (int i = 0; i < _exportables.length; i++)
                if (_columnas.contains(i)) _exportables[i],
            ],
          ),
        ];
      case VehiculoExportAlcance.ficha:
        final List<VehiculoFichaData> datos = await widget.loader.cargar(<VehiculoEntity>[widget.seleccionado!]);
        return <GestionReport>[VehiculoReports.ficha(datos.first)];
      case VehiculoExportAlcance.completo:
        final List<VehiculoFichaData> datos = await widget.loader.cargar(
          widget.vehiculos,
          onProgress: (double p) => mounted ? setState(() => _progreso = p) : null,
        );
        return excel
            ? <GestionReport>[VehiculoReports.completoExcel(datos, filtros: widget.filtros)]
            : datos.map(VehiculoReports.ficha).toList();
    }
  }

  String _nombreArchivo() {
    final String fecha = DateFormat('yyyyMMdd').format(DateTime.now());
    return switch (_alcance) {
      VehiculoExportAlcance.listado => 'Vehiculos_listado_$fecha',
      VehiculoExportAlcance.ficha => 'Vehiculo_${widget.seleccionado!.matricula}_$fecha',
      VehiculoExportAlcance.completo => 'Vehiculos_informe_completo_$fecha',
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Exportar vehículos',
      icon: Icons.file_download_outlined,
      formKey: _formKey,
      isSaving: _exportando,
      saveLabel: _exportando ? 'Generando...' : 'Exportar',
      onSave: _exportar,
      children: <Widget>[
        VehiculoExportOptions(
          alcance: _alcance,
          formato: _formato,
          totalVehiculos: widget.vehiculos.length,
          seleccionado: widget.seleccionado,
          filtros: widget.filtros,
          enabled: !_exportando,
          onAlcance: (VehiculoExportAlcance a) => setState(() {
            _alcance = a;
            _horizontal = a == VehiculoExportAlcance.listado;
          }),
          onFormato: (VehiculoExportFormato f) => setState(() => _formato = f),
          horizontal: _horizontal,
          onHorizontal: (bool h) => setState(() => _horizontal = h),
          columnLabels: <String>[for (final GestionColumn<VehiculoEntity> c in _exportables) c.label],
          columnas: _columnas,
          onColumnas: (Set<int> c) => setState(() => _columnas = c),
        ),
        if (_exportando) VehiculoExportProgress(progreso: _progreso, alcance: _alcance),
      ],
    );
  }
}
