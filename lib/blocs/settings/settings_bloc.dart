import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeSettingsEvent extends SettingsEvent {}

class ToggleThemeEvent extends SettingsEvent {}

// State
class SettingsState extends Equatable {
  final bool isDarkMode;
  
  const SettingsState({
    this.isDarkMode = false,
  });
  
  SettingsState copyWith({
    bool? isDarkMode,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
  
  @override
  List<Object?> get props => [isDarkMode];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _darkModeKey = 'dark_mode';
  
  SettingsBloc() : super(const SettingsState()) {
    on<InitializeSettingsEvent>(_onInitializeSettings);
    on<ToggleThemeEvent>(_onToggleTheme);
    
    // Initialize settings when bloc is created
    add(InitializeSettingsEvent());
  }
  
  Future<void> _onInitializeSettings(InitializeSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      
      emit(state.copyWith(isDarkMode: isDarkMode));
    } catch (e) {
      // If there's an error, use default settings
      print('Error initializing settings: $e');
    }
  }
  
  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<SettingsState> emit) async {
    try {
      final newDarkMode = !state.isDarkMode;
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, newDarkMode);
      
      emit(state.copyWith(isDarkMode: newDarkMode));
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }
}