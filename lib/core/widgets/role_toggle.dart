import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable Pembeli / Pedagang toggle used on the Login screen.
///
/// [isPembeli] determines which tab is selected.
/// [onChanged] is called with `true` when Pembeli is tapped, `false` for Pedagang.
class RoleToggle extends StatelessWidget {
  final bool isPembeli;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const RoleToggle({
    super.key,
    required this.isPembeli,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = AppColors.roleToggleBg(isDark);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab(
            label: 'Pembeli',
            isSelected: isPembeli,
            onTap: () => onChanged(true),
          ),
          _buildTab(
            label: 'Pedagang',
            isSelected: !isPembeli,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.black38),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ),
    );
  }
}
