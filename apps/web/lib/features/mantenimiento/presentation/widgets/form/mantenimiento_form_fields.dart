import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Selector de taller por nombre (talleres activos + el guardado, si ya no lo está)
class MantenimientoTallerField extends StatelessWidget {
  const MantenimientoTallerField({required this.value, required this.onChanged, super.key});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallerBloc, TallerState>(
      builder: (BuildContext context, TallerState state) {
        final List<String> nombres = state is TallerLoaded
            ? state.talleres.where((TallerEntity t) => t.activo).map((TallerEntity t) => t.nombre).toList()
            : <String>[];
        if (value != null && !nombres.contains(value)) {
          nombres.insert(0, value!);
        }
        return GestionSearchField<String>(
          value: value,
          loading: state is TallerLoading,
          hint: 'Seleccionar taller',
          options: nombres.map((String n) => GestionOption<String>(n, n)).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

/// Selector de vehículo con búsqueda por matrícula, marca o modelo
class MantenimientoVehiculoField extends StatelessWidget {
  const MantenimientoVehiculoField({
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final VehiculoEntity? value;
  final bool enabled;
  final ValueChanged<VehiculoEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiculosBloc, VehiculosState>(
      builder: (BuildContext context, VehiculosState state) {
        final List<VehiculoEntity> vehiculos =
            state is VehiculosLoaded ? state.vehiculos : <VehiculoEntity>[];
        return GestionSearchField<VehiculoEntity>(
          value: value,
          required: true,
          enabled: enabled,
          loading: state is! VehiculosLoaded,
          hint: 'Buscar por matrícula, marca o modelo',
          options: vehiculos
              .map(
                (VehiculoEntity v) => GestionOption<VehiculoEntity>(
                  v,
                  '${v.matricula} · ${v.marca} ${v.modelo}',
                  color: v.estado == VehiculoEstado.activo ? AppColors.success : AppColors.warning,
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
