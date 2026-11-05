import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_bloc.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_event.dart';
import 'package:ambutrack_web/features/taller/presentation/bloc/proveedor_taller_state.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/proveedor_taller_form_dialog.dart';
import 'package:ambutrack_web/features/taller/presentation/widgets/proveedor_taller_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión del Catálogo de Proveedores de Taller
class ProveedoresTallerPage extends StatelessWidget {
  const ProveedoresTallerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProveedorTallerBloc>(
        create: (BuildContext context) =>
            getIt<ProveedorTallerBloc>()
              ..add(const ProveedorTallerLoadRequested()),
        child: const _ProveedoresView(),
      ),
    );
  }
}

class _ProveedoresView extends StatelessWidget {
  const _ProveedoresView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
          AppSizes.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlocBuilder<ProveedorTallerBloc, ProveedorTallerState>(
              builder: (
                BuildContext context,
                ProveedorTallerState state,
              ) {
                final List<ProveedorTallerEntity> proveedores = state
                        is ProveedorTallerLoaded
                    ? state.proveedores
                    : <ProveedorTallerEntity>[];
                return PageHeader(
                  config: PageHeaderConfig(
                    icon: Icons.local_shipping,
                    title: 'Proveedores',
                    subtitle: 'Gestión de proveedores de repuestos y servicios',
                    addButtonLabel: 'Nuevo Proveedor',
                    stats: _buildStats(proveedores),
                    onAdd: () => _showFormDialog(context),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXl),
            const Expanded(child: ProveedorTallerTable()),
          ],
        ),
      ),
    );
  }

  List<HeaderStat> _buildStats(List<ProveedorTallerEntity> proveedores) {
    final int repuestos = proveedores
        .where(
            (ProveedorTallerEntity p) => p.tipo == TipoProveedor.repuestos)
        .length;
    final int servicios = proveedores
        .where(
            (ProveedorTallerEntity p) => p.tipo == TipoProveedor.servicios)
        .length;

    return <HeaderStat>[
      HeaderStat(
        value: proveedores.length.toString(),
        icon: Icons.local_shipping,
      ),
      HeaderStat(
        value: repuestos.toString(),
        icon: Icons.inventory_2_outlined,
        color: AppColors.info,
      ),
      HeaderStat(
        value: servicios.toString(),
        icon: Icons.miscellaneous_services_outlined,
        color: AppColors.secondary,
      ),
    ];
  }

  Future<void> _showFormDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<ProveedorTallerBloc>.value(
          value: context.read<ProveedorTallerBloc>(),
          child: const ProveedorTallerFormDialog(),
        );
      },
    );
  }
}
