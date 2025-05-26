import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:othello/models/game_model.dart';
import 'package:othello/services/ai_service.dart';
import 'package:othello/services/firebase_service.dart';

// Events
abstract class GameEvent extends Equatable {
  const GameEvent();
  
  @override
  List<Object?> get props => [];
}

class StartGameEvent extends GameEvent {
  final GameMode gameMode;
  final AIDifficulty aiDifficulty;
  
  const StartGameEvent({
    required this.gameMode,
    this.aiDifficulty = AIDifficulty.easy,
  });
  
  @override
  List<Object?> get props => [gameMode, aiDifficulty];
}

class MakeMoveEvent extends GameEvent {
  final Position position;
  
  const MakeMoveEvent(this.position);
  
  @override
  List<Object?> get props => [position];
}

class CreateRoomEvent extends GameEvent {}

class JoinRoomEvent extends GameEvent {
  final String roomCode;
  
  const JoinRoomEvent(this.roomCode);
  
  @override
  List<Object?> get props => [roomCode];
}

class LeaveRoomEvent extends GameEvent {}

class RestartGameEvent extends GameEvent {}

class GameUpdateEvent extends GameEvent {
  final GameModel game;
  
  const GameUpdateEvent(this.game);
  
  @override
  List<Object?> get props => [game];
}

// State
class GameState extends Equatable {
  final GameModel? game;
  final bool isLoading;
  final String? error;
  final List<Position> validMoves;
  final String? roomCode;
  final bool isCreatingRoom;
  final bool isJoiningRoom;
  
  const GameState({
    this.game,
    this.isLoading = false,
    this.error,
    this.validMoves = const [],
    this.roomCode,
    this.isCreatingRoom = false,
    this.isJoiningRoom = false,
  });
  
  GameState copyWith({
    GameModel? game,
    bool? isLoading,
    String? error,
    List<Position>? validMoves,
    String? roomCode,
    bool? isCreatingRoom,
    bool? isJoiningRoom,
  }) {
    return GameState(
      game: game ?? this.game,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      validMoves: validMoves ?? this.validMoves,
      roomCode: roomCode ?? this.roomCode,
      isCreatingRoom: isCreatingRoom ?? this.isCreatingRoom,
      isJoiningRoom: isJoiningRoom ?? this.isJoiningRoom,
    );
  }
  
  @override
  List<Object?> get props => [
    game, isLoading, error, validMoves, roomCode, isCreatingRoom, isJoiningRoom
  ];
}

// Bloc
class GameBloc extends Bloc<GameEvent, GameState> {
  final AIService _aiService = AIService();
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _gameSubscription;
  
  GameBloc() : super(const GameState()) {
    on<StartGameEvent>(_onStartGame);
    on<MakeMoveEvent>(_onMakeMove);
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<RestartGameEvent>(_onRestartGame);
    on<GameUpdateEvent>(_onGameUpdate);
  }
  
