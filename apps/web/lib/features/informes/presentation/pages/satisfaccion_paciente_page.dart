import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion_frame/gestion_frame.dart';
import 'package:ambutrack_web/features/informes/presentation/widgets/informe_sin_datos.dart';
import 'package:flutter/material.dart';

/// Informe de satisfacción del paciente.
///
/// Todavía no existe ninguna fuente de datos (encuestas) en Supabase, por lo
/// que se muestra un estado vacío explicativo. Propuesta de tablas y flujo en
/// `docs/plans/informes_satisfaccion_paciente.md`.
class SatisfaccionPacientePage extends StatelessWidget {
  const SatisfaccionPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: GestionFrame(
          toolbar: GestionToolbar(
            title: 'Satisfacción del Paciente',
            icon: Icons.sentiment_satisfied_alt_outlined,
            groups: <List<GestionToolbarAction>>[
              <GestionToolbarAction>[
                GestionToolbarAction(icon: Icons.refresh, label: 'Actualizar'),
                GestionToolbarAction(icon: Icons.print_outlined, label: 'Imprimir'),
              ],
            ],
          ),
          statusBar: GestionStatusBar(items: <String>['Sin fuente de datos de encuestas']),
          content: InformeSinDatos(
            icon: Icons.poll_outlined,
            title: 'Aún no hay datos de satisfacción',
            message: 'AmbuTrack todavía no registra encuestas ni valoraciones de los pacientes, '
                'por lo que este informe no puede calcularse. Para activarlo es necesario:',
            puntos: <String>[
              'Crear las tablas de encuestas y respuestas vinculadas a cada traslado finalizado.',
              'Habilitar la recogida de la valoración (SMS/e-mail tras el servicio o app móvil).',
              'Con respuestas, el informe mostrará puntuación media, NPS, tasa de respuesta y desglose.',
            ],
          ),
        ),
      ),
    );
  }
}
