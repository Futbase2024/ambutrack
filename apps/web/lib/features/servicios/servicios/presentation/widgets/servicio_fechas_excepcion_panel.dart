import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/repositories/servicio_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Gestión de fechas excluidas (sin traslados) e incluidas (traslados extra)
/// de un servicio recurrente. Los cambios se guardan al momento en BD y los
/// triggers de Supabase regeneran/eliminan los traslados afectados.
class ServicioFechasExcepcionPanel extends StatefulWidget {
  const ServicioFechasExcepcionPanel({
    required this.servicioId,
    this.onChanged,
    super.key,
  });

  final String servicioId;

  /// Se invoca tras guardar cambios (p.ej. para recargar los trayectos)
  final VoidCallback? onChanged;

  @override
  State<ServicioFechasExcepcionPanel> createState() => _ServicioFechasExcepcionPanelState();
}

class _ServicioFechasExcepcionPanelState extends State<ServicioFechasExcepcionPanel>
    with SingleTickerProviderStateMixin {
  final ServicioRepository _repository = getIt<ServicioRepository>();
  late final TabController _tabController = TabController(length: 2, vsync: this);

  List<DateTime> _excluidas = <DateTime>[];
  List<DateTime> _incluidas = <DateTime>[];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ServicioFechasExcepcionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.servicioId != widget.servicioId) {
      _load();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final FechasExcepcionServicio fechas = await _repository.getFechasExcepcion(widget.servicioId);
      if (!mounted) {
        return;
      }
      setState(() {
        _excluidas = fechas.excluidas;
        _incluidas = fechas.incluidas;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ FechasExcepcion: Error al cargar: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        await _showError('No se pudieron cargar las fechas del servicio.', e);
      }
    }
  }

  Future<void> _save(List<DateTime> excluidas, List<DateTime> incluidas) async {
    setState(() => _isSaving = true);
    try {
      await _repository.updateFechasExcepcion(
        widget.servicioId,
        excluidas: excluidas,
        incluidas: incluidas,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _excluidas = List<DateTime>.of(excluidas)..sort();
        _incluidas = List<DateTime>.of(incluidas)..sort();
        _isSaving = false;
      });
      widget.onChanged?.call();
    } catch (e) {
      debugPrint('❌ FechasExcepcion: Error al guardar: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        await _showError('No se pudieron guardar las fechas del servicio.', e);
      }
    }
  }

  Future<void> _showError(String message, Object error) {
    return showResultDialog(
      context: context,
      title: 'Error',
      message: message,
      type: ResultType.error,
      details: error.toString(),
    );
  }

  Future<void> _addFecha({required bool excluir}) async {
    final DateTime hoy = DateUtils.dateOnly(DateTime.now());
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 730)),
      helpText: excluir ? 'Fecha a excluir' : 'Fecha a incluir',
    );
    if (fecha == null || !mounted) {
      return;
    }
    final List<DateTime> destino = excluir ? _excluidas : _incluidas;
    if (destino.any((DateTime f) => DateUtils.isSameDay(f, fecha))) {
      return;
    }
    if (excluir) {
      final bool? ok = await showSimpleConfirmationDialog(
        context: context,
        title: 'Excluir fecha',
        message: 'Se eliminarán los trayectos pendientes del '
            '${DateFormat('dd/MM/yyyy').format(fecha)} y no se generarán nuevos ese día.',
        confirmText: 'Excluir',
        icon: Icons.event_busy,
      );
      if (ok != true) {
        return;
      }
    }
    // Una fecha no puede estar a la vez excluida e incluida: se mueve de lista
    final List<DateTime> excluidas = excluir
        ? <DateTime>[..._excluidas, fecha]
        : _excluidas.where((DateTime f) => !DateUtils.isSameDay(f, fecha)).toList();
    final List<DateTime> incluidas = excluir
        ? _incluidas.where((DateTime f) => !DateUtils.isSameDay(f, fecha)).toList()
        : <DateTime>[..._incluidas, fecha];
    await _save(excluidas, incluidas);
  }

  Future<void> _removeFecha(DateTime fecha, {required bool excluida}) async {
    if (!excluida) {
      final bool? ok = await showSimpleConfirmationDialog(
        context: context,
        title: 'Quitar fecha incluida',
        message: 'Se eliminarán los trayectos pendientes generados para el '
            '${DateFormat('dd/MM/yyyy').format(fecha)} si no corresponden a la recurrencia.',
        confirmText: 'Quitar',
        icon: Icons.event_available,
      );
      if (ok != true) {
        return;
      }
    }
    await _save(
      excluida ? _excluidas.where((DateTime f) => f != fecha).toList() : _excluidas,
      excluida ? _incluidas : _incluidas.where((DateTime f) => f != fecha).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.secondary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            indicatorColor: AppColors.secondary,
            labelStyle: const TextStyle(fontSize: AppSizes.fontSmall, fontWeight: FontWeight.w600),
            tabs: <Tab>[
              Tab(text: 'FECHAS EXCLUIDAS (${_excluidas.length})'),
              Tab(text: 'FECHAS INCLUIDAS (${_incluidas.length})'),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: AppLoadingIndicator(size: 32))
              : TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _FechasExcepcionList(
                      fechas: _excluidas,
                      emptyText: 'Sin fechas excluidas',
                      addLabel: 'Excluir fecha',
                      color: AppColors.error,
                      isSaving: _isSaving,
                      onAdd: () => _addFecha(excluir: true),
                      onRemove: (DateTime f) => _removeFecha(f, excluida: true),
                    ),
                    _FechasExcepcionList(
                      fechas: _incluidas,
                      emptyText: 'Sin fechas incluidas',
                      addLabel: 'Incluir fecha',
                      color: AppColors.success,
                      isSaving: _isSaving,
                      onAdd: () => _addFecha(excluir: false),
                      onRemove: (DateTime f) => _removeFecha(f, excluida: false),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Lista de fechas con botón para añadir y eliminar
class _FechasExcepcionList extends StatelessWidget {
  const _FechasExcepcionList({
    required this.fechas,
    required this.emptyText,
    required this.addLabel,
    required this.color,
    required this.isSaving,
    required this.onAdd,
    required this.onRemove,
  });

  final List<DateTime> fechas;
  final String emptyText;
  final String addLabel;
  final Color color;
  final bool isSaving;
  final VoidCallback onAdd;
  final ValueChanged<DateTime> onRemove;

  @override
  Widget build(BuildContext context) {
    final DateFormat formato = DateFormat('EEEE dd/MM/yyyy', 'es_ES');
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              onPressed: isSaving ? null : onAdd,
              label: addLabel,
              icon: Icons.add,
              size: AppButtonSize.small,
              variant: AppButtonVariant.outline,
              isLoading: isSaving,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Expanded(
            child: fechas.isEmpty
                ? Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: fechas.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.gray200),
                    itemBuilder: (BuildContext context, int index) {
                      final DateTime fecha = fechas[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(Icons.event, size: AppSizes.iconMedium, color: color),
                        title: Text(
                          formato.format(fecha).toUpperCase(),
                          style: const TextStyle(
                            fontSize: AppSizes.fontSmall,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Quitar',
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: isSaving ? null : () => onRemove(fecha),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para gestionar las fechas excluidas/incluidas de un servicio
Future<void> showServicioFechasExcepcionDialog({
  required BuildContext context,
  required String servicioId,
  String? codigo,
  VoidCallback? onChanged,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
      child: SafeArea(
        child: SizedBox(
          width: 520,
          height: 560,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.event_busy, color: AppColors.primary),
                title: Text(
                  codigo == null ? 'Excepciones de fechas' : 'Excepciones de fechas · $codigo',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                ),
                subtitle: const Text(
                  'Excluye días sin servicio o incluye días extra',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Expanded(
                child: ServicioFechasExcepcionPanel(servicioId: servicioId, onChanged: onChanged),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
