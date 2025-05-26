import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum CellState { empty, black, white }
enum GameMode { ai, online, local }
enum AIDifficulty { easy, hard }
enum GameStatus { playing, blackWon, whiteWon, draw }

class Position {
  final int row;
  final int col;
  
  const Position(this.row, this.col);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
  
  @override
  String toString() => '($row, $col)';
}

class GameModel extends Equatable {
  static const int boardSize = 8;
  final String id;
  final List<List<CellState>> board;
  final CellState currentPlayer;
  final GameMode gameMode;
  final AIDifficulty aiDifficulty;
  final GameStatus status;
  final int blackScore;
  final int whiteScore;
  final String? roomCode;
  final String? creatorId;
  final String? joinerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const GameModel({
    required this.id,
    required this.board,
    required this.currentPlayer,
    required this.gameMode,
    this.aiDifficulty = AIDifficulty.easy,
    required this.status,
    required this.blackScore,
    required this.whiteScore,
    this.roomCode,
    this.creatorId,
    this.joinerId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a new game
  factory GameModel.newGame({
    required GameMode gameMode,
    AIDifficulty aiDifficulty = AIDifficulty.easy,
    String? creatorId,
    String? roomCode,
  }) {
    // Initialize the board with empty cells
    final board = List.generate(
      boardSize,
      (_) => List.filled(boardSize, CellState.empty),
    );
    
    // Set up the initial pieces
    board[3][3] = CellState.white;
    board[3][4] = CellState.black;
    board[4][3] = CellState.black;
    board[4][4] = CellState.white;
    
    final now = DateTime.now();
    
    return GameModel(
      id: const Uuid().v4(),
      board: board,
      currentPlayer: CellState.black, // Black goes first
      gameMode: gameMode,
      aiDifficulty: aiDifficulty,
      status: GameStatus.playing,
      blackScore: 2,
      whiteScore: 2,
      roomCode: roomCode,
      creatorId: creatorId,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Get valid moves for the current player
  List<Position> getValidMoves() {
    final validMoves = <Position>[];
    
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] == CellState.empty) {
          final position = Position(row, col);
          if (isValidMove(position)) {
            validMoves.add(position);
          }
        }
      }
    }
    
    return validMoves;
  }
  
  // Check if a move is valid
  bool isValidMove(Position position) {
    if (board[position.row][position.col] != CellState.empty) {
      return false;
    }
    
    return getFlippedPieces(position).isNotEmpty;
  }
  
