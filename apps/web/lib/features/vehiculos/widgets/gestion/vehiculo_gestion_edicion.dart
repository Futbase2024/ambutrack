import 'dart:async';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_bloc.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/bloc/vehiculos_event.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/flota_gestion_common.dart';
import 'package:ambutrack_web/features/vehiculos/widgets/gestion/vehiculo_gestion_columns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Máximo de matrículas que se listan en la confirmación de un cambio en bloque
const int _kMaxMatriculas = 10;

/// Modo edición de la rejilla de vehículos: cambios en la propia celda
/// (se guardan al momento) y cambios en bloque sobre los vehículos marcados.
mixin VehiculoEdicionMixin<W extends StatefulWidget> on State<W> {
  /// Modo edición activo
  bool editando = false;

  /// Ids de los vehículos marcados con la casilla
  Set<String> marcados = <String>{};

  /// Vehículos que se ven ahora en la rejilla (con búsqueda y filtros)
  List<VehiculoEntity> get vehiculosVisibles;

  /// Aplica el cambio en la lista local para que se vea al instante
  void aplicarLocal(List<VehiculoEntity> actualizados);

  /// Marcados que siguen visibles (los ocultos por un filtro no se cambian)
  List<VehiculoEntity> get marcadosVisibles =>
      vehiculosVisibles.where((VehiculoEntity v) => marcados.contains(v.id)).toList();

  void toggleEdicion() => setState(() {
        editando = !editando;
        marcados = <String>{};
      });

  /// Cambio de una celda (CAP, silla, estado, km, ubicación)
  void guardarCambio(VehiculoEntity actualizado) => unawaited(_guardarCambio(actualizado));

  Future<void> _guardarCambio(VehiculoEntity actualizado) async {
    VehiculoEntity? original;
    for (final VehiculoEntity v in vehiculosVisibles) {
      if (v.id == actualizado.id) {
        original = v;
      }
    }
    if (original == null || !await _confirmarCambio(original, actualizado) || !mounted) {
      return;
    }
    aplicarLocal(<VehiculoEntity>[actualizado]);
    // La silla eléctrica no es un campo del vehículo: se guarda en su stock
    final VehiculosEvent evento = actualizado.tieneSillaElectrica != original.tieneSillaElectrica
        ? VehiculosSillaElectricaRequested(
            vehiculoIds: <String>[actualizado.id],
            tiene: actualizado.tieneSillaElectrica,
          )
        : VehiculoUpdateRequested(vehiculo: actualizado);
    context.read<VehiculosBloc>().add(evento);
  }

  /// Pide confirmación para dar de baja o para bajar los kilómetros
  Future<bool> _confirmarCambio(VehiculoEntity original, VehiculoEntity actualizado) async {
    if (actualizado.estado == VehiculoEstado.baja && original.estado != VehiculoEstado.baja) {
      return await showSimpleConfirmationDialog(
            context: context,
            title: 'Dar de baja el vehículo',
            message: '¿Seguro que quieres pasar ${original.matricula} a "Baja"?\n\n'
                'Dejará de estar disponible para asignar servicios.',
            confirmText: 'Dar de baja',
            icon: Icons.block,
          ) ??
          false;
    }
    final double? kmAntes = original.kmActual;
    final double? kmDespues = actualizado.kmActual;
    if (kmAntes != null && kmDespues != null && kmDespues < kmAntes) {
      return await showSimpleConfirmationDialog(
            context: context,
            title: 'Kilómetros menores',
            message: 'Vas a cambiar los km de ${original.matricula} de ${flotaKm(kmAntes)} '
                'a ${flotaKm(kmDespues)}, que es menos que el valor actual.\n\n¿Es correcto?',
            confirmText: 'Guardar',
            icon: Icons.speed,
            iconColor: AppColors.warning,
            confirmButtonColor: AppColors.warning,
          ) ??
          false;
    }
    return true;
  }

  void cambiarEstadoEnBloque(VehiculoEstado estado) => unawaited(
        _cambiarEnBloque(
          descripcion: 'Poner en estado "${vehiculoEstadoLabel(estado)}"',
          critico: estado == VehiculoEstado.baja,
          cambio: (VehiculoEntity v) => v.copyWith(estado: estado),
        ),
      );

  void cambiarCapEnBloque({required bool valor}) => unawaited(
        _cambiarEnBloque(
          descripcion: valor ? 'Marcar CAP' : 'Quitar CAP',
          cambio: (VehiculoEntity v) => v.copyWith(requiereCap: valor),
        ),
      );

  void cambiarSoporteEnBloque({required bool valor}) => unawaited(
        _cambiarEnBloque(
          descripcion: valor ? 'Marcar soporte de silla eléctrica' : 'Quitar soporte de silla eléctrica',
          cambio: (VehiculoEntity v) => v.copyWith(tieneSoporteSillaElectrica: valor),
        ),
      );

  void cambiarCarrosEnBloque(int carros) => unawaited(
        _cambiarEnBloque(
          descripcion: 'Poner ${carros == 1 ? '1 carro' : '$carros carros'}',
          cambio: (VehiculoEntity v) => v.copyWith(numeroCarros: carros),
        ),
      );

  void cambiarSillaEnBloque({required bool valor}) => unawaited(
        _cambiarEnBloque(
          descripcion: valor
              ? 'Poner 1 silla eléctrica en el stock'
              : 'Dejar a 0 la silla eléctrica del stock',
          cambio: (VehiculoEntity v) => v.copyWith(tieneSillaElectrica: valor),
          evento: (List<VehiculoEntity> lista) => VehiculosSillaElectricaRequested(
            vehiculoIds: <String>[for (final VehiculoEntity v in lista) v.id],
            tiene: valor,
          ),
        ),
      );

  Future<void> _cambiarEnBloque({
    required String descripcion,
    required VehiculoEntity Function(VehiculoEntity v) cambio,
    VehiculosEvent Function(List<VehiculoEntity> actualizados)? evento,
    bool critico = false,
  }) async {
    final List<VehiculoEntity> lista = marcadosVisibles;
    if (lista.isEmpty) {
      return;
    }
    final Iterable<String> matriculas = lista.take(_kMaxMatriculas).map((VehiculoEntity v) => '• ${v.matricula}');
    final String resto = lista.length > _kMaxMatriculas ? '\n… y ${lista.length - _kMaxMatriculas} más' : '';
    final Color color = critico ? AppColors.error : AppColors.primary;
    final bool? ok = await showSimpleConfirmationDialog(
      context: context,
      title: 'Cambiar ${lista.length} ${lista.length == 1 ? 'vehículo' : 'vehículos'}',
      message: '$descripcion en:\n\n${matriculas.join('\n')}$resto',
      confirmText: 'Aplicar',
      icon: critico ? Icons.block : Icons.edit_note,
      iconColor: color,
      confirmButtonColor: color,
    );
    if (ok != true || !mounted) {
      return;
    }
    final List<VehiculoEntity> actualizados = lista.map(cambio).toList();
    aplicarLocal(actualizados);
    setState(() => marcados = <String>{});
    context
        .read<VehiculosBloc>()
        .add(evento?.call(actualizados) ?? VehiculosBulkUpdateRequested(vehiculos: actualizados));
  }
}
