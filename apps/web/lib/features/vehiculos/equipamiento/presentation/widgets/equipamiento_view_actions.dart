import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/auth/enums/user_role.dart';
import 'package:ambutrack_web/core/auth/services/role_service.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/domain/repositories/equipamiento_vehiculo_repository.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_event.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/bloc/equipamiento_vehiculo_state.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_adjuntos.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_columns.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_detail_panel.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_extra_form_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/equipamiento/presentation/widgets/equipamiento_linea_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Acciones de la pantalla de equipamiento (diálogos, confirmaciones y adjuntos)
mixin EquipamientoViewActions<T extends StatefulWidget> on State<T> {
  /// Operación lanzada desde la vista (no desde un formulario) pendiente de resultado
  bool _pendiente = false;

  /// Admin y jefe de mantenimiento pueden excluir items y gestionar extras
  late final bool puedeGestionar = _calcularPermiso();

  bool _calcularPermiso() {
    final UserRole rol = getIt<RoleService>().getCurrentUserRoleSync();
    return rol == UserRole.admin || rol == UserRole.jefeMantenimiento;
  }

  EquipamientoVehiculoBloc get _bloc => context.read<EquipamientoVehiculoBloc>();

  /// Acciones disponibles para la línea seleccionada
  EquipamientoAcciones accionesPara(StockVehiculoEntity? l) {
    if (l == null) {
      return const EquipamientoAcciones();
    }
    return EquipamientoAcciones(
      onRegistrar: l.excluido ? null : () => abrirRegistro(l),
      onAdjuntar: l.excluido ? null : () => adjuntar(l),
      onVerAdjunto: l.tieneAdjunto ? () => verAdjunto(l) : null,
      onQuitarAdjunto: l.tieneAdjunto && !l.excluido ? () => quitarAdjunto(l) : null,
      onExcluir: puedeGestionar && l.esDePlantilla ? () => excluir(l) : null,
      onEliminarExtra: puedeGestionar && !l.esDePlantilla ? () => eliminarExtra(l) : null,
    );
  }

  Future<void> abrirRegistro(StockVehiculoEntity l) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<EquipamientoVehiculoBloc>.value(
        value: _bloc,
        child: EquipamientoLineaFormDialog(linea: l),
      ),
    );
  }

  Future<void> abrirExtra(List<StockVehiculoEntity> lineas) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => BlocProvider<EquipamientoVehiculoBloc>.value(
        value: _bloc,
        child: EquipamientoExtraFormDialog(
          productosEnVehiculo: lineas.map((StockVehiculoEntity l) => l.productoId).toSet(),
        ),
      ),
    );
  }

  Future<void> adjuntar(StockVehiculoEntity l) async {
    final AdjuntoSeleccionado? archivo = await elegirAdjunto(context);
    if (archivo == null || !mounted) {
      return;
    }
    _lanzar(EquipamientoAdjuntoUploadRequested(
      id: l.id,
      bytes: archivo.bytes,
      fileName: archivo.nombre,
      contentType: archivo.contentType,
    ));
  }

  Future<void> verAdjunto(StockVehiculoEntity l) async {
    try {
      abrirEnPestana(await getIt<EquipamientoVehiculoRepository>().getUrlAdjunto(l.documentoPath!));
    } catch (e) {
      if (mounted) {
        await _mostrarError('No se pudo abrir el documento.', e.toString());
      }
    }
  }

  Future<void> quitarAdjunto(StockVehiculoEntity l) async {
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Quitar documento',
      message: '¿Quitar "${l.documentoNombre ?? 'documento'}" de ${l.productoNombre ?? 'este item'}?',
      confirmText: 'Quitar',
      icon: Icons.link_off,
    );
    if (ok == true) {
      _lanzar(EquipamientoAdjuntoDeleteRequested(l.id));
    }
  }

  Future<void> excluir(StockVehiculoEntity l) async {
    final bool incluir = l.excluido;
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: incluir ? 'Volver a incluir item' : 'Excluir item del vehículo',
      message: incluir
          ? '"${l.productoNombre}" volverá a exigirse en la dotación de este vehículo.'
          : '"${l.productoNombre}" dejará de exigirse en este vehículo. '
              'El resto de vehículos no se ven afectados.',
      confirmText: incluir ? 'Incluir' : 'Excluir',
      icon: incluir ? Icons.undo : Icons.block,
      iconColor: incluir ? AppColors.primary : AppColors.warning,
      confirmButtonColor: incluir ? AppColors.primary : AppColors.warning,
    );
    if (ok == true) {
      _lanzar(EquipamientoExcluirRequested(id: l.id, excluido: !incluir));
    }
  }

  Future<void> eliminarExtra(StockVehiculoEntity l) async {
    final bool? ok = await showConfirmationDialog(
      context: context,
      title: 'Eliminar item extra',
      message: 'Esta acción es permanente y no se puede deshacer.',
      itemDetails: <String, String>{
        'Item': GestionFormatters.texto(l.productoNombre),
        'Cantidad': '${l.cantidadActual}',
        'Lote': GestionFormatters.texto(l.lote),
      },
      icon: Icons.delete_forever,
    );
    if (ok == true) {
      _lanzar(EquipamientoExtraDeleteRequested(l.id));
    }
  }

  /// Muestra el resultado de las operaciones lanzadas desde la vista
  void onResultado(BuildContext context, EquipamientoVehiculoState state) {
    if (!_pendiente) {
      return;
    }
    _pendiente = false;
    if (state.resultado == EquipamientoResultado.exito) {
      unawaited(showResultDialog(
        context: context,
        title: 'Operación completada',
        message: state.mensaje ?? 'Cambios guardados.',
        type: ResultType.success,
      ));
    } else if (state.resultado == EquipamientoResultado.error) {
      unawaited(_mostrarError('No se pudo completar la operación.', state.error));
    }
  }

  Future<void> imprimir(List<StockVehiculoEntity> lineas, String titulo) =>
      imprimirEquipamiento(lineas, titulo);

  void _lanzar(EquipamientoVehiculoEvent event) {
    _pendiente = true;
    _bloc.add(event);
  }

  Future<void> _mostrarError(String mensaje, String? detalle) {
    return showResultDialog(
      context: context,
      title: 'Error en equipamiento',
      message: mensaje,
      details: detalle,
      type: ResultType.error,
    );
  }
}
