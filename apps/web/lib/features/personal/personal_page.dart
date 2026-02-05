import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/personal_header.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/personal_table_v4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de personal
class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PersonalBloc>.value(
        value: getIt<PersonalBloc>(),
        child: const _PersonalView(),
      ),
    );
  }
}

/// Vista principal de personal
class _PersonalView extends StatefulWidget {
  const _PersonalView();

  @override
  State<_PersonalView> createState() => _PersonalViewState();
}

class _PersonalViewState extends State<_PersonalView> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    debugPrint('⏱️ PersonalPage: Inicio de carga de página');

    // Solo cargar si está en estado inicial
    final PersonalBloc bloc = context.read<PersonalBloc>();
    if (bloc.state is PersonalInitial) {
      debugPrint('🚀 PersonalPage: Primera carga, solicitando personal...');
      bloc.add(const PersonalLoadRequested());
    } else if (bloc.state is PersonalLoaded) {
      final PersonalLoaded loadedState = bloc.state as PersonalLoaded;
      debugPrint('⚡ PersonalPage: Datos ya cargados (${loadedState.total} personas), reutilizando estado del BLoC');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageStartTime != null) {
          final Duration elapsed = DateTime.now().difference(_pageStartTime!);
          debugPrint('⏱️ Tiempo total de carga de página (con datos en caché): ${elapsed.inMilliseconds}ms');
          _pageStartTime = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalBloc, PersonalState>(
      listener: (BuildContext context, PersonalState state) {
        if (state is PersonalLoaded && _pageStartTime != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageStartTime != null) {
              final Duration elapsed = DateTime.now().difference(_pageStartTime!);
              debugPrint('⏱️ Tiempo total de carga de página (primera vez): ${elapsed.inMilliseconds}ms');
              _pageStartTime = null;
            }
          });
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header con stats integradas
              PersonalHeader(),
              SizedBox(height: AppSizes.spacingXl),

              // Tabla de personal con filtros integrados (v4 optimizada)
              Expanded(
                child: PersonalTableV4(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
