import 'package:flutter/material.dart';
import 'package:othello/config/theme.dart';

class PieceWidget extends StatelessWidget {
  final bool isBlack;
  
  const PieceWidget({
    super.key,
    required this.isBlack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isBlack ? AppTheme.blackPiece : AppTheme.whitePiece,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}