import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/theme/app_text_styles.dart';
import 'package:ambutrack_web/core/widgets/dropdowns/app_searchable_dropdown.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/tipo_ubicacion.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/models/trayecto_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card de trayecto individual
class TrayectoCardWidget extends StatefulWidget {
  const TrayectoCardWidget({
    required this.index,
    required this.trayecto,
    required this.loadingCentros,
    required this.centrosHospitalarios,
    required this.centrosDropdownItems,
    required this.pacienteNombreCompleto,
    required this.canDelete,
    required this.onDelete,
    required this.onUpdate,
    required this.onAplicarCentroATodos,
    super.key,
  });

  final int index;
  final TrayectoData trayecto;
  final bool loadingCentros;
  final List<CentroHospitalarioEntity> centrosHospitalarios;
  final List<AppSearchableDropdownItem<CentroHospitalarioEntity>> centrosDropdownItems;
  final String? pacienteNombreCompleto;
  final bool canDelete;
  final VoidCallback onDelete;
  final void Function(TrayectoData) onUpdate;
  final void Function(String centroNombre) onAplicarCentroATodos;

  @override
  State<TrayectoCardWidget> createState() => _TrayectoCardWidgetState();
}

class _TrayectoCardWidgetState extends State<TrayectoCardWidget> {
  late TrayectoData _trayecto;
  bool _isShowingDialog = false;

  @override
  void initState() {
    super.initState();
    _trayecto = widget.trayecto;
  }

  @override
  void didUpdateWidget(TrayectoCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar estado local cuando el widget padre cambia los datos
    // Forzamos actualización porque TrayectoData no tiene == implementado
    debugPrint('🔄 TrayectoCardWidget [${widget.index}]: Actualizando con nuevos datos');
    debugPrint('   - Origen Centro: ${widget.trayecto.origenCentro}');
    debugPrint('   - Destino Centro: ${widget.trayecto.destinoCentro}');
    setState(() {
      _trayecto = widget.trayecto;
    });
  }

