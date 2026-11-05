import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ancho estándar de los formularios de gestión
enum GestionFormSize {
  small(500),
  medium(760),
  large(980);

  const GestionFormSize(this.width);
  final double width;
}

/// Marco de formulario estilo programa de gestión:
/// barra de título fina, cuerpo con secciones y pie compacto.
///
/// Atajos: Ctrl/⌘+Intro guarda, Esc cancela.
class GestionFormDialog extends StatelessWidget {
  const GestionFormDialog({
    required this.title,
    required this.formKey,
    required this.children,
    required this.onSave,
    this.subtitle,
    this.icon,
    this.size = GestionFormSize.medium,
    this.isEditing = false,
    this.isSaving = false,
    this.saveLabel,
    this.onCancel,
    this.readOnly = false,
    this.destructive = false,
    super.key,
  });

  final String title;

  /// Identificación del registro en edición (p.ej. matrícula)
  final String? subtitle;
  final IconData? icon;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final GestionFormSize size;
  final bool isEditing;
  final bool isSaving;
  final String? saveLabel;

  /// Ficha de solo consulta: el pie muestra únicamente "Cerrar" (que ejecuta [onSave])
  final bool readOnly;

  /// Acción principal destructiva (botón en rojo, sin atajo Ctrl+Intro)
  final bool destructive;

  void _cancel(BuildContext context) {
    if (isSaving) {
      return;
    }
    if (onCancel != null) {
      onCancel!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _save() {
    if (!isSaving) {
      onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        if (!destructive) const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        if (!destructive) const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
        const SingleActivator(LogicalKeyboardKey.escape): () => _cancel(context),
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
            constraints: BoxConstraints(maxWidth: size.width),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _TitleBar(
                  title: title,
                  subtitle: subtitle,
                  icon: icon ?? (isEditing ? Icons.edit_outlined : Icons.add_box_outlined),
                  onClose: isSaving ? null : () => _cancel(context),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Form(
                      key: formKey,
                      child: FocusTraversalGroup(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                      ),
                    ),
                  ),
                ),
                _Footer(
                  isEditing: isEditing,
                  isSaving: isSaving,
                  readOnly: readOnly,
                  destructive: destructive,
                  saveLabel: saveLabel,
                  onSave: _save,
                  onCancel: () => _cancel(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.title, required this.icon, this.subtitle, this.onClose});

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

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isEditing,
    required this.isSaving,
    required this.readOnly,
    required this.destructive,
    required this.onSave,
    required this.onCancel,
    this.saveLabel,
  });

  final bool isEditing;
  final bool isSaving;
  final bool readOnly;
  final bool destructive;
  final String? saveLabel;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  IconData get _icon {
    if (readOnly) {
      return Icons.check;
    }
    if (destructive) {
      return Icons.delete_outline;
    }
    return isEditing ? Icons.save_outlined : Icons.add;
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle hint = TextStyle(fontSize: 11.5, color: AppColors.gray500);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: <Widget>[
          if (readOnly)
            const Text('Esc cerrar', style: hint)
          else
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(
                    text: '*',
                    style: TextStyle(color: AppColors.error),
                  ),
                  TextSpan(
                    text: destructive
                        ? ' Obligatorio     Esc cancelar'
                        : ' Obligatorio     Ctrl+Intro guardar · Esc cancelar',
                  ),
                ],
              ),
              style: hint,
            ),
          const Spacer(),
          if (!readOnly) ...<Widget>[
            OutlinedButton(
              onPressed: isSaving ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                side: const BorderSide(color: AppColors.gray300),
                minimumSize: const Size(96, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
          ],
          FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(_icon, size: 16),
            label: Text(
              saveLabel ??
                  (readOnly
                      ? 'Cerrar'
                      : isEditing
                      ? 'Actualizar'
                      : 'Guardar'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? AppColors.error : AppColors.primary,
              minimumSize: const Size(112, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
