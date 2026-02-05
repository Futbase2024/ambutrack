import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/vehiculos/presentation/widgets/vehiculo_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diálogo para agregar un nuevo vehículo
class AgregarVehiculoDialog extends StatefulWidget {
  const AgregarVehiculoDialog({super.key});

  @override
  State<AgregarVehiculoDialog> createState() => _AgregarVehiculoDialogState();
}

class _AgregarVehiculoDialogState extends State<AgregarVehiculoDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _kmActualController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  VehiculoEstado _estadoSeleccionado = VehiculoEstado.activo;

  @override
  void dispose() {
    _matriculaController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _capacidadController.dispose();
    _kmActualController.dispose();
    _ubicacionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> vehiculoData = <String, dynamic>{
        'matricula': _matriculaController.text.trim(),
        'tipo': _tipoController.text.trim(),
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'anio': int.parse(_anioController.text.trim()),
        'estado': _estadoSeleccionado,
        'capacidad': _capacidadController.text.isNotEmpty
            ? int.parse(_capacidadController.text.trim())
            : null,
        'km_actual': _kmActualController.text.isNotEmpty
            ? double.parse(_kmActualController.text.trim())
            : null,
        'ubicacion_actual': _ubicacionController.text.isNotEmpty
            ? _ubicacionController.text.trim()
            : null,
        'observaciones': _observacionesController.text.isNotEmpty
            ? _observacionesController.text.trim()
            : null,
      };

      Navigator.of(context).pop(vehiculoData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: VehiculoFormFields(
                    matriculaController: _matriculaController,
                    tipoController: _tipoController,
                    marcaController: _marcaController,
                    modeloController: _modeloController,
                    anioController: _anioController,
                    capacidadController: _capacidadController,
                    kmActualController: _kmActualController,
                    ubicacionController: _ubicacionController,
                    observacionesController: _observacionesController,
                    estadoSeleccionado: _estadoSeleccionado,
                    onEstadoChanged: (VehiculoEstado? estado) {
                      if (estado != null) {
                        setState(() {
                          _estadoSeleccionado = estado;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            _DialogFooter(
              onCancel: () => Navigator.of(context).pop(),
              onSave: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header del diálogo con título y botón cerrar
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Agregar Nuevo Vehículo',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa la información del vehículo',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// Footer del diálogo con botones de acción
class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.onCancel,
    required this.onSave,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondaryLight,
              side: const BorderSide(color: AppColors.gray300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Guardar Vehículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
