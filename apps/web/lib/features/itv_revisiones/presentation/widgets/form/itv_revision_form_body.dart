import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/itv_revisiones/presentation/widgets/form/itv_revision_form_data.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Campos del formulario de ITV/Revisión
class ItvRevisionFormBody extends StatelessWidget {
  const ItvRevisionFormBody({
    required this.data,
    required this.isEditing,
    required this.onChanged,
    super.key,
  });

  final ItvRevisionFormData data;
  final bool isEditing;

  /// Notifica cambios para que el diálogo se reconstruya
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Inspección', first: true),
        GestionFormRow(
          label: 'Vehículo',
          required: true,
          child: _VehiculoField(data: data, isEditing: isEditing, onChanged: onChanged),
        ),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Tipo',
                  required: true,
                  child: GestionDropdownField<TipoItvRevision>(
                    value: data.tipo,
                    options: ItvRevisionFormOptions.tipos,
                    required: true,
                    onChanged: (TipoItvRevision? v) => _set(() => data.tipo = v ?? data.tipo),
                  ),
                ),
                GestionFormRow(
                  label: 'Fecha',
                  required: true,
                  child: GestionDateField(
                    value: data.fecha,
                    required: true,
                    onChanged: (DateTime? v) => _set(() => data.fecha = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Kilometraje',
                  required: true,
                  child: GestionIntField(controller: data.km, unit: 'km', required: true),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Resultado',
                  required: true,
                  child: GestionDropdownField<ResultadoItvRevision>(
                    value: data.resultado,
                    options: ItvRevisionFormOptions.resultados,
                    required: true,
                    onChanged: (ResultadoItvRevision? v) => _set(() => data.resultado = v ?? data.resultado),
                  ),
                ),
                GestionFormRow(
                  label: 'Vencimiento',
                  child: GestionDateField(
                    value: data.fechaVencimiento,
                    onChanged: (DateTime? v) => _set(() => data.fechaVencimiento = v),
                  ),
                ),
                GestionFormRow(
                  label: 'Coste total',
                  required: true,
                  child: GestionMoneyField(controller: data.coste, required: true),
                ),
              ],
            ),
          ],
        ),
        if (isEditing)
          GestionFormColumns(
            children: <Widget>[
              GestionFormRow(
                label: 'Estado',
                required: true,
                child: GestionDropdownField<EstadoItvRevision>(
                  value: data.estado,
                  options: ItvRevisionFormOptions.estados,
                  required: true,
                  onChanged: (EstadoItvRevision? v) => _set(() => data.estado = v ?? data.estado),
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        const GestionFormSection(title: 'Taller y documentación'),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Taller',
              child: _TallerField(data: data, onChanged: onChanged),
            ),
            GestionFormRow(
              label: 'Nº documento',
              child: GestionTextField(controller: data.documento, hint: 'Nº de informe o factura'),
            ),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: data.observaciones, maxLines: 3, maxLength: 1000),
        ),
      ],
    );
  }

  void _set(VoidCallback change) {
    change();
    onChanged();
  }
}

class _VehiculoField extends StatelessWidget {
  const _VehiculoField({required this.data, required this.isEditing, required this.onChanged});

  final ItvRevisionFormData data;
  final bool isEditing;
  final VoidCallback onChanged;

  static String _label(VehiculoEntity v) => '${v.matricula} · ${v.marca} ${v.modelo}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        final List<VehiculoEntity> vehiculos =
            state is VehiculosLoaded ? state.vehiculos : <VehiculoEntity>[];
        if (isEditing) {
          final VehiculoEntity? v =
              vehiculos.where((VehiculoEntity e) => e.id == data.vehiculoId).firstOrNull;
          return GestionFormReadOnly(value: v == null ? (data.vehiculoId ?? '—') : _label(v));
        }
        return GestionSearchField<String>(
          value: data.vehiculoId,
          required: true,
          loading: state is! VehiculosLoaded,
          hint: 'Buscar por matrícula, marca o modelo',
          options: vehiculos
              .map(
                (VehiculoEntity v) => GestionOption<String>(
                  v.id,
                  _label(v),
                  color: v.estado == VehiculoEstado.activo ? AppColors.success : AppColors.warning,
                ),
              )
              .toList(),
          onChanged: (String? id) {
            data.vehiculoId = id;
            final VehiculoEntity? v = vehiculos.where((VehiculoEntity e) => e.id == id).firstOrNull;
            // Autocompleta el kilometraje con el km actual del vehículo
            data.km.text = GestionFormParse.formatEntero(v?.kmActual ?? 0);
            onChanged();
          },
        );
      },
    );
  }
}

class _TallerField extends StatelessWidget {
  const _TallerField({required this.data, required this.onChanged});

  final ItvRevisionFormData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallerBloc, TallerState>(
      builder: (BuildContext context, TallerState state) {
        final List<String> nombres = state is TallerLoaded
            ? state.talleres.where((TallerEntity t) => t.activo).map((TallerEntity t) => t.nombre).toList()
            : <String>[];
        // Conserva el taller guardado aunque ya no esté activo
        if (data.taller != null && !nombres.contains(data.taller)) {
          nombres.insert(0, data.taller!);
        }
        return GestionSearchField<String>(
          value: data.taller,
          loading: state is! TallerLoaded && state is! TallerError,
          hint: 'Seleccionar taller',
          options: nombres.map((String n) => GestionOption<String>(n, n)).toList(),
          onChanged: (String? v) {
            data.taller = v;
            onChanged();
          },
        );
      },
    );
  }
}
