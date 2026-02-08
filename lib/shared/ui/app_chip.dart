import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        avatar: icon != null
            ? Icon(
                icon,
                size: 18,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              )
            : null,
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedColor: colorScheme.primary,
        disabledColor: theme.disabledColor,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            color: isSelected ? Colors.transparent : theme.dividerColor,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
