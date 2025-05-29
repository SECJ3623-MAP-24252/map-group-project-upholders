// lib/widgets/role_selector.dart
import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          ['user', 'therapist'].map((role) {
            final isSelected = selectedRole == role;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ChoiceChip(
                label: Text(role[0].toUpperCase() + role.substring(1)),
                selected: isSelected,
                onSelected: (_) => onRoleSelected(role),
                selectedColor: Colors.blue,
              ),
            );
          }).toList(),
    );
  }
}
