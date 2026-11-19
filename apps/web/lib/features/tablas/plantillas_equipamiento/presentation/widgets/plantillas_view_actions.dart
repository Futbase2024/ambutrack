import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_bloc.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_event.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/bloc/plantillas_equipamiento_state.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_form_dialog.dart';
import 'package:ambutrack_web/features/tablas/plantillas_equipamiento/presentation/widgets/plantilla_item_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Acciones de la pantalla de plantillas: formularios, confirmaciones y resultados
mixin PlantillasViewActions<T extends StatefulWidget> on State<T> {
  /// Operación lanzada desde la vista (no desde un formulario) pendiente de resultado
  bool _pendiente = false;

  PlantillasEquipamientoBloc get _bloc => context.read<PlantillasEquipamientoBloc>();

  Future<void> abrirPlantilla([PlantillaEquipamientoEntity? plantilla]) => _dialogo(
        PlantillaFormDialog(plantilla: plantilla),
      );

  Future<void> abrirItem(PlantillasEquipamientoState state, [PlantillaEquipamientoItemEntity? item]) => _dialogo(
        PlantillaItemFormDialog(plantillaId: state.plantillaId!, items: state.items, item: item),
      );

  Future<void> toggleItem(PlantillaEquipamientoItemEntity item) async {
    final bool activar = !item.activo;
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: activar ? 'Activar item' : 'Desactivar item',
      message: activar
          ? '"${item.productoNombre}" volverá a exigirse en todos los vehículos de la plantilla.'
          : '"${item.productoNombre}" dejará de exigirse. En los vehículos quedará como '
              '"Fuera de plantilla" conservando cantidades, caducidades y documentos.',
      confirmText: activar ? 'Activar' : 'Desactivar',
      icon: activar ? Icons.check_circle_outline : Icons.block,
      iconColor: activar ? AppColors.primary : AppColors.warning,
      confirmButtonColor: activar ? AppColors.primary : AppColors.warning,
    );
    if (ok == true) {
      _lanzar(PlantillaItemActivoRequested(itemId: item.id, activo: activar));
    }
  }

  Future<void> eliminarItem(PlantillaEquipamientoItemEntity item) async {
    final bool? ok = await showConfirmationDialog(
      context: context,
      title: 'Eliminar item de la plantilla',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Item': GestionFormatters.texto(item.productoNombre),
        'Sección': item.seccion,
        'Cantidad': '${item.cantidadRequerida}',
      },
      warningMessage: 'Las líneas de los vehículos se conservan como "Fuera de plantilla". '
          'Si solo quieres dejar de exigirlo, usa "Desactivar".',
      icon: Icons.delete_forever,
    );
    if (ok == true) {
      _lanzar(PlantillaItemDeleteRequested(item.id));
    }
  }

  Future<void> reaplicar(PlantillaEquipamientoEntity plantilla) async {
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Reaplicar plantilla',
      message: 'Se crearán las líneas que falten en los vehículos de tipo '
          '${plantilla.tiposVehiculo.join(', ')}. Las líneas existentes no se modifican.',
      confirmText: 'Reaplicar',
      icon: Icons.sync,
      iconColor: AppColors.primary,
      confirmButtonColor: AppColors.primary,
    );
    if (ok == true) {
      _lanzar(const PlantillaReaplicarRequested());
    }
  }

  /// Muestra el resultado de las operaciones lanzadas desde la vista
  void onResultado(BuildContext context, PlantillasEquipamientoState state) {
    if (!_pendiente) {
      return;
    }
    _pendiente = false;
    final bool ok = state.resultado == PlantillasResultado.exito;
    unawaited(showResultDialog(
      context: context,
      title: ok ? 'Operación completada' : 'Error en plantillas',
      message: ok ? (state.mensaje ?? 'Cambios guardados.') : 'No se pudo completar la operación.',
      details: ok ? null : state.error,
      type: ok ? ResultType.success : ResultType.error,
    ));
  }

  void _lanzar(PlantillasEquipamientoEvent event) {
    _pendiente = true;
    _bloc.add(event);
  }

  Future<void> _dialogo(Widget child) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<PlantillasEquipamientoBloc>.value(value: _bloc, child: child),
    );
  }
}
