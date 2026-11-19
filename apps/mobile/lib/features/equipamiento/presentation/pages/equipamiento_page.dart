import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vehiculo/presentation/bloc/vehiculo_asignado/vehiculo_asignado_bloc.dart';
import '../../../vehiculo/presentation/bloc/vehiculo_asignado/vehiculo_asignado_event.dart';
import '../../../vehiculo/presentation/bloc/vehiculo_asignado/vehiculo_asignado_state.dart';
import '../bloc/equipamiento_bloc.dart';
import '../bloc/equipamiento_event.dart';
import '../bloc/equipamiento_state.dart';
import '../widgets/equipamiento_lista.dart';

/// Dotación (equipamiento + documentación) del vehículo asignado al técnico
class EquipamientoPage extends StatelessWidget {
  const EquipamientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VehiculoAsignadoBloc>(
          create: (BuildContext _) => getIt<VehiculoAsignadoBloc>()..add(const LoadVehiculoAsignado()),
        ),
        BlocProvider<EquipamientoBloc>(create: (BuildContext _) => getIt<EquipamientoBloc>()),
      ],
      child: const _EquipamientoView(),
    );
  }
}

class _EquipamientoView extends StatelessWidget {
  const _EquipamientoView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiculoAsignadoBloc, VehiculoAsignadoState>(
      listener: (BuildContext context, VehiculoAsignadoState state) {
        if (state is VehiculoAsignadoLoaded) {
          context.read<EquipamientoBloc>().add(EquipamientoLoadRequested(state.vehiculo.id));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: const Text('Equipamiento', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        body: const SafeArea(child: _Contenido()),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final VehiculoAsignadoState vState = context.watch<VehiculoAsignadoBloc>().state;
    if (vState is VehiculoAsignadoEmpty) {
      return const _Aviso(
        icon: Icons.no_transfer_rounded,
        titulo: 'Sin vehículo asignado',
        texto: 'No tienes un vehículo asignado en tu turno de hoy.',
      );
    }
    if (vState is VehiculoAsignadoError) {
      return _Aviso(icon: Icons.error_outline, titulo: 'Error', texto: vState.message);
    }
    if (vState is! VehiculoAsignadoLoaded) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return BlocBuilder<EquipamientoBloc, EquipamientoState>(
      builder: (BuildContext context, EquipamientoState state) {
        if (state.status == EquipamientoStatus.failure && state.lineas.isEmpty) {
          return _Aviso(icon: Icons.error_outline, titulo: 'Error al cargar', texto: state.error ?? '');
        }
        if (state.status != EquipamientoStatus.loaded && state.lineas.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state.lineas.isEmpty) {
          return const _Aviso(
            icon: Icons.inventory_2_outlined,
            titulo: 'Sin plantilla de equipamiento',
            texto: 'Este vehículo todavía no tiene dotación asignada para su tipo.',
          );
        }
        return EquipamientoLista(
          matricula: vState.vehiculo.matricula,
          lineas: state.lineas,
          onRefresh: () async =>
              context.read<EquipamientoBloc>().add(EquipamientoLoadRequested(vState.vehiculo.id)),
        );
      },
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icon, required this.titulo, required this.texto});

  final IconData icon;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.gray600)),
          ],
        ),
      ),
    );
  }
}
