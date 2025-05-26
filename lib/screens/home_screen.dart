import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:othello/blocs/settings/settings_bloc.dart';
import 'package:othello/models/game_model.dart';
import 'package:othello/screens/game_screen.dart';
import 'package:othello/screens/join_room_screen.dart';
import 'package:othello/widgets/menu_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game title
                    Text(
                      'OTHELLO',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'REVERSI',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Game mode buttons
                    MenuButton(
                      icon: Icons.person,
                      label: 'Play vs Easy AI',
                      onPressed: () => _startGame(
                        context,
                        GameMode.ai,
                        AIDifficulty.easy,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    MenuButton(
                      icon: Icons.psychology,
                      label: 'Play vs Hard AI',
                      onPressed: () => _startGame(
                        context,
                        GameMode.ai,
                        AIDifficulty.hard,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    MenuButton(
                      icon: Icons.people,
                      label: 'Local 2 Player',
                      onPressed: () => _startGame(
                        context,
                        GameMode.local,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    MenuButton(
                      icon: Icons.add,
                      label: 'Create Online Room',
                      onPressed: () => _createRoom(context),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    MenuButton(
                      icon: Icons.login,
                      label: 'Join Online Room',
                      onPressed: () => _joinRoom(context),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Theme toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.brightness_4,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<SettingsBloc, SettingsState>(
                          builder: (context, state) {
                            return Switch(
                              value: state.isDarkMode,
                              onChanged: (_) {
                                context.read<SettingsBloc>().add(ToggleThemeEvent());
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _startGame(BuildContext context, GameMode gameMode, [AIDifficulty aiDifficulty = AIDifficulty.easy]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameMode: gameMode,
          aiDifficulty: aiDifficulty,
        ),
      ),
    );
  }
  
  void _createRoom(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameMode: GameMode.online,
          createRoom: true,
        ),
      ),
    );
  }
  
  void _joinRoom(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JoinRoomScreen(),
      ),
    );
  }
}