import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/domain/entities/personal_con_turnos_entity.dart';
import 'package:ambutrack_web/features/cuadrante/cuadrante_module/presentation/widgets/form/copiar_semana_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Resultado del diálogo de copiar semana
class CopiarSemanaResult {
  const CopiarSemanaResult({
    required this.semanaDestino,
    this.idPersonal,
  });

  final String semanaDestino;
  final List<String>? idPersonal; // null = todos, lista = varios seleccionados
}

/// Diálogo para copiar turnos de la semana actual a otra semana
class CopiarSemanaDialog extends StatefulWidget {
  const CopiarSemanaDialog({
    required this.semanaActual,
    required this.personalConTurnos,
    super.key,
  });

  /// Fecha de inicio de la semana actual
  final DateTime semanaActual;

  /// Lista de personal disponible
  final List<PersonalConTurnosEntity> personalConTurnos;

  @override
  State<CopiarSemanaDialog> createState() => _CopiarSemanaDialogState();
}

class _CopiarSemanaDialogState extends State<CopiarSemanaDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DateFormat _formatter = DateFormat('d MMM', 'es_ES');

  String? _semanaDestinoSeleccionada;
  CopiarSemanaModo _modoSeleccion = CopiarSemanaModo.todos;
  String? _personalSeleccionado; // Para modo "uno"
  final Set<String> _personalSeleccionadoVarios = <String>{}; // Para modo "varios"
  final List<GestionOption<String>> _semanasDisponibles = <GestionOption<String>>[];

  @override
  void initState() {
    super.initState();
    _generarSemanasDisponibles();
  }

  /// Genera lista de las próximas 8 semanas disponibles
  void _generarSemanasDisponibles() {
    for (int i = 1; i <= 8; i++) {
      final DateTime inicioSemana = widget.semanaActual.add(Duration(days: 7 * i));
      _semanasDisponibles.add(
        GestionOption<String>(inicioSemana.toIso8601String(), _rango(inicioSemana), color: AppColors.primary),
      );
    }
  }

  String _rango(DateTime inicio) =>
      '${_formatter.format(inicio)} - ${_formatter.format(inicio.add(const Duration(days: 6)))}';

  void _cambiarModo(CopiarSemanaModo modo) {
    setState(() {
      _modoSeleccion = modo;
      // Limpiar selecciones al cambiar de modo
      _personalSeleccionado = null;
      _personalSeleccionadoVarios.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestionFormDialog(
      title: 'Copiar semana de turnos',
      subtitle: _rango(widget.semanaActual),
      icon: Icons.content_copy,
      size: GestionFormSize.small,
      formKey: _formKey,
      saveLabel: 'Copiar semana',
      onSave: _confirmar,
      children: <Widget>[
        const GestionFormSection(title: 'Origen y destino', first: true),
        GestionFormRow(
          label: 'Semana origen',
          child: GestionFormReadOnly(value: _rango(widget.semanaActual)),
        ),
        GestionFormRow(
          label: 'Semana destino',
          required: true,
          child: GestionDropdownField<String>(
            value: _semanaDestinoSeleccionada,
            options: _semanasDisponibles,
            required: true,
            hint: 'Selecciona la semana destino',
            onChanged: (String? value) => setState(() => _semanaDestinoSeleccionada = value),
          ),
        ),
        const GestionFormSection(title: 'Trabajadores'),
        GestionFormRow(
          label: 'Copiar',
          child: CopiarSemanaModoSelector(modo: _modoSeleccion, onChanged: _cambiarModo),
        ),
        if (_modoSeleccion == CopiarSemanaModo.uno)
          GestionFormRow(
            label: 'Trabajador',
            required: true,
            child: GestionSearchField<String>(
              value: _personalSeleccionado,
              required: true,
              hint: 'Selecciona un trabajador',
              options: widget.personalConTurnos
                  .map((PersonalConTurnosEntity p) => GestionOption<String>(p.personal.id, p.personal.nombreCompleto))
                  .toList(),
              onChanged: (String? value) => setState(() => _personalSeleccionado = value),
            ),
          ),
        if (_modoSeleccion == CopiarSemanaModo.varios)
          GestionFormRow(
            label: 'Trabajadores',
            required: true,
            multiline: true,
            child: CopiarSemanaPersonalChecklist(
              personal: widget.personalConTurnos,
              seleccionados: _personalSeleccionadoVarios,
              onChanged: () => setState(() {}),
            ),
          ),
        if (_semanaDestinoSeleccionada != null) const CopiarSemanaAviso(),
      ],
    );
  }

  bool _puedeConfirmar() {
    if (_semanaDestinoSeleccionada == null) {
      return false;
    }

    switch (_modoSeleccion) {
      case CopiarSemanaModo.todos:
        return true;
      case CopiarSemanaModo.uno:
        return _personalSeleccionado != null;
      case CopiarSemanaModo.varios:
        return _personalSeleccionadoVarios.isNotEmpty;
    }
  }

  void _confirmar() {
    final bool valido = _formKey.currentState?.validate() ?? false;
    if (!valido || !_puedeConfirmar()) {
      return;
    }

    List<String>? idPersonal;

    switch (_modoSeleccion) {
      case CopiarSemanaModo.todos:
        idPersonal = null; // null = todos
      case CopiarSemanaModo.uno:
        idPersonal = _personalSeleccionado != null ? <String>[_personalSeleccionado!] : null;
      case CopiarSemanaModo.varios:
        idPersonal = _personalSeleccionadoVarios.toList();
    }

    debugPrint(
      '📋 CopiarSemanaDialog: destino $_semanaDestinoSeleccionada, personal: ${idPersonal?.length ?? 'todos'}',
    );
    Navigator.of(context).pop(
      CopiarSemanaResult(
        semanaDestino: _semanaDestinoSeleccionada!,
        idPersonal: idPersonal,
      ),
    );
  }
}
