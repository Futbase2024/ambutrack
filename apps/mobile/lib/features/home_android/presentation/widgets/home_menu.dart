import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/menu/app_menu.dart';

/// Menú principal de la home agrupado por secciones.
///
/// Turno siempre está disponible; el resto requiere el turno iniciado.
class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key, required this.turnoActivo});

  final bool turnoActivo;

  static const String _requiereTurno = 'Disponible con el turno iniciado';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AppMenuSeccion('Mi jornada'),
        AppMenuGrupo(
          opciones: <AppMenuOpcion>[
            AppMenuOpcion(
              icon: Icons.schedule_rounded,
              color: AppColors.secondary,
              titulo: 'Turno',
              descripcion: turnoActivo
                  ? 'Consulta tu jornada o registra la salida'
                  : 'Registra la entrada para comenzar tu turno',
              badge: turnoActivo ? 'En servicio' : null,
              badgeColor: AppColors.success,
              onTap: () => context.push('/registro-horario'),
            ),
            AppMenuOpcion(
              icon: Icons.local_hospital_outlined,
              color: AppColors.primary,
              titulo: 'Servicios',
              descripcion: 'Traslados asignados y su seguimiento',
              descripcionDeshabilitada: _requiereTurno,
              enabled: turnoActivo,
              onTap: () => context.push('/servicios'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const AppMenuSeccion('Gestión'),
        AppMenuGrupo(
          opciones: <AppMenuOpcion>[
            AppMenuOpcion(
              icon: Icons.airport_shuttle_outlined,
              color: AppColors.info,
              titulo: 'Vehículo',
              descripcion: 'Checklists, equipamiento y caducidades',
              descripcionDeshabilitada: _requiereTurno,
              enabled: turnoActivo,
              onTap: () => context.push('/vehiculo'),
            ),
            AppMenuOpcion(
              icon: Icons.description_outlined,
              color: AppColors.warning,
              titulo: 'Trámites',
              descripcion: 'Vacaciones, permisos y ausencias',
              descripcionDeshabilitada: _requiereTurno,
              enabled: turnoActivo,
              onTap: () => context.push('/tramites'),
            ),
            AppMenuOpcion(
              icon: Icons.checkroom_outlined,
              color: AppColors.highPriority,
              titulo: 'Vestuario',
              descripcion: 'Uniformidad y solicitudes de prendas',
              descripcionDeshabilitada: _requiereTurno,
              enabled: turnoActivo,
              onTap: () => context.push('/vestuario'),
            ),
          ],
        ),
      ],
    );
  }
}
