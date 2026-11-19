import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/taller_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Selector de taller del catálogo que guarda el NOMBRE del taller.
///
/// Muestra los talleres activos y, si el valor guardado ya no está activo
/// (o es un texto libre antiguo), lo mantiene como primera opción.
/// Requiere un [TallerBloc] cargado en el contexto.
class TallerNombreField extends StatelessWidget {
  const TallerNombreField({required this.value, required this.onChanged, super.key});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallerBloc, TallerState>(
      builder: (BuildContext context, TallerState state) {
        final List<String> nombres = state is TallerLoaded
            ? state.talleres.where((TallerEntity t) => t.activo).map((TallerEntity t) => t.nombre).toList()
            : <String>[];
        final String? actual = value;
        if (actual != null && actual.isNotEmpty && !nombres.contains(actual)) {
          nombres.insert(0, actual);
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
