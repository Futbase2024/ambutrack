import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';

/// Widget configuración de tipo de servicio
class TipoServicioConfigWidget extends StatelessWidget {
  const TipoServicioConfigWidget({
    super.key,
    required this.motivoSeleccionado,
    required this.motivos,
    required this.loading,
    required this.onChanged,
  });

  final MotivoTrasladoEntity? motivoSeleccionado;
  final List<MotivoTrasladoEntity> motivos;
  final bool loading;
  final ValueChanged<MotivoTrasladoEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestionFormRow(
      label: 'Tipo de servicio',
      required: true,
      child: GestionSearchField<MotivoTrasladoEntity>(
        value: motivoSeleccionado,
        loading: loading,
        enabled: loading || motivos.isNotEmpty,
        hint: motivos.isEmpty && !loading ? 'No hay tipos de servicio disponibles' : 'Buscar tipo de servicio…',
        options: motivos
            .map((MotivoTrasladoEntity m) => GestionOption<MotivoTrasladoEntity>(m, m.nombre))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
