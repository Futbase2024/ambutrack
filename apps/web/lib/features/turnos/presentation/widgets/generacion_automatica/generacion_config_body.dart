import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/turnos/presentation/widgets/generacion_automatica/generacion_config_fields.dart';
import 'package:flutter/material.dart';

/// Valores editables de la configuración de generación automática
class GeneracionConfigValores {
  GeneracionConfigValores({required this.fechaInicio, required this.fechaFin});

  DateTime fechaInicio;
  DateTime fechaFin;
  List<PersonalEntity> personal = <PersonalEntity>[];
  List<String> personalSeleccionado = <String>[];

  // Configuración por defecto
  double horasMaximasSemanales = 40;
  double horasMaximasMensuales = 160;
  double horasMinimasDescanso = 12;
  int diasDescansoSemanal = 2;
  bool rotacionEquitativa = true;
  bool respetarPreferencias = true;
}

/// Cuerpo del formulario de configuración de la generación automática.
///
/// Modifica [valores] dentro de [onUpdate] (el `setState` del diálogo).
class GeneracionConfigBody extends StatelessWidget {
  const GeneracionConfigBody({required this.valores, required this.onUpdate, super.key});

  final GeneracionConfigValores valores;
  final ValueChanged<VoidCallback> onUpdate;

  static const double _labelWidth = 230;

  @override
  Widget build(BuildContext context) {
    final GeneracionConfigValores v = valores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Período de generación', first: true),
        GestionFormColumns(
          children: <Widget>[
            GestionFormRow(
              label: 'Fecha inicio',
              required: true,
              child: GestionDateField(
                value: v.fechaInicio,
                required: true,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onChanged: (DateTime? picked) {
                  if (picked != null) {
                    onUpdate(() => v.fechaInicio = picked);
                  }
                },
              ),
            ),
            GestionFormRow(
              label: 'Fecha fin',
              required: true,
              child: GestionDateField(
                value: v.fechaFin,
                required: true,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onChanged: (DateTime? picked) {
                  if (picked != null) {
                    onUpdate(() => v.fechaFin = picked);
                  }
                },
              ),
            ),
          ],
        ),
        const GestionFormSection(title: 'Personal a incluir'),
        GeneracionPersonalSelector(
          personal: v.personal,
          seleccionados: v.personalSeleccionado,
          onTodos: (bool value) => onUpdate(() {
            if (value) {
              v.personalSeleccionado = v.personal.map((PersonalEntity p) => p.id).toList();
            } else {
              v.personalSeleccionado.clear();
            }
          }),
          onPersona: (String id, {required bool seleccionar}) => onUpdate(() {
            if (seleccionar) {
              v.personalSeleccionado.add(id);
            } else {
              v.personalSeleccionado.remove(id);
            }
          }),
        ),
        const GestionFormSection(title: 'Restricciones legales'),
        GestionFormRow(
          label: 'Horas máximas semanales',
          labelWidth: _labelWidth,
          child: GeneracionSliderField(
            value: v.horasMaximasSemanales,
            min: 0,
            max: 60,
            onChanged: (double x) => onUpdate(() => v.horasMaximasSemanales = x),
          ),
        ),
        GestionFormRow(
          label: 'Horas máximas mensuales',
          labelWidth: _labelWidth,
          child: GeneracionSliderField(
            value: v.horasMaximasMensuales,
            min: 0,
            max: 200,
            onChanged: (double x) => onUpdate(() => v.horasMaximasMensuales = x),
          ),
        ),
        GestionFormRow(
          label: 'Horas mín. descanso entre turnos',
          labelWidth: _labelWidth,
          child: GeneracionSliderField(
            value: v.horasMinimasDescanso,
            min: 8,
            max: 24,
            onChanged: (double x) => onUpdate(() => v.horasMinimasDescanso = x),
          ),
        ),
        GestionFormRow(
          label: 'Días de descanso semanal',
          labelWidth: _labelWidth,
          child: GeneracionSliderField(
            value: v.diasDescansoSemanal.toDouble(),
            min: 1,
            max: 3,
            onChanged: (double x) => onUpdate(() => v.diasDescansoSemanal = x.toInt()),
          ),
        ),
        const GestionFormSection(title: 'Opciones avanzadas'),
        GestionFormRow(
          label: 'Rotación equitativa',
          labelWidth: _labelWidth,
          child: GestionSwitchField(
            value: v.rotacionEquitativa,
            text: 'Distribuir turnos de forma equitativa entre el personal',
            onChanged: (bool x) => onUpdate(() => v.rotacionEquitativa = x),
          ),
        ),
        GestionFormRow(
          label: 'Respetar preferencias',
          labelWidth: _labelWidth,
          child: GestionSwitchField(
            value: v.respetarPreferencias,
            text: 'Considerar preferencias de días y tipos de turno (si existen)',
            onChanged: (bool x) => onUpdate(() => v.respetarPreferencias = x),
          ),
        ),
      ],
    );
  }
}
