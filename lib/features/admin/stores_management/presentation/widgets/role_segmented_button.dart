import 'package:flutter/material.dart';
import '../../../../user/domain/entities/role.dart';

class RoleSegmentedButton extends StatelessWidget {
  const RoleSegmentedButton({
    super.key,
    required this.role,
    required this.onChanged,
  });

  final Role role;
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Role>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: Colors.blue[300],
        selectedForegroundColor: Colors.grey[50],
        shadowColor: Colors.grey[300],
        elevation: 3,
        foregroundColor: Colors.blue[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(
          color: Color(0xB0636363),
          width: 0.3,
        ),
      ),
      selectedIcon: const Icon(Icons.check_circle),
      selected: {role},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
      segments: const [
        ButtonSegment<Role>(
          value: Role.worker,
          label: Text(
            'عامل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(Icons.person),
        ),
        ButtonSegment<Role>(
          value: Role.storeOwner,
          label: Text(
            'مدير',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: Icon(Icons.manage_accounts),
        ),
      ],
    );
  }
}
