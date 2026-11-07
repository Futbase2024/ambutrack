import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/core/widgets/loading/app_loading_indicator.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/trayecto_form/trayecto_ubicacion_field.dart';
import 'package:flutter/material.dart';

/// Formulario de edición de trayecto
class TrayectoFormDialog extends StatefulWidget {
  const TrayectoFormDialog({
    required this.trayecto,
    required this.onSave,
    super.key,
  });

  final TrasladoEntity trayecto;
  final void Function(TrasladoEntity) onSave;

  @override
  State<TrayectoFormDialog> createState() => _TrayectoFormDialogState();
}

class _TrayectoFormDialogState extends State<TrayectoFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TrasladoDataSource _trasladoDataSource = TrasladoDataSourceFactory.createSupabase();
  final CentroHospitalarioDataSource _centroHospitalarioDataSource =
      CentroHospitalarioDataSourceFactory.createSupabase();

  late final TextEditingController _observacionesController =
      TextEditingController(text: widget.trayecto.observaciones ?? '');
  late DateTime _fecha = widget.trayecto.fecha ?? DateTime.now();
  late TimeOfDay _horaProgramada = _initialHora();

  late final TrayectoUbicacion _origen =
      TrayectoUbicacion(tipo: widget.trayecto.tipoOrigen, value: widget.trayecto.origen);
  late final TrayectoUbicacion _destino =
      TrayectoUbicacion(tipo: widget.trayecto.tipoDestino, value: widget.trayecto.destino);

  List<CentroHospitalarioEntity> _centrosHospitalarios = <CentroHospitalarioEntity>[];
  bool _isLoading = true;
  bool _isSaving = false;

  TimeOfDay _initialHora() {
    final DateTime? h = widget.trayecto.horaProgramada;
    return h != null ? TimeOfDay(hour: h.hour, minute: h.minute) : TimeOfDay.now();
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 Trayecto origen: tipo=${_origen.tipo}, valor=${_origen.value}');
    debugPrint('🔍 Trayecto destino: tipo=${_destino.tipo}, valor=${_destino.value}');
    _loadCentrosHospitalarios();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _origen.dispose();
    _destino.dispose();
    super.dispose();
  }

  Future<void> _loadCentrosHospitalarios() async {
    try {
      debugPrint('🏥 Cargando centros hospitalarios...');
      final List<CentroHospitalarioEntity> centros = await _centroHospitalarioDataSource.getAll();
      debugPrint('🏥 ${centros.length} centros cargados desde Supabase');
      if (!mounted) {
        return;
      }
      // Lista completa (incluye inactivos para localizar los ya guardados)
      _centrosHospitalarios = centros;
      _origen.resolverCentro(centros, 'origen');
      _destino.resolverCentro(centros, 'destino');
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('❌ Error cargando centros hospitalarios: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? get _observacionesValue =>
      _observacionesController.text.trim().isNotEmpty ? _observacionesController.text.trim() : null;

  Future<void> _onSave() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      // Hora programada como "HH:mm:ss" sobre la fecha elegida
      final String hora = '${_horaProgramada.hour.toString().padLeft(2, '0')}:'
          '${_horaProgramada.minute.toString().padLeft(2, '0')}:00';
      final DateTime horaProgramada = DateTime.parse('${_fecha.toIso8601String().split('T')[0]}T$hora');

      final TrasladoEntity trayectoActualizado = widget.trayecto.copyWith(
        fecha: _fecha,
        horaProgramada: horaProgramada,
        tipoOrigen: _origen.tipo,
        origen: _origen.value,
        tipoDestino: _destino.tipo,
        destino: _destino.value,
        observaciones: _observacionesValue,
        updatedAt: DateTime.now(),
      );

      await _trasladoDataSource.update(
        id: widget.trayecto.id,
        updates: <String, dynamic>{
          'fecha': _fecha.toIso8601String(),
          'hora_programada': horaProgramada.toIso8601String(),
          'tipo_origen': _origen.tipo,
          'origen': _origen.value,
          'tipo_destino': _destino.tipo,
          'destino': _destino.value,
          'observaciones': _observacionesValue,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        widget.onSave(trayectoActualizado);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Error al guardar trayecto: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        await showResultDialog(
          context: context,
          title: 'No se pudo guardar',
          message: 'No se pudo actualizar el trayecto. Inténtalo de nuevo.',
          details: e.toString(),
          type: ResultType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TrasladoEntity t = widget.trayecto;
    return GestionFormDialog(
      title: 'Editar trayecto',
      subtitle: t.codigo ?? t.paciente?.nombreCompleto,
      icon: Icons.edit_road,
      formKey: _formKey,
      isEditing: true,
      isSaving: _isSaving,
      onSave: _onSave,
      children: <Widget>[
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: AppLoadingIndicator(message: 'Cargando centros...'),
          )
        else ...<Widget>[
          const GestionFormSection(title: 'Trayecto', first: true),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Fecha',
                required: true,
                child: GestionDateField(
                  value: _fecha,
                  required: true,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onChanged: (DateTime? v) => setState(() => _fecha = v ?? _fecha),
                ),
              ),
              GestionFormRow(
                label: 'Hora',
                required: true,
                child: GestionTimeField(
                  value: _horaProgramada,
                  required: true,
                  onChanged: (TimeOfDay? v) => setState(() => _horaProgramada = v ?? _horaProgramada),
                ),
              ),
            ],
          ),
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Tipo traslado',
                child: GestionFormReadOnly(
                  value: t.tipoTraslado == 'ida' ? 'Ida (no editable)' : 'Vuelta (no editable)',
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          GestionFormColumns(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const GestionFormSection(title: 'Origen'),
                  TrayectoUbicacionField(
                    ubicacion: _origen,
                    centros: _centrosHospitalarios,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const GestionFormSection(title: 'Destino'),
                  TrayectoUbicacionField(
                    ubicacion: _destino,
                    centros: _centrosHospitalarios,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ],
          ),
          const GestionFormSection(title: 'Observaciones'),
          GestionFormRow(
            label: 'Observaciones',
            multiline: true,
            child: GestionTextField(
              controller: _observacionesController,
              hint: 'Notas adicionales sobre el trayecto',
              maxLines: 3,
            ),
          ),
        ],
      ],
    );
  }
}
