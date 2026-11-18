import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/ausencias_bloc.dart';
import '../bloc/ausencias_event.dart';
import '../bloc/ausencias_state.dart';
import '../widgets/form/fechas_rango_selector.dart';
import '../widgets/form/tipo_ausencia_selector.dart';
import '../widgets/form/tramite_boton_enviar.dart';
import '../widgets/form/tramite_form_seccion.dart';

/// Formulario para solicitar ausencias (baja médica, permisos, etc.)
class SolicitarAusenciaPage extends StatefulWidget {
  const SolicitarAusenciaPage({this.tipoPreseleccionado, super.key});

  /// Clave del tipo a marcar al abrir: 'baja_medica', 'permiso_personal'…
  final String? tipoPreseleccionado;

  @override
  State<SolicitarAusenciaPage> createState() => _SolicitarAusenciaPageState();
}

class _SolicitarAusenciaPageState extends State<SolicitarAusenciaPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  /// Se guardan aparte para no perderlos mientras el bloc recarga
  List<TipoAusenciaEntity> _tipos = <TipoAusenciaEntity>[];
  TipoAusenciaEntity? _tipoSeleccionado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final AusenciasBloc bloc = context.read<AusenciasBloc>();
    _actualizarTipos(bloc.state);
    bloc.add(const TiposAusenciaLoadRequested());
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  String get _titulo => switch (widget.tipoPreseleccionado) {
        'baja_medica' => 'Baja médica',
        'permiso_personal' => 'Permiso personal',
        _ => 'Solicitar ausencia',
      };

  void _actualizarTipos(AusenciasState state) {
    final List<TipoAusenciaEntity> tipos = switch (state) {
      AusenciasLoaded() => state.tiposAusencia,
      TiposAusenciaLoaded() => state.tipos,
      _ => const <TipoAusenciaEntity>[],
    };
    if (tipos.isEmpty) {
      return;
    }
    _tipos = tipos;
    _tipoSeleccionado ??= TipoAusenciaSelector.buscarPorClave(tipos, widget.tipoPreseleccionado);
  }

  void _enviar() {
    final TipoAusenciaEntity? tipo = _tipoSeleccionado;
    final DateTime? inicio = _fechaInicio;
    final DateTime? fin = _fechaFin;
    if (tipo == null) {
      TramiteDialogos.faltaDato(context, 'Selecciona el tipo de ausencia que quieres solicitar.');
      return;
    }
    if (inicio == null || fin == null) {
      TramiteDialogos.faltaDato(context, 'Selecciona las fechas de inicio y fin de la ausencia.');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthState authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.personal == null) {
      TramiteDialogos.error(context, 'No se pudo obtener la información de tu usuario. Vuelve a iniciar sesión.');
      return;
    }

    final String observaciones = _observacionesController.text.trim();
    setState(() => _enviando = true);
    context.read<AusenciasBloc>().add(
          AusenciaCreateRequested(
            AusenciaEntity(
              id: const Uuid().v4(),
              idPersonal: authState.personal!.id,
              idTipoAusencia: tipo.id,
              fechaInicio: inicio,
              fechaFin: fin,
              motivo: _motivoController.text.trim(),
              estado: EstadoAusencia.pendiente,
              observaciones: observaciones.isEmpty ? null : observaciones,
              activo: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ),
        );
  }

  void _onEstado(BuildContext context, AusenciasState state) {
    setState(() {
      _actualizarTipos(state);
      if (state is AusenciaCreated || state is AusenciasError) {
        _enviando = false;
      }
    });
    if (state is AusenciaCreated) {
      TramiteDialogos.enviada(context, 'Tu solicitud de ausencia se ha enviado y está pendiente de aprobación.');
    } else if (state is AusenciasError) {
      TramiteDialogos.error(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AusenciasBloc, AusenciasState>(
      listener: _onEstado,
      builder: (context, state) {
        final bool enviando = _enviando;
        final TipoAusenciaEntity? tipo = _tipoSeleccionado;

        return Scaffold(
          backgroundColor: AppColors.gray50,
          appBar: AppBar(
            title: Text(_titulo),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBar: TramiteBotonEnviar(onPressed: _enviar, enviando: enviando),
          body: SafeArea(
            bottom: false,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: <Widget>[
                  TramiteFormSeccion(
                    titulo: 'Tipo de ausencia',
                    obligatorio: true,
                    padding: EdgeInsets.zero,
                    child: TipoAusenciaSelector(
                      tipos: _tipos,
                      seleccionado: tipo,
                      cargando: _tipos.isEmpty && state is! AusenciasError,
                      enabled: !enviando,
                      onChanged: (t) => setState(() => _tipoSeleccionado = t),
                    ),
                  ),
                  TramiteFormSeccion(
                    titulo: 'Periodo',
                    obligatorio: true,
                    padding: EdgeInsets.zero,
                    child: FechasRangoSelector(
                      inicio: _fechaInicio,
                      fin: _fechaFin,
                      primeraFecha: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 30)),
                      enabled: !enviando,
                      onChanged: (inicio, fin) => setState(() {
                        _fechaInicio = inicio;
                        _fechaFin = fin;
                      }),
                    ),
                  ),
                  TramiteFormSeccion(
                    titulo: 'Motivo',
                    obligatorio: true,
                    child: TramiteCampoTexto(
                      controller: _motivoController,
                      hint: 'Describe brevemente el motivo de la ausencia',
                      enabled: !enviando,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica el motivo de la ausencia' : null,
                    ),
                  ),
                  TramiteFormSeccion(
                    titulo: 'Observaciones',
                    child: TramiteCampoTexto(
                      controller: _observacionesController,
                      hint: 'Información adicional para tu responsable (opcional)',
                      enabled: !enviando,
                    ),
                  ),
                  if (tipo != null && tipo.requiereDocumento)
                    const TramiteAviso(
                      texto: 'Este tipo de ausencia requiere aportar un justificante.',
                      color: AppColors.warning,
                      icon: Icons.description_outlined,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
