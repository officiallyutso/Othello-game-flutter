import 'package:flutter/material.dart';
import 'package:othello/config/theme.dart';
import 'package:othello/models/game_model.dart';
import 'package:othello/widgets/piece_widget.dart';

class GameInfoWidget extends StatelessWidget {
  final GameModel game;
  
  const GameInfoWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Black score
          _buildScoreIndicator(
            context,
            isBlack: true,
            score: game.blackScore,
            isCurrentTurn: game.currentPlayer == CellState.black && game.status == GameStatus.playing,
          ),
          
          // VS text
          Text(
            'VS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // White score
          _buildScoreIndicator(
            context,
            isBlack: false,
            score: game.whiteScore,
            isCurrentTurn: game.currentPlayer == CellState.white && game.status == GameStatus.playing,
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreIndicator(
    BuildContext context, {
    required bool isBlack,
    required int score,
    required bool isCurrentTurn,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn 
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: PieceWidget(isBlack: isBlack),
          ),
          const SizedBox(width: 12),
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}