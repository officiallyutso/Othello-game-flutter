import 'dart:math';
import 'package:othello/models/game_model.dart';

class AIService {
  final Random _random = Random();
  
  // Get the best move for the AI based on difficulty
  Future<Position> getBestMove(GameModel game) async {
    final validMoves = game.getValidMoves();
    
    if (validMoves.isEmpty) {
      throw Exception('No valid moves available');
    }
    
    switch (game.aiDifficulty) {
      case AIDifficulty.easy:
        return _getRandomMove(validMoves);
      case AIDifficulty.hard:
        return _getMinimaxMove(game);
    }
  }
  
  // Easy AI: just pick a random valid move
  Position _getRandomMove(List<Position> validMoves) {
    return validMoves[_random.nextInt(validMoves.length)];
  }
  
  // Hard AI: use minimax with alpha-beta pruning
  Position _getMinimaxMove(GameModel game) {
    final validMoves = game.getValidMoves();
    Position bestMove = validMoves.first;
    int bestScore = -1000;
    
    for (final move in validMoves) {
      final newGame = game.makeMove(move);
      final score = _minimax(newGame, 4, -1000, 1000, false);
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    return bestMove;
  }
  
  // Minimax algorithm with alpha-beta pruning
  int _minimax(GameModel game, int depth, int alpha, int beta, bool isMaximizing) {
    // Terminal conditions
    if (depth == 0 || game.status != GameStatus.playing) {
      return _evaluateBoard(game);
    }
    
    final validMoves = game.getValidMoves();
    
    // If no valid moves, pass turn
    if (validMoves.isEmpty) {
      // Create a game with the turn passed
      final nextPlayer = game.currentPlayer == CellState.black ? CellState.white : CellState.black;
      final passedGame = GameModel(
        id: game.id,
        board: game.board,
        currentPlayer: nextPlayer,
        gameMode: game.gameMode,
        aiDifficulty: game.aiDifficulty,
        status: game.status,
        blackScore: game.blackScore,
        whiteScore: game.whiteScore,
        roomCode: game.roomCode,
        creatorId: game.creatorId,
        joinerId: game.joinerId,
        createdAt: game.createdAt,
        updatedAt: game.updatedAt,
      );
      
      // Check if the next player also has no moves
      final nextValidMoves = passedGame.getValidMoves();
      if (nextValidMoves.isEmpty) {
        // Game over, evaluate the final board
        return _evaluateBoard(game);
      }
      
      // Continue with the passed turn
      return _minimax(passedGame, depth - 1, alpha, beta, !isMaximizing);
    }
    
    if (isMaximizing) {
      int maxEval = -1000;
      for (final move in validMoves) {
        final newGame = game.makeMove(move);
        final eval = _minimax(newGame, depth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Alpha-beta pruning
      }
      return maxEval;
    } else {
      int minEval = 1000;
      for (final move in validMoves) {
        final newGame = game.makeMove(move);
        final eval = _minimax(newGame, depth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Alpha-beta pruning
      }
      return minEval;
    }
  }
  
  // Evaluate the board position
  int _evaluateBoard(GameModel game) {
    // Simple evaluation: difference in piece count
    // For a more sophisticated AI, you could add positional weights
    // (corners are more valuable, edges are good, etc.)
    
    // Determine which player we're evaluating for
    final aiPlayer = game.gameMode == GameMode.ai ? CellState.white : CellState.black;
    
    // Piece count difference
    int score = 0;
    
    // Corner control (corners are very valuable)
    final corners = [
      Position(0, 0),
      Position(0, 7),
      Position(7, 0),
      Position(7, 7),
    ];
    
    // Edge control (edges are somewhat valuable)
    final edges = <Position>[];
    for (int i = 1; i < 7; i++) {
      edges.add(Position(0, i)); // Top edge
      edges.add(Position(7, i)); // Bottom edge
      edges.add(Position(i, 0)); // Left edge
      edges.add(Position(i, 7)); // Right edge
    }
    
    // Mobility (number of valid moves)
    final mobilityScore = game.getValidMoves().length;
    
    // Calculate the score
    for (int r = 0; r < GameModel.boardSize; r++) {
      for (int c = 0; c < GameModel.boardSize; c++) {
        final pos = Position(r, c);
        final cell = game.board[r][c];
        
        if (cell == CellState.empty) continue;
        
        int value = 1; // Base value for a piece
        
        // Increase value for strategic positions
        if (corners.contains(pos)) {
          value = 10; // Corners are very valuable
        } else if (edges.contains(pos)) {
          value = 3; // Edges are somewhat valuable
        }
        
        if (cell == aiPlayer) {
          score += value;
        } else {
          score -= value;
        }
      }
    }
    
    // Add mobility score
    if (game.currentPlayer == aiPlayer) {
      score += mobilityScore;
    } else {
      score -= mobilityScore;
    }
    
    return score;
  }
}