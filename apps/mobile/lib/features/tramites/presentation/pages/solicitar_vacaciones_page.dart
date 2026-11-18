import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vacaciones_bloc.dart';
import '../bloc/vacaciones_event.dart';
import '../bloc/vacaciones_state.dart';
import '../widgets/form/fechas_rango_selector.dart';
import '../widgets/form/tramite_boton_enviar.dart';
import '../widgets/form/tramite_form_seccion.dart';

/// Formulario para solicitar vacaciones
class SolicitarVacacionesPage extends StatefulWidget {
  const SolicitarVacacionesPage({super.key});

  @override
  State<SolicitarVacacionesPage> createState() => _SolicitarVacacionesPageState();
}

class _SolicitarVacacionesPageState extends State<SolicitarVacacionesPage> {
  final TextEditingController _observacionesController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  void _enviar() {
    final DateTime? inicio = _fechaInicio;
    final DateTime? fin = _fechaFin;
    if (inicio == null || fin == null) {
      TramiteDialogos.faltaDato(context, 'Selecciona las fechas de inicio y fin de tus vacaciones.');
      return;
    }

    final AuthState authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) {
      TramiteDialogos.error(context, 'No se pudo obtener la información de tu usuario. Vuelve a iniciar sesión.');
      return;
    }

    final String observaciones = _observacionesController.text.trim();
    context.read<VacacionesBloc>().add(
          VacacionesCreateRequested(
            VacacionesEntity(
              id: const Uuid().v4(),
              idPersonal: authState.personal!.id,
              fechaInicio: inicio,
              fechaFin: fin,
              diasSolicitados: FechasRangoSelector.diasEntre(inicio, fin),
              estado: 'pendiente',
              observaciones: observaciones.isEmpty ? null : observaciones,
              fechaSolicitud: DateTime.now(),
              activo: true,
            ),
          ),
        );
  }

  void _onEstado(BuildContext context, VacacionesState state) {
    if (state is VacacionCreated) {
      TramiteDialogos.enviada(
        context,
        'Tu solicitud de vacaciones se ha enviado y está pendiente de aprobación.',
      );
    } else if (state is VacacionesError) {
      TramiteDialogos.error(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VacacionesBloc, VacacionesState>(
      listener: _onEstado,
      builder: (context, state) {
        final bool enviando = state is VacacionesLoading;

        return Scaffold(
          backgroundColor: AppColors.gray50,
          appBar: AppBar(
            title: const Text('Solicitar vacaciones'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBar: TramiteBotonEnviar(onPressed: _enviar, enviando: enviando),
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              children: <Widget>[
                TramiteFormSeccion(
                  titulo: 'Periodo',
                  obligatorio: true,
                  padding: EdgeInsets.zero,
                  child: FechasRangoSelector(
                    inicio: _fechaInicio,
                    fin: _fechaFin,
                    primeraFecha: DateUtils.dateOnly(DateTime.now()),
                    enabled: !enviando,
                    onChanged: (inicio, fin) => setState(() {
                      _fechaInicio = inicio;
                      _fechaFin = fin;
                    }),
                  ),
                ),
                TramiteFormSeccion(
                  titulo: 'Observaciones',
                  child: TramiteCampoTexto(
                    controller: _observacionesController,
                    hint: 'Añade cualquier información para tu responsable (opcional)',
                    enabled: !enviando,
                  ),
                ),
                const TramiteAviso(
                  texto: 'Tu responsable revisará la solicitud. Podrás consultar su estado en Mis trámites.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