  Future<void> _onStartGame(StartGameEvent event, Emitter<GameState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final game = GameModel.newGame(
        gameMode: event.gameMode,
        aiDifficulty: event.aiDifficulty,
      );
      
      final validMoves = game.getValidMoves();
      
      emit(state.copyWith(
        game: game,
        isLoading: false,
        validMoves: validMoves,
      ));
      
      // If playing against AI and AI goes first (white), make AI move
      if (event.gameMode == GameMode.ai && game.currentPlayer == CellState.white) {
        add(MakeMoveEvent(await _aiService.getBestMove(game)));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to start game: $e',
      ));
    }
  }
  
  Future<void> _onMakeMove(MakeMoveEvent event, Emitter<GameState> emit) async {
    if (state.game == null) return;
    
    try {
      final game = state.game!;
      
      // For online games, use Firebase to make the move
      if (game.gameMode == GameMode.online) {
        if (state.roomCode == null) return;
        
        final success = await _firebaseService.makeMove(
          state.roomCode!,
          event.position,
        );
        
        if (!success) {
          emit(state.copyWith(
            error: 'Invalid move or not your turn',
          ));
        }
        
        // The game update will come through the Firebase listener
        return;
      }
      
      // For local games, update the game state directly
      if (!game.isValidMove(event.position)) {
        emit(state.copyWith(
          error: 'Invalid move',
        ));
        return;
      }
      
      final updatedGame = game.makeMove(event.position);
      final validMoves = updatedGame.getValidMoves();
      
      emit(state.copyWith(
        game: updatedGame,
        validMoves: validMoves,
        error: null,
      ));
      
      // If playing against AI, make AI move after a short delay
      if (game.gameMode == GameMode.ai && 
          updatedGame.currentPlayer == CellState.white &&
          updatedGame.status == GameStatus.playing) {
        // Add a small delay to make the AI move feel more natural
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (validMoves.isNotEmpty) {
          add(MakeMoveEvent(await _aiService.getBestMove(updatedGame)));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to make move: $e',
      ));
    }
  }
  
  Future<void> _onCreateRoom(CreateRoomEvent event, Emitter<GameState> emit) async {
    emit(state.copyWith(isCreatingRoom: true, error: null));
    
    try {
      final roomCode = await _firebaseService.createGameRoom();
      
      if (roomCode == null) {
        emit(state.copyWith(
          isCreatingRoom: false,
          error: 'Failed to create room',
        ));
        return;
      }
      
      // Listen for game updates
      _subscribeToGameUpdates(roomCode);
      
      emit(state.copyWith(
        isCreatingRoom: false,
        roomCode: roomCode,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreatingRoom: false,
        error: 'Failed to create room: $e',
      ));
    }
  }
  
  Future<void> _onJoinRoom(JoinRoomEvent event, Emitter<GameState> emit) async {
    emit(state.copyWith(isJoiningRoom: true, error: null));
    
    try {
      final game = await _firebaseService.joinGameRoom(event.roomCode);
      
      if (game == null) {
        emit(state.copyWith(
          isJoiningRoom: false,
          error: 'Failed to join room. Room may not exist or is full.',
        ));
        return;
      }
      
      // Listen for game updates
      _subscribeToGameUpdates(event.roomCode);
      
      emit(state.copyWith(
        isJoiningRoom: false,
        roomCode: event.roomCode,
      ));
    } catch (e) {
      emit(state.copyWith(
        isJoiningRoom: false,
        error: 'Failed to join room: $e',
      ));
    }
  }
  
  Future<void> _onLeaveRoom(LeaveRoomEvent event, Emitter<GameState> emit) async {
    if (state.roomCode == null) return;
    
    try {
      await _firebaseService.leaveGameRoom(state.roomCode!);
      
      // Cancel the subscription
      await _gameSubscription?.cancel();
      _gameSubscription = null;
      
      emit(const GameState());
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to leave room: $e',
      ));
    }
  }
  
  Future<void> _onRestartGame(RestartGameEvent event, Emitter<GameState> emit) async {
    if (state.game == null) return;
    
    try {
      final gameMode = state.game!.gameMode;
      final aiDifficulty = state.game!.aiDifficulty;
      
      // For online games, we need to handle differently
      if (gameMode == GameMode.online) {
        // First emit a loading state
        emit(state.copyWith(isLoading: true, error: null));
        
        // Leave the current room safely
        if (state.roomCode != null) {
          try {
            await _firebaseService.leaveGameRoom(state.roomCode!);
          } catch (e) {
            print('Error leaving room: $e');
            // Continue anyway
          }
        }
        
        // Cancel the subscription safely
        if (_gameSubscription != null) {
          try {
            await _gameSubscription?.cancel();
          } catch (e) {
            print('Error canceling subscription: $e');
            // Continue anyway
          }
          _gameSubscription = null;
        }
        
        // Reset state before creating a new room
        emit(const GameState(isLoading: true));
        
        // Create a new room
        add(CreateRoomEvent());
        return;
      }
      
      // For local games, just start a new game with a clean state
      emit(const GameState(isLoading: true));
      
      // Small delay to ensure UI updates properly
      await Future.delayed(const Duration(milliseconds: 100));
      
      add(StartGameEvent(
        gameMode: gameMode,
        aiDifficulty: aiDifficulty,
      ));
    } catch (e) {
      // If any error occurs, reset to a clean state
      emit(GameState(
        error: 'Failed to restart game: $e',
      ));
    }
  }
  
  void _onGameUpdate(GameUpdateEvent event, Emitter<GameState> emit) {
    final validMoves = event.game.getValidMoves();
    
    emit(state.copyWith(
      game: event.game,
      validMoves: validMoves,
    ));
  }
  
  void _subscribeToGameUpdates(String roomCode) {
    // Cancel any existing subscription
    _gameSubscription?.cancel();
    
    // Subscribe to game updates
    _gameSubscription = _firebaseService
        .listenToGame(roomCode)
        .listen(
          (game) => add(GameUpdateEvent(game)),
          onError: (error) => add(LeaveRoomEvent()),
        );
  }
  
  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}