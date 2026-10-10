import 'package:flutter/material.dart';

import '../theme.dart';

/// Selo de conexão: "Online" ou "Sem internet · casos salvos no aparelho".
/// O app funciona igual nos dois estados; o selo só tranquiliza o usuário.
class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key, required this.online, this.onLongPress});

  final bool online;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final bg = online ? AppColors.okTint : AppColors.offlineTint;
    final fg = online ? AppColors.ok : AppColors.offlineText;
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(online ? Icons.wifi : Icons.cloud_off, size: 16, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                online ? 'Online' : 'Sem internet · casos salvos no aparelho',
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
