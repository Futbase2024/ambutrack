import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_bloc.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_event.dart';
import 'package:ambutrack_web/features/almacen/presentation/bloc/proveedores/proveedores_state.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/proveedores_header.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/proveedores_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de Proveedores del Almacén
class ProveedoresPage extends StatelessWidget {
  const ProveedoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProveedoresBloc>.value(
        value: getIt<ProveedoresBloc>(),
        child: const _ProveedoresView(),
      ),
    );
  }
}

/// Vista principal de proveedores
class _ProveedoresView extends StatefulWidget {
  const _ProveedoresView();

  @override
  State<_ProveedoresView> createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<_ProveedoresView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos solo si el estado es Initial
    final ProveedoresBloc bloc = context.read<ProveedoresBloc>();
    if (bloc.state is ProveedoresInitial) {
      bloc.add(const ProveedoresLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header personalizado con estadísticas y botón agregar
            ProveedoresHeader(),
            SizedBox(height: AppSizes.spacingXl),

            // Tabla ocupa el espacio restante
            Expanded(child: ProveedoresTable()),
          ],
        ),
      ),
    );
  }
}