  // Get pieces that would be flipped by a move
  List<Position> getFlippedPieces(Position position) {
    final flippedPieces = <Position>[];
    final opponent = currentPlayer == CellState.black ? CellState.white : CellState.black;
    
    // Check in all 8 directions
    final directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1],
    ];
    
    for (final direction in directions) {
      final dirRow = direction[0];
      final dirCol = direction[1];
      
      var row = position.row + dirRow;
      var col = position.col + dirCol;
      final piecesToFlip = <Position>[];
      
      // Move in the current direction as long as we find opponent pieces
      while (row >= 0 && row < boardSize && col >= 0 && col < boardSize && board[row][col] == opponent) {
        piecesToFlip.add(Position(row, col));
        row += dirRow;
        col += dirCol;
      }
      
      // If we found at least one opponent piece and ended with our piece, these are valid flips
      if (piecesToFlip.isNotEmpty && 
          row >= 0 && row < boardSize && col >= 0 && col < boardSize && 
          board[row][col] == currentPlayer) {
        flippedPieces.addAll(piecesToFlip);
      }
    }
    
    return flippedPieces;
  }
  
  // Make a move and return the new game state
  GameModel makeMove(Position position) {
    if (!isValidMove(position)) {
      return this;
    }
    
    final flippedPieces = getFlippedPieces(position);
    final newBoard = List.generate(
      boardSize,
      (r) => List.generate(
        boardSize,
        (c) => board[r][c],
      ),
    );
    
    // Place the new piece
    newBoard[position.row][position.col] = currentPlayer;
    
    // Flip the captured pieces
    for (final piece in flippedPieces) {
      newBoard[piece.row][piece.col] = currentPlayer;
    }
    
    // Count the pieces
    int blackCount = 0;
    int whiteCount = 0;
    
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (newBoard[r][c] == CellState.black) {
          blackCount++;
        } else if (newBoard[r][c] == CellState.white) {
          whiteCount++;
        }
      }
    }
    
    // Switch to the next player
    final nextPlayer = currentPlayer == CellState.black ? CellState.white : CellState.black;
    
    // Create a temporary game to check if the next player has valid moves
    final tempGame = GameModel(
      id: id,
      board: newBoard,
      currentPlayer: nextPlayer,
      gameMode: gameMode,
      aiDifficulty: aiDifficulty,
      status: status,
      blackScore: blackCount,
      whiteScore: whiteCount,
      roomCode: roomCode,
      creatorId: creatorId,
      joinerId: joinerId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
    
    final hasValidMoves = tempGame.getValidMoves().isNotEmpty;
    
    // If the next player has no valid moves, check if the current player has moves
    if (!hasValidMoves) {
      final currentPlayerTempGame = GameModel(
        id: id,
        board: newBoard,
        currentPlayer: currentPlayer, // Keep the current player
        gameMode: gameMode,
        aiDifficulty: aiDifficulty,
        status: status,
        blackScore: blackCount,
        whiteScore: whiteCount,
        roomCode: roomCode,
        creatorId: creatorId,
        joinerId: joinerId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
      
      final currentPlayerHasMoves = currentPlayerTempGame.getValidMoves().isNotEmpty;
      
      // If neither player has moves, the game is over
      if (!currentPlayerHasMoves) {
        // Determine the winner
        GameStatus gameStatus;
        if (blackCount > whiteCount) {
          gameStatus = GameStatus.blackWon;
        } else if (whiteCount > blackCount) {
          gameStatus = GameStatus.whiteWon;
        } else {
          gameStatus = GameStatus.draw;
        }
        
        return GameModel(
          id: id,
          board: newBoard,
          currentPlayer: nextPlayer,
          gameMode: gameMode,
          aiDifficulty: aiDifficulty,
          status: gameStatus,
          blackScore: blackCount,
          whiteScore: whiteCount,
          roomCode: roomCode,
          creatorId: creatorId,
          joinerId: joinerId,
          createdAt: createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      // If only the next player has no moves, skip their turn
      return GameModel(
        id: id,
        board: newBoard,
        currentPlayer: currentPlayer, // Keep the current player
        gameMode: gameMode,
        aiDifficulty: aiDifficulty,
        status: status,
        blackScore: blackCount,
        whiteScore: whiteCount,
        roomCode: roomCode,
        creatorId: creatorId,
        joinerId: joinerId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
    }
    
    // Normal case: switch to the next player
    return GameModel(
      id: id,
      board: newBoard,
      currentPlayer: nextPlayer,
      gameMode: gameMode,
      aiDifficulty: aiDifficulty,
      status: status,
      blackScore: blackCount,
      whiteScore: whiteCount,
      roomCode: roomCode,
      creatorId: creatorId,
      joinerId: joinerId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
  
  // Convert to a map for Firestore
  // In your GameModel class, update the toMap method:
  
  Map<String, dynamic> toMap() {
  // Convert 2D board array to a flattened string representation
  final boardString = board.map((row) => 
    row.map((cell) => cell.index.toString()).join('')
  ).join('|');
  
  return {
    'id': id,
    'board': boardString, // Store as string instead of nested arrays
    'currentPlayer': currentPlayer.index,
    'gameMode': gameMode.index,
    'aiDifficulty': aiDifficulty.index,
    'status': status.index,
    'blackScore': blackScore,
    'whiteScore': whiteScore,
    'roomCode': roomCode,
    'creatorId': creatorId,
    'joinerId': joinerId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  }
  
  // Then update the fromMap method to parse this format:
  factory GameModel.fromMap(Map<String, dynamic> map) {
  // Parse the board string back to a 2D array
  final boardString = map['board'] as String;
  final rows = boardString.split('|');
  final board = List<List<CellState>>.generate(
    boardSize,
    (r) => List<CellState>.generate(
      boardSize,
      (c) => CellState.values[int.parse(rows[r][c])],
    ),
  );
  
  return GameModel(
    id: map['id'],
    board: board,
    currentPlayer: CellState.values[map['currentPlayer']],
    gameMode: GameMode.values[map['gameMode']],
    aiDifficulty: AIDifficulty.values[map['aiDifficulty']],
    status: GameStatus.values[map['status']],
    blackScore: map['blackScore'],
    whiteScore: map['whiteScore'],
    roomCode: map['roomCode'],
    creatorId: map['creatorId'],
    joinerId: map['joinerId'],
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
  );
  }
  
  @override
  List<Object?> get props => [
    id, board, currentPlayer, gameMode, aiDifficulty, 
    status, blackScore, whiteScore, roomCode, 
    creatorId, joinerId, createdAt, updatedAt
  ];
}