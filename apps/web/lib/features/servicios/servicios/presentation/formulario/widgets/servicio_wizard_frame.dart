import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/widgets/servicio_wizard_footer.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/formulario/widgets/servicio_wizard_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Marco del asistente de servicios con el estilo de los formularios de gestión:
/// barra de título fina, indicador de pasos, cuerpo desplazable y pie compacto.
///
/// Atajos: Ctrl/⌘+Intro avanza (o guarda en el último paso), Esc cierra.
class ServicioWizardFrame extends StatelessWidget {
  const ServicioWizardFrame({
    required this.title,
    required this.icon,
    required this.steps,
    required this.currentStep,
    required this.isSaving,
    required this.finalLabel,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<String> steps;
  final int currentStep;
  final bool isSaving;

  /// Texto del botón principal en el último paso
  final String finalLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final Widget child;

  static const double _maxWidth = 980;
  static const double _maxHeight = 720;

  void _next() {
    if (!isSaving) {
      onNext();
    }
  }

  void _close() {
    if (!isSaving) {
      onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _next,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _next,
        const SingleActivator(LogicalKeyboardKey.escape): _close,
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.gray300),
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth, maxHeight: _maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _WizardTitleBar(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  onClose: isSaving ? null : onClose,
                ),
                ServicioWizardStepIndicator(steps: steps, currentStep: currentStep),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: FocusTraversalGroup(child: child),
                  ),
                ),
                ServicioWizardFooter(
                  currentStep: currentStep,
                  totalSteps: steps.length,
                  isSaving: isSaving,
                  finalLabel: finalLabel,
                  onPrevious: onPrevious,
                  onNext: _next,
                  onCancel: _close,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WizardTitleBar extends StatelessWidget {
  const _WizardTitleBar({required this.title, required this.icon, this.subtitle, this.onClose});

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.gray900),
          ),
          if (subtitle != null) ...<Widget>[
            const Text('  ·  ', style: TextStyle(color: AppColors.gray400)),
            Flexible(
              child: Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: AppColors.gray600, fontWeight: FontWeight.w500),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: onClose,
            tooltip: 'Cerrar (Esc)',
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.gray600,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
