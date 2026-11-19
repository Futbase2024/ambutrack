part of '../turno_form_dialog.dart';

/// Estado y manejadores del horario del turno (tipo, plantilla, fechas y horas).
mixin _TurnoFormHorario on State<TurnoFormDialog>, _TurnoFormCatalogos {
  late TextEditingController _horaInicioController;
  late TextEditingController _horaFinController;

  late FocusNode _horaInicioFocusNode;
  late FocusNode _horaFinFocusNode;

  TipoTurno _tipoTurno = TipoTurno.manana;
  @override
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();
  bool _isCustomTime = false;

  /// Listener para detectar cuando un campo de hora pierde el foco
  void _onHoraFocusChanged() {
    // Solo procesar cuando el campo pierde el foco
    if (_horaInicioFocusNode.hasFocus || _horaFinFocusNode.hasFocus) {
      return;
    }

    // Autoformatear las horas cuando pierden el foco
    final String horaInicioFormatted = TurnoFormUtils.formatTimeInput(_horaInicioController.text);
    final String horaFinFormatted = TurnoFormUtils.formatTimeInput(_horaFinController.text);

    if (horaInicioFormatted != _horaInicioController.text) {
      _horaInicioController.value = TextEditingValue(
        text: horaInicioFormatted,
        selection: TextSelection.collapsed(offset: horaInicioFormatted.length),
      );
    }

    if (horaFinFormatted != _horaFinController.text) {
      _horaFinController.value = TextEditingValue(
        text: horaFinFormatted,
        selection: TextSelection.collapsed(offset: horaFinFormatted.length),
      );
    }

    // Procesar ambos campos si tienen valores válidos
    final String horaInicio = _horaInicioController.text;
    final String horaFin = _horaFinController.text;

    // Validar formato básico HH:mm antes de procesar
    final RegExp regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(horaInicio) || !regex.hasMatch(horaFin)) {
      return;
    }

    // Detectar si cruza medianoche
    if (TurnoFormUtils.cruzaMedianoche(horaInicio, horaFin)) {
      if (_fechaFin == _fechaInicio || _fechaFin.isBefore(_fechaInicio.add(const Duration(days: 1)))) {
        setState(() {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
          debugPrint('🌙 Turno cruza medianoche: $horaInicio-$horaFin | Ajustando fechaFin');
        });
      }
    } else {
      if (_fechaFin != _fechaInicio) {
        setState(() {
          _fechaFin = _fechaInicio;
          debugPrint('☀️ Turno mismo día: $horaInicio-$horaFin');
        });
      }
    }
  }

  /// Selección de un tipo de turno (solo si no hay plantilla seleccionada)
  void _onTipoTurnoSelected(TipoTurno tipo) {
    setState(() {
      _tipoTurno = tipo;
      _isCustomTime = tipo == TipoTurno.personalizado;

      // Si no es personalizado, aplicar horas del tipo
      if (!_isCustomTime) {
        _horaInicioController.text = tipo.horaInicio;
        _horaFinController.text = tipo.horaFin;

        // Detectar si cruza medianoche
        if (TurnoFormUtils.cruzaMedianoche(tipo.horaInicio, tipo.horaFin)) {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
          debugPrint('🌙 Tipo de turno ${tipo.nombre} cruza medianoche | Ajustando fechaFin');
        } else {
          _fechaFin = _fechaInicio;
        }
      }

      // Limpiar plantilla seleccionada
      _idPlantillaSeleccionada = null;
    });
  }

  /// Selección de una plantilla de turno (aplica horas y tipo)
  void _onPlantillaChanged(String? id) {
    if (id == null) {
      setState(() {
        _idPlantillaSeleccionada = null;
      });
      return;
    }

    try {
      final PlantillaTurnoEntity plantilla = _plantillasDisponibles.firstWhere(
        (PlantillaTurnoEntity p) => p.id == id,
      );

      setState(() {
        _idPlantillaSeleccionada = id;
        _horaInicioController.text = plantilla.horaInicio;
        _horaFinController.text = plantilla.horaFin;

        if (TurnoFormUtils.cruzaMedianoche(plantilla.horaInicio, plantilla.horaFin)) {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
          debugPrint('🌙 Turno cruza medianoche: ${plantilla.nombre} | Ajustando fechaFin');
        } else {
          _fechaFin = _fechaInicio;
        }

        _tipoTurno = plantilla.tipoTurno;
        _isCustomTime = true;

        debugPrint('✅ Plantilla aplicada: ${plantilla.nombre} | Badges deshabilitados');
      });
    } catch (e) {
      debugPrint('❌ Error al seleccionar plantilla: $e');
    }
  }

  /// Auto-formatear cuando el usuario termina de editar (pierde foco o presiona Enter)
  void _onHoraEditingComplete(TextEditingController controller) {
    final String formatted = TurnoFormUtils.formatTimeInput(controller.text);
    if (formatted != controller.text) {
      controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Detectar si el turno cruza medianoche cuando se editan las horas manualmente
    if (_horaInicioController.text.isNotEmpty && _horaFinController.text.isNotEmpty) {
      if (TurnoFormUtils.cruzaMedianoche(_horaInicioController.text, _horaFinController.text)) {
        setState(() {
          _fechaFin = _fechaInicio.add(const Duration(days: 1));
          debugPrint(
            '🌙 Turno cruza medianoche: ${_horaInicioController.text}-${_horaFinController.text} | Ajustando fechaFin',
          );
        });
      } else if (_fechaFin != _fechaInicio) {
        setState(() {
          _fechaFin = _fechaInicio;
          debugPrint('☀️ Turno mismo día: ${_horaInicioController.text}-${_horaFinController.text}');
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isInicio}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
          // Si la fecha fin es anterior a la nueva fecha inicio, ajustarla
          if (_fechaFin.isBefore(_fechaInicio)) {
            _fechaFin = _fechaInicio;
          }
        } else {
          _fechaFin = picked;
        }
      });
    }
  }
}
