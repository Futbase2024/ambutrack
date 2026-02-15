import 'dart:math';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/app_dialog.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/formacion_personal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Diálogo para crear/editar formación personal
class FormacionPersonalFormDialog extends StatefulWidget {
  const FormacionPersonalFormDialog({super.key, this.item});

  final FormacionPersonalEntity? item;

  @override
  State<FormacionPersonalFormDialog> createState() => _FormacionPersonalFormDialogState();
}

class _FormacionPersonalFormDialogState extends State<FormacionPersonalFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _personalIdController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _horasAcumuladasController = TextEditingController(text: '0');

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  DateTime? _fechaExpiracion;
  bool _isLoading = true;
  bool _isSaving = false;

  // Datos de catálogos
  final List<CertificacionEntity> _certificaciones = <CertificacionEntity>[];
  final List<CursoEntity> _cursos = <CursoEntity>[];
  final List<UserEntity> _usuarios = <UserEntity>[];

  CertificacionEntity? _certificacionSeleccionada;
  CursoEntity? _cursoSeleccionado;
  UserEntity? _usuarioSeleccionado;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar acceder a context antes de tiempo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    if (_isEditing) {
      _personalIdController.text = widget.item!.personalId;
      _observacionesController.text = widget.item!.observaciones ?? '';
      _horasAcumuladasController.text = widget.item!.horasAcumuladas.toString();
      _fechaInicio = widget.item!.fechaInicio;
      _fechaFin = widget.item!.fechaFin;
      _fechaExpiracion = widget.item!.fechaExpiracion;
    }
  }

  Future<void> _loadData() async {
    try {
      // Cargar certificaciones, cursos y usuarios en paralelo
      final List<Object?> results = await Future.wait(<Future<Object?>>[
        getIt<CertificacionRepository>().getActivas(),
        getIt<CursoRepository>().getActivos(),
        getIt<UsersDataSource>().getAll(),
      ]);

      setState(() {
        if (results[0] is List<CertificacionEntity>) {
          _certificaciones.addAll(results[0] as List<CertificacionEntity>);
        }
        if (results[1] is List<CursoEntity>) {
          _cursos.addAll(results[1] as List<CursoEntity>);
        }
        if (results[2] is List<UserEntity>) {
          _usuarios.addAll(results[2] as List<UserEntity>);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _personalIdController.dispose();
    _observacionesController.dispose();
    _horasAcumuladasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _isEditing ? 'Editar Formación' : 'Nueva Formación',
      content: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Personal
                    DropdownButtonFormField<UserEntity>(
                      initialValue: _usuarioSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Empleado *',
                        border: OutlineInputBorder(),
                      ),
                      items: _usuarios
                          .map<DropdownMenuItem<UserEntity>>((UserEntity usuario) {
                        return DropdownMenuItem<UserEntity>(
                          value: usuario,
                          child: Text(usuario.displayName ?? usuario.email),
                        );
                      }).toList(),
                      onChanged: (UserEntity? value) {
                        setState(() {
                          _usuarioSeleccionado = value;
                          _personalIdController.text = value?.id ?? '';
                        });
                      },
                      validator: (UserEntity? value) {
                        if (value == null) {
                          return 'Selecciona un empleado';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de formación
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Certificación'),
                            value: 'certificacion',
                            // ignore: deprecated_member_use
                            groupValue: _certificacionSeleccionada != null ? 'certificacion' : 'curso',
                            // ignore: deprecated_member_use
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _certificacionSeleccionada = null;
                                  _cursoSeleccionado = null;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Curso'),
                            value: 'curso',
                            // ignore: deprecated_member_use
                            groupValue: _cursoSeleccionado != null ? 'curso' : 'certificacion',
                            // ignore: deprecated_member_use
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _cursoSeleccionado = null;
                                  _certificacionSeleccionada = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Certificación
                    if (_certificacionSeleccionada != null || _cursoSeleccionado == null)
                      DropdownButtonFormField<CertificacionEntity>(
                        initialValue: _certificacionSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Certificación *',
                          border: OutlineInputBorder(),
                        ),
                        items: _certificaciones
                            .map<DropdownMenuItem<CertificacionEntity>>((CertificacionEntity cert) {
                          return DropdownMenuItem<CertificacionEntity>(
                            value: cert,
                            child: Text('${cert.codigo} - ${cert.nombre}'),
                          );
                        }).toList(),
                        onChanged: (CertificacionEntity? value) {
                          setState(() {
                            _certificacionSeleccionada = value;
                            _cursoSeleccionado = null;
                          });
                        },
                      ),
                    const SizedBox(height: 16),

                    // Curso
                    if (_cursoSeleccionado != null || _certificacionSeleccionada == null)
                      DropdownButtonFormField<CursoEntity>(
                        initialValue: _cursoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Curso *',
                          border: OutlineInputBorder(),
                        ),
                        items: _cursos.map<DropdownMenuItem<CursoEntity>>((CursoEntity curso) {
                          return DropdownMenuItem<CursoEntity>(
                            value: curso,
                            child: Text(curso.nombre),
                          );
                        }).toList(),
                        onChanged: (CursoEntity? value) {
                          setState(() {
                            _cursoSeleccionado = value;
                            _certificacionSeleccionada = null;
                          });
                        },
                      ),
                    const SizedBox(height: 16),

                    // Fechas
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _fechaInicio ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _fechaInicio = picked;
                                  // Auto-calcular fecha de expiración si es certificación
                                  if (_certificacionSeleccionada != null && _fechaExpiracion == null) {
                                    _fechaExpiracion = picked.add(
                                      Duration(days: _certificacionSeleccionada!.vigenciaMeses * 30),
                                    );
                                  }
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha Inicio *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _fechaInicio != null
                                    ? DateFormat('dd/MM/yyyy').format(_fechaInicio!)
                                    : 'Selecciona fecha',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _fechaFin ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() {
                                  _fechaFin = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha Fin *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _fechaFin != null
                                    ? DateFormat('dd/MM/yyyy').format(_fechaFin!)
                                    : 'Selecciona fecha',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _fechaExpiracion ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            _fechaExpiracion = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha Expiración *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _fechaExpiracion != null
                              ? DateFormat('dd/MM/yyyy').format(_fechaExpiracion!)
                              : 'Selecciona fecha',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Horas acumuladas
                    TextFormField(
                      controller: _horasAcumuladasController,
                      decoration: const InputDecoration(
                        labelText: 'Horas Acumuladas',
                        border: OutlineInputBorder(),
                        suffixIcon: Text('horas'),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Observaciones
                    TextFormField(
                      controller: _observacionesController,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveFormacion,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _saveFormacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado certificación o curso
    if (_certificacionSeleccionada == null && _cursoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una certificación o un curso'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar fechas
    if (_fechaInicio == null || _fechaFin == null || _fechaExpiracion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todas las fechas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final FormacionPersonalRepository repository = getIt<FormacionPersonalRepository>();

      final FormacionPersonalEntity formacion = FormacionPersonalEntity(
        id: _isEditing ? widget.item!.id : _generateUuid(),
        personalId: _personalIdController.text,
        certificacionId: _certificacionSeleccionada?.id,
        cursoId: _cursoSeleccionado?.id,
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
        fechaExpiracion: _fechaExpiracion!,
        horasAcumuladas: int.tryParse(_horasAcumuladasController.text) ?? 0,
        estado: _calculateEstado(_fechaExpiracion!),
        observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await repository.update(formacion);
      } else {
        await repository.create(formacion);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // true indica que se guardó correctamente
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _generateUuid() {
    // Generar un UUID simple (en producción usar uuid package)
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }

  String _calculateEstado(DateTime fechaExpiracion) {
    final DateTime now = DateTime.now();
    final DateTime thirtyDaysLater = now.add(const Duration(days: 30));

    if (fechaExpiracion.isBefore(now)) {
      return 'vencida';
    } else if (fechaExpiracion.isBefore(thirtyDaysLater) || fechaExpiracion.isAtSameMomentAs(thirtyDaysLater)) {
      return 'proxima_vencer';
    } else {
      return 'vigente';
    }
  }
}
