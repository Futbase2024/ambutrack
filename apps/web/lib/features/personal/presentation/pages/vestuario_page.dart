import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/vestuario_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/vestuario/vestuario_gestion_view.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_bloc.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/bloc/stock_vestuario_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Vestuario del Personal (layout tipo programa de gestión)
class VestuarioPage extends StatelessWidget {
  const VestuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VestuarioBloc>(
            create: (BuildContext _) =>
                getIt<VestuarioBloc>()..add(const VestuarioLoadRequested()),
          ),
          BlocProvider<PersonalBloc>(
            create: (BuildContext _) =>
                getIt<PersonalBloc>()..add(const PersonalLoadRequested()),
          ),
          // Stock cargado SIEMPRE para poder devolver vestuario al eliminar
          BlocProvider<StockVestuarioBloc>(
            create: (BuildContext _) =>
                getIt<StockVestuarioBloc>()..add(const StockVestuarioLoadRequested()),
          ),
        ],
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: VestuarioGestionView(),
        ),
      ),
    );
  }
}
