import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modelo simple para personal
class PersonalItem {
  const PersonalItem({
    required this.id,
    required this.nombre,
    this.cargo,
  });

  final String id;
  final String nombre;
  final String? cargo;
}

/// Widget selector de personal con dropdown
class PersonalSelector extends StatelessWidget {
  const PersonalSelector({
    required this.selectedPersonalId,
    required this.personalList,
    required this.onPersonalSelected,
    super.key,
  });

  final String selectedPersonalId;
  final List<PersonalItem> personalList;
  final void Function(PersonalItem) onPersonalSelected;

  @override
  Widget build(BuildContext context) {
    final PersonalItem selectedPersonal = personalList.firstWhere(
      (PersonalItem p) => p.id == selectedPersonalId,
      orElse: () => personalList.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Personal Seleccionado',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<PersonalItem>(
                  value: selectedPersonal,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                  items: personalList.map((PersonalItem personal) {
                    return DropdownMenuItem<PersonalItem>(
                      value: personal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            personal.nombre,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          if (personal.cargo != null)
                            Text(
                              personal.cargo!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (PersonalItem? newPersonal) {
                    if (newPersonal != null) {
                      onPersonalSelected(newPersonal);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
