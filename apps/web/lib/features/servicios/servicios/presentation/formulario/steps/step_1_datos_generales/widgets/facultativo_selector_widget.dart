import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Widget para seleccionar el facultativo que prescribe el traslado
class FacultativoSelectorWidget extends StatelessWidget {
  const FacultativoSelectorWidget({
    super.key,
    required this.facultativo,
    required this.facultativos,
    required this.loading,
    required this.onChanged,
  });

  final FacultativoEntity? facultativo;
  final List<FacultativoEntity> facultativos;
  final bool loading;
  final ValueChanged<FacultativoEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: 'Facultativo',
      required: true,
      child: GestionSearchField<FacultativoEntity>(
        value: facultativo,
        hint: 'Nombre, apellidos o nº colegiado',
        loading: loading,
        options: facultativos
            .map(
              (FacultativoEntity f) => GestionOption<FacultativoEntity>(
                f,
                '${f.nombre} ${f.apellidos}${f.numColegiado != null ? ' (Col: ${f.numColegiado})' : ''}',
                color: f.activo ? null : AppColors.gray400,
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
