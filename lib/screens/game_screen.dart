import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:othello/blocs/game/game_bloc.dart';
import 'package:othello/config/theme.dart';
import 'package:othello/models/game_model.dart';
import 'package:othello/widgets/board_widget.dart';
import 'package:othello/widgets/game_info_widget.dart';
import 'package:othello/widgets/room_info_widget.dart';

class GameScreen extends StatelessWidget {
  final GameMode gameMode;
  final AIDifficulty aiDifficulty;
  final bool createRoom;
  final String? roomCode;
  
  const GameScreen({
    super.key,
    required this.gameMode,
    this.aiDifficulty = AIDifficulty.easy,
    this.createRoom = false,
    this.roomCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GameBloc();
        
        // Start the game based on the mode
        if (gameMode == GameMode.online) {
          if (createRoom) {
            bloc.add(CreateRoomEvent());
          } else if (roomCode != null) {
            bloc.add(JoinRoomEvent(roomCode!));
          }
        } else {
          bloc.add(StartGameEvent(
            gameMode: gameMode,
            aiDifficulty: aiDifficulty,
          ));
        }
        
        return bloc;
      },
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(_getTitle(state)),
                actions: [
                  if (state.game != null && state.game!.status == GameStatus.playing)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _showRestartDialog(context);
                      },
                    ),
                ],
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }
  
  String _getTitle(GameState state) {
    if (state.game == null) {
      return 'Othello';
    }
    
    switch (state.game!.gameMode) {
      case GameMode.ai:
        return 'Playing vs ${state.game!.aiDifficulty == AIDifficulty.easy ? 'Easy' : 'Hard'} AI';
      case GameMode.local:
        return 'Local 2 Player';
      case GameMode.online:
        return 'Online Game';
    }
  }
  
  Widget _buildBody(BuildContext context, GameState state) {
    if (state.isLoading || state.isCreatingRoom || state.isJoiningRoom) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state.game == null) {
      if (gameMode == GameMode.online) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                createRoom ? 'Creating room...' : 'Joining room...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        );
      }
      
      return const Center(
        child: Text('Game not started'),
      );
    }
    
    return Column(
      children: [
        // Room info for online games
        if (state.game!.gameMode == GameMode.online && state.roomCode != null)
          RoomInfoWidget(roomCode: state.roomCode!),
        
        // Game info (scores, current player)
        GameInfoWidget(game: state.game!),
        
        // Game board
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BoardWidget(
                  game: state.game!,
                  validMoves: state.validMoves,
                  onTap: (position) {
                    context.read<GameBloc>().add(MakeMoveEvent(position));
                  },
                ),
              ),
            ),
          ),
        ),
        
        // Game status
        if (state.game!.status != GameStatus.playing)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _getGameStatusText(state.game!.status),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<GameBloc>().add(RestartGameEvent());
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ),
          
        const SizedBox(height: 16),
      ],
    );
  }
  
  String _getGameStatusText(GameStatus status) {
    switch (status) {
      case GameStatus.playing:
        return 'Game in progress';
      case GameStatus.blackWon:
        return 'Black wins!';
      case GameStatus.whiteWon:
        return 'White wins!';
      case GameStatus.draw:
        return 'Game ended in a draw!';
    }
  }
  
  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restart Game?'),
        content: const Text('Are you sure you want to restart the game?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // First close the dialog
              Navigator.of(dialogContext).pop();
              
              // Then restart with a small delay to ensure dialog is closed
              Future.delayed(const Duration(milliseconds: 100), () {
                if (context.mounted) {
                  context.read<GameBloc>().add(RestartGameEvent());
                }
              });
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}