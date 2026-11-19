import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/geolocalizacion/domain/repositories/geolocalizacion_repository.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/bloc/geolocalizacion_cubit.dart';
import 'package:ambutrack_web/features/geolocalizacion/presentation/widgets/geolocalizacion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Geolocalización en tiempo real de la flota
class GeolocalizacionPage extends StatelessWidget {
  const GeolocalizacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<GeolocalizacionCubit>(
        create: (BuildContext _) => GeolocalizacionCubit(getIt<GeolocalizacionRepository>())..iniciar(),
        child: const Scaffold(backgroundColor: AppColors.backgroundLight, body: GeolocalizacionView()),
      ),
    );
  }
}
