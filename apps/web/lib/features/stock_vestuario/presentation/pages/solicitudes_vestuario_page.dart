import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/stock_vestuario/data/repositories/solicitudes_vestuario_repository_impl.dart';
import 'package:ambutrack_web/features/stock_vestuario/data/repositories/stock_vestuario_repository_impl.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/solicitudes_vestuario_cubit.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/gestion/solicitudes_vestuario/solicitudes_vestuario_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de solicitudes de vestuario: almacén gestiona lo que piden los técnicos
class SolicitudesVestuarioPage extends StatelessWidget {
  const SolicitudesVestuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<SolicitudesVestuarioCubit>(
        create: (BuildContext _) =>
            SolicitudesVestuarioCubit(SolicitudesVestuarioRepositoryImpl(), StockVestuarioRepositoryImpl())..cargar(),
        child: const Scaffold(backgroundColor: AppColors.backgroundLight, body: SolicitudesVestuarioGestionView()),
      ),
    );
  }
}
