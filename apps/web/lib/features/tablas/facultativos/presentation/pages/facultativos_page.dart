import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_header.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de facultativos
class FacultativosPage extends StatelessWidget {
  const FacultativosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FacultativoBloc>(
        create: (BuildContext context) => getIt<FacultativoBloc>()
          ..add(const FacultativoLoadAllRequested()),
        child: const _FacultativosView(),
      ),
    );
  }
}

class _FacultativosView extends StatelessWidget {
  const _FacultativosView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header con título y botón agregar
          FacultativoHeader(),
          SizedBox(height: AppSizes.spacingLarge),

          // Tabla con datos
          Expanded(
            child: FacultativoTable(),
          ),
        ],
      ),
    );
  }
}
