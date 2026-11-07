import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/ausencias/presentation/widgets/form/eliminar_dias_parcial_form.dart';
import 'package:flutter/material.dart';

/// Diálogo para seleccionar un rango de días a eliminar de una vacación
class EliminarDiasParcialVacacionDialog extends StatelessWidget {
  const EliminarDiasParcialVacacionDialog({
    required this.vacacion,
    required this.nombrePersonal,
    super.key,
  });

  final VacacionesEntity vacacion;
  final String nombrePersonal;

  @override
  Widget build(BuildContext context) {
    return EliminarDiasParcialSolicitudDialog(
      entidad: 'vacación',
      fechaInicio: vacacion.fechaInicio,
      fechaFin: vacacion.fechaFin,
      diasTotales: vacacion.diasSolicitados,
      nombrePersonal: nombrePersonal,
      onConfirmar: (DateTime fechaInicioEliminar, DateTime fechaFinEliminar) {
        // Retornar el resultado con las fechas seleccionadas
        Navigator.of(context).pop(
          _EliminarDiasResult(
            fechaInicioEliminar: fechaInicioEliminar,
            fechaFinEliminar: fechaFinEliminar,
          ),
        );
      },
    );
  }
}

/// Resultado del diálogo de eliminación parcial
class _EliminarDiasResult {
  const _EliminarDiasResult({
    required this.fechaInicioEliminar,
    required this.fechaFinEliminar,
  });

  final DateTime fechaInicioEliminar;
  final DateTime fechaFinEliminar;
}

/// Muestra el diálogo de eliminación parcial y retorna el resultado
Future<({DateTime fechaInicio, DateTime fechaFin})?> showEliminarDiasParcialVacacionDialog({
  required BuildContext context,
  required VacacionesEntity vacacion,
  required String nombrePersonal,
}) async {
  final Object? result = await showDialog<Object>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => EliminarDiasParcialVacacionDialog(
      vacacion: vacacion,
      nombrePersonal: nombrePersonal,
    ),
  );

  if (result is _EliminarDiasResult) {
    return (
      fechaInicio: result.fechaInicioEliminar,
      fechaFin: result.fechaFinEliminar,
    );
  }

  return null;
}
