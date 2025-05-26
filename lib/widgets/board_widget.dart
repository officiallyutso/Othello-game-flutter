import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:othello/config/theme.dart';
import 'package:othello/models/game_model.dart';
import 'package:othello/widgets/piece_widget.dart';

class BoardWidget extends StatelessWidget {
  final GameModel game;
  final List<Position> validMoves;
  final Function(Position) onTap;
  
  const BoardWidget({
    super.key,
    required this.game,
    required this.validMoves,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.boardGreen,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.boardBorder,
          width: 3,
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: GameModel.boardSize,
        ),
        itemCount: GameModel.boardSize * GameModel.boardSize,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final row = index ~/ GameModel.boardSize;
          final col = index % GameModel.boardSize;
          final position = Position(row, col);
          final cellState = game.board[row][col];
          final isValidMove = validMoves.contains(position);
          
          return GestureDetector(
            onTap: () {
              if (isValidMove) {
                onTap(position);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.boardGreen,
                border: Border.all(
                  color: AppTheme.boardBorder,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Cell content
                  if (cellState != CellState.empty)
                    PieceWidget(
                      isBlack: cellState == CellState.black,
                    ).animate().scale(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                    ),
                  
                  // Valid move indicator
                  if (isValidMove && game.status == GameStatus.playing)
                    Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: game.currentPlayer == CellState.black
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 300),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}