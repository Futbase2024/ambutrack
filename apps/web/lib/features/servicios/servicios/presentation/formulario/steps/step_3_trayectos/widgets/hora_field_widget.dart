import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de hora del trayecto
class HoraFieldWidget extends StatefulWidget {
  const HoraFieldWidget({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final void Function(TimeOfDay?) onChanged;

  @override
  State<HoraFieldWidget> createState() => _HoraFieldWidgetState();
}

class _HoraFieldWidgetState extends State<HoraFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Hora *',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
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
                widget.controller.text = cleaned.substring(0, 5);
                widget.controller.selection = TextSelection.fromPosition(
                  const TextPosition(offset: 5),
                );
              }
              return;
            }

            if (!cleaned.contains(':') && cleaned.length > 4) {
              widget.controller.text = cleaned.substring(0, 4);
              widget.controller.selection = TextSelection.fromPosition(
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
                widget.onChanged(TimeOfDay(hour: h, minute: m));
                widget.controller.text = '$horas:$minutos';
                widget.controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: widget.controller.text.length),
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
        ),
      ],
    );
  }
}
