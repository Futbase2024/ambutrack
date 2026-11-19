import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de personal (layout tipo programa de gestión)
class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PersonalBloc>(
        create: (BuildContext _) => getIt<PersonalBloc>()..add(const PersonalLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: PersonalGestionView(),
        ),
      ),
    );
  }
}