  void _updateField(void Function() update) {
    setState(() {
      update();
    });
    widget.onUpdate(_trayecto);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Trayecto ${widget.index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (widget.canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: widget.onDelete,
                  tooltip: 'Eliminar trayecto',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Layout vertical: Primero títulos y botones, luego campos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Fila de títulos y botones
              Row(
                children: <Widget>[
                  // === ORIGEN - Solo título y botones ===
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Origen *',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildUbicacionButtons(
                          tipoActual: _trayecto.tipoOrigen,
                          onTipoChanged: (TipoUbicacion tipo) => _updateField(() => _trayecto.tipoOrigen = tipo),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // === DESTINO - Solo título y botones ===
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Destino *',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildUbicacionButtons(
                          tipoActual: _trayecto.tipoDestino,
                          onTipoChanged: (TipoUbicacion tipo) => _updateField(() => _trayecto.tipoDestino = tipo),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // === HORA - Solo título ===
                  SizedBox(
                    width: 130,
                    child: Text(
                      'Hora *',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fila de campos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // === ORIGEN - Campo ===
                  Expanded(
                    child: _buildUbicacionField(
                      esOrigen: true,
                      tipoUbicacion: _trayecto.tipoOrigen,
                      tipoUbicacionContraria: _trayecto.tipoDestino,
                      domicilio: _trayecto.origenDomicilio,
                      centroNombre: _trayecto.origenCentro,
                      ubicacionEnCentro: _trayecto.origenUbicacionEnCentro,
                      onDomicilioChanged: (String? value) => _updateField(() => _trayecto.origenDomicilio = value),
                      onCentroChanged: (String? nombre) => _updateField(() => _trayecto.origenCentro = nombre),
                      onUbicacionEnCentroChanged: (String? value) => _updateField(() => _trayecto.origenUbicacionEnCentro = value),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // === DESTINO - Campo ===
                  Expanded(
                    child: _buildUbicacionField(
                      esOrigen: false,
                      tipoUbicacion: _trayecto.tipoDestino,
                      tipoUbicacionContraria: _trayecto.tipoOrigen,
                      domicilio: _trayecto.destinoDomicilio,
                      centroNombre: _trayecto.destinoCentro,
                      ubicacionEnCentro: _trayecto.destinoUbicacionEnCentro,
                      onDomicilioChanged: (String? value) => _updateField(() => _trayecto.destinoDomicilio = value),
                      onCentroChanged: (String? nombre) => _updateField(() => _trayecto.destinoCentro = nombre),
                      onUbicacionEnCentroChanged: (String? value) => _updateField(() => _trayecto.destinoUbicacionEnCentro = value),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // === HORA - Campo ===
                  SizedBox(
                    width: 130,
                    child: _buildHoraField(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye los botones de selección de tipo de ubicación
  Widget _buildUbicacionButtons({
    required TipoUbicacion tipoActual,
    required void Function(TipoUbicacion) onTipoChanged,
  }) {
    return Row(
      children: <Widget>[
        _UbicacionOptionButton(
          icon: Icons.home,
          tooltip: 'Domicilio paciente',
          isSelected: tipoActual == TipoUbicacion.domicilioPaciente,
          onTap: () => onTipoChanged(TipoUbicacion.domicilioPaciente),
        ),
        const SizedBox(width: 4),
        _UbicacionOptionButton(
          icon: Icons.location_on,
          tooltip: 'Otro domicilio',
          isSelected: tipoActual == TipoUbicacion.otroDomicilio,
          onTap: () => onTipoChanged(TipoUbicacion.otroDomicilio),
        ),
        const SizedBox(width: 4),
        _UbicacionOptionButton(
          icon: Icons.local_hospital,
          tooltip: 'Centro hospitalario',
          isSelected: tipoActual == TipoUbicacion.centroHospitalario,
          onTap: () => onTipoChanged(TipoUbicacion.centroHospitalario),
        ),
      ],
    );
  }

  /// Construye el campo de ubicación según el tipo seleccionado
  Widget _buildUbicacionField({
    required bool esOrigen,
    required TipoUbicacion tipoUbicacion,
    required TipoUbicacion tipoUbicacionContraria,
    required String? domicilio,
    required String? centroNombre,
    required String? ubicacionEnCentro,
    required void Function(String?) onDomicilioChanged,
    required void Function(String?) onCentroChanged,
    required void Function(String?) onUbicacionEnCentroChanged,
  }) {
    // Domicilio paciente
    if (tipoUbicacion == TipoUbicacion.domicilioPaciente) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.pacienteNombreCompleto != null
                    ? 'Domicilio de ${widget.pacienteNombreCompleto}'
                    : 'Domicilio del paciente',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Otro domicilio
    if (tipoUbicacion == TipoUbicacion.otroDomicilio) {
      return TextFormField(
        initialValue: domicilio,
        decoration: InputDecoration(
          hintText: 'Escribe la dirección',
          prefixIcon: const Icon(Icons.edit_location, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
        style: GoogleFonts.inter(fontSize: 13),
        onChanged: onDomicilioChanged,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa la dirección';
          }
          return null;
        },
      );
    }

    // Centro hospitalario
    if (tipoUbicacion == TipoUbicacion.centroHospitalario) {
      if (widget.loadingCentros) {
        return Container(
          height: 48,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.gray300),
          ),
          child: const Row(
            children: <Widget>[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Cargando...', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }

      // Determinar si debe mostrarse el campo de ubicación en centro
      // REGLAS:
      // 1. Alta hospitalaria (Hospital → Domicilio): Mostrar en ORIGEN
      // 2. Traslado entre hospitales (Hospital → Hospital):
      //    - IDA (índice par: 0, 2, 4...): Mostrar en ORIGEN (donde se recoge)
      //    - VUELTA (índice impar: 1, 3, 5...): Mostrar en DESTINO (donde se deja)
      // 3. Consulta (Domicilio → Hospital): NO mostrar

      final bool esIda = widget.index % 2 == 0;
      final bool esVuelta = !esIda;

      final bool mostrarUbicacionEnCentro = esOrigen
          ? (
              // Mostrar en ORIGEN si:
              // - Va a domicilio (alta hospitalaria)
              (tipoUbicacionContraria == TipoUbicacion.domicilioPaciente ||
               tipoUbicacionContraria == TipoUbicacion.otroDomicilio) ||
              // - Es traslado entre hospitales Y es trayecto de IDA
              (tipoUbicacionContraria == TipoUbicacion.centroHospitalario && esIda)
            )
          : (
              // Mostrar en DESTINO solo si:
              // - Origen es hospital Y es trayecto de VUELTA (para trasladar entre hospitales)
              tipoUbicacionContraria == TipoUbicacion.centroHospitalario && esVuelta
            );

      // Si NO hay que mostrar ubicación, retornar solo el dropdown
      if (!mostrarUbicacionEnCentro) {
        // ignore: always_specify_types
      return AppSearchableDropdown<CentroHospitalarioEntity>(
        key: ValueKey<String>('centro_${esOrigen ? "origen" : "destino"}_${widget.index}_$centroNombre'),
        value: centroNombre != null
            ? widget.centrosHospitalarios.firstWhere(
                (CentroHospitalarioEntity c) => c.nombre == centroNombre,
                orElse: () => widget.centrosHospitalarios.first,
              )
            : null,
        items: widget.centrosDropdownItems,
        onChanged: (CentroHospitalarioEntity? centro) async {
          if (centro == null) {
            onCentroChanged(null);
            return;
          }

          // Si es el primer trayecto (índice 0), preguntar si aplicar a todos
          if (widget.index == 0) {
            // Prevent duplicate dialog openings
            if (_isShowingDialog) {
              debugPrint('🏥 ⚠️ Diálogo ya está abierto, ignorando evento duplicado');
              return;
            }

            setState(() {
              _isShowingDialog = true;
            });

            debugPrint('🏥 Mostrando diálogo para centro: ${centro.nombre}');
            final bool? aplicarATodos = await _mostrarDialogoAplicarATodos(centro.nombre);

            setState(() {
              _isShowingDialog = false;
            });

            debugPrint('🏥 Respuesta del diálogo: $aplicarATodos');

            if (aplicarATodos == true) {
              // Aplicar a todos los trayectos
              debugPrint('🏥 ✅ Aplicando centro "${centro.nombre}" a TODOS los trayectos');
              widget.onAplicarCentroATodos(centro.nombre);
            } else if (aplicarATodos == false) {
              // Solo aplicar al trayecto actual
              debugPrint('🏥 ℹ️ Aplicando centro "${centro.nombre}" solo al trayecto actual');
              onCentroChanged(centro.nombre);
            } else {
              debugPrint('🏥 ❌ Usuario canceló el diálogo');
            }
          } else {
            // Si no es el primer trayecto, solo aplicar al actual
            onCentroChanged(centro.nombre);
          }
        },
          hint: widget.centrosHospitalarios.isEmpty ? 'Sin centros' : 'Buscar centro...',
          prefixIcon: Icons.local_hospital,
          enabled: widget.centrosHospitalarios.isNotEmpty,
        );
      }

      // SI hay que mostrar ubicación, retornar Column con dropdown + campo de ubicación
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Dropdown del centro hospitalario
          // ignore: always_specify_types
          AppSearchableDropdown<CentroHospitalarioEntity>(
            key: ValueKey<String>('centro_${esOrigen ? "origen" : "destino"}_${widget.index}_$centroNombre'),
            value: centroNombre != null
                ? widget.centrosHospitalarios.firstWhere(
                    (CentroHospitalarioEntity c) => c.nombre == centroNombre,
                    orElse: () => widget.centrosHospitalarios.first,
                  )
                : null,
            items: widget.centrosDropdownItems,
            onChanged: (CentroHospitalarioEntity? centro) async {
              if (centro == null) {
                onCentroChanged(null);
                return;
              }

              // Si es el primer trayecto (índice 0), preguntar si aplicar a todos
              if (widget.index == 0) {
                // Prevent duplicate dialog openings
                if (_isShowingDialog) {
                  debugPrint('🏥 ⚠️ Diálogo ya está abierto, ignorando evento duplicado');
                  return;
                }

                setState(() {
                  _isShowingDialog = true;
                });

                debugPrint('🏥 Mostrando diálogo para centro: ${centro.nombre}');
                final bool? aplicarATodos = await _mostrarDialogoAplicarATodos(centro.nombre);

                setState(() {
                  _isShowingDialog = false;
                });

                debugPrint('🏥 Respuesta del diálogo: $aplicarATodos');

                if (aplicarATodos == true) {
                  // Aplicar a todos los trayectos
                  debugPrint('🏥 ✅ Aplicando centro "${centro.nombre}" a TODOS los trayectos');
                  widget.onAplicarCentroATodos(centro.nombre);
                } else if (aplicarATodos == false) {
                  // Solo aplicar al trayecto actual
                  debugPrint('🏥 ℹ️ Aplicando centro "${centro.nombre}" solo al trayecto actual');
                  onCentroChanged(centro.nombre);
                } else {
                  debugPrint('🏥 ❌ Usuario canceló el diálogo');
                }
              } else {
                // Si no es el primer trayecto, solo aplicar al actual
                onCentroChanged(centro.nombre);
              }
            },
            hint: widget.centrosHospitalarios.isEmpty ? 'Sin centros' : 'Buscar centro...',
            prefixIcon: Icons.local_hospital,
            enabled: widget.centrosHospitalarios.isNotEmpty,
          ),

          // Espacio entre el dropdown y el campo de ubicación
          const SizedBox(height: 8),

          // Campo de texto para ubicación dentro del centro (Urgencias, Hab-202, etc.)
          // SOLO se muestra en: Hospital→Hospital o Altas (Hospital→Domicilio)
          TextFormField(
            initialValue: ubicacionEnCentro,
            decoration: InputDecoration(
              hintText: 'Ej: Urgencias, Hab-202, UCI... (opcional)',
              labelText: 'Ubicación en centro (opcional)',
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
              prefixIcon: const Icon(Icons.room_outlined, size: 18, color: AppColors.textSecondaryLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
            ),
            style: AppTextStyles.tableCell,
            onChanged: onUbicacionEnCentroChanged,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// Muestra diálogo preguntando si aplicar el centro hospitalario a todos los trayectos
  Future<bool?> _mostrarDialogoAplicarATodos(String centroNombre) async {
    debugPrint('🏥 📱 Mostrando diálogo modal...');

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _DialogoAplicarATodos(
          centroNombre: centroNombre,
          onResult: (bool value) {
            debugPrint('🏥 🚪 Cerrando diálogo con valor: $value');
            Navigator.of(dialogContext).pop(value);
          },
        );
      },
    );

    debugPrint('🏥 📱 Diálogo cerrado con resultado: $result');
    return result;
  }

  /// Construye el campo de hora
  Widget _buildHoraField() {
    return TextFormField(
      controller: _trayecto.horaController ?? (_trayecto.horaController = TextEditingController()),
      decoration: InputDecoration(
        hintText: 'HHMM',
        prefixIcon: const Icon(Icons.access_time, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
        LengthLimitingTextInputFormatter(5),
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (String value) {
        final String cleaned = value.replaceAll(RegExp('[^0-9:]'), '');

        if (cleaned.contains(':') && cleaned.length >= 5) {
          if (cleaned.length > 5) {
            _trayecto.horaController!.text = cleaned.substring(0, 5);
            _trayecto.horaController!.selection = TextSelection.fromPosition(
              const TextPosition(offset: 5),
            );
          }
          return;
        }

        if (!cleaned.contains(':') && cleaned.length > 4) {
          _trayecto.horaController!.text = cleaned.substring(0, 4);
          _trayecto.horaController!.selection = TextSelection.fromPosition(
            const TextPosition(offset: 4),
          );
          return;
        }

        if (cleaned.length == 4 && !cleaned.contains(':')) {
          final String horas = cleaned.substring(0, 2);
          final String minutos = cleaned.substring(2, 4);
          final int h = int.tryParse(horas) ?? 0;
          final int m = int.tryParse(minutos) ?? 0;

          if (h >= 0 && h < 24 && m >= 0 && m < 60) {
            _updateField(() => _trayecto.hora = TimeOfDay(hour: h, minute: m));
            _trayecto.horaController!.text = '$horas:$minutos';
            _trayecto.horaController!.selection = TextSelection.fromPosition(
              TextPosition(offset: _trayecto.horaController!.text.length),
            );
          }
        }
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa hora';
        }

        if (value.contains(':')) {
          final List<String> parts = value.split(':');
          if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
            return 'Formato: HHMM';
          }
          final int? h = int.tryParse(parts[0]);
          final int? m = int.tryParse(parts[1]);
          if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) {
            return 'Hora inválida';
          }
          return null;
        }

        if (value.length != 4) {
          return 'Formato: HHMM';
        }

        final int? h = int.tryParse(value.substring(0, 2));
        final int? m = int.tryParse(value.substring(2, 4));
        if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) {
          return 'Hora inválida';
        }

        return null;
      },
    );
  }
}

/// Widget separado para el diálogo de confirmación
class _DialogoAplicarATodos extends StatefulWidget {
  const _DialogoAplicarATodos({
    required this.centroNombre,
    required this.onResult,
  });

  final String centroNombre;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool) onResult;

  @override
  State<_DialogoAplicarATodos> createState() => _DialogoAplicarATodosState();
}

class _DialogoAplicarATodosState extends State<_DialogoAplicarATodos> {
  bool _isProcessing = false;

  void _handleResult(bool value) {
    if (_isProcessing) {
      debugPrint('🏥 ⚠️ Ya se está procesando, ignorando clic adicional');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    debugPrint('🏥 ${value ? "✅" : "❌"} Usuario hizo clic en "${value ? "Sí, aplicar a todos" : "No, solo este trayecto"}"');
    widget.onResult(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aplicar a todos los trayectos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '¿Deseas aplicar el centro hospitalario seleccionado:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.centroNombre,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'a todos los trayectos del servicio?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esto te ahorrará tiempo al no tener que seleccionar el centro en cada trayecto.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _isProcessing ? null : () => _handleResult(false),
              child: Text(
                'No, solo este trayecto',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isProcessing ? null : () => _handleResult(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Sí, aplicar a todos',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
  }
}

/// Botón compacto de opción de ubicación
class _UbicacionOptionButton extends StatelessWidget {
  const _UbicacionOptionButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.gray400,
            size: 18,
          ),
        ),
      ),
    );
  }
}
