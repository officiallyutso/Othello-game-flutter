import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  
  @override
  List<Object> get props => [];
}

class ToggleThemeEvent extends SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {}

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
  List<Object> get props => [isDarkMode];
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<LoadSettingsEvent>(_onLoadSettings);
    
    // Load settings when bloc is created
    add(LoadSettingsEvent());
  }
  
  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final newDarkMode = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newDarkMode);
    emit(state.copyWith(isDarkMode: newDarkMode));
  }
  
  Future<void> _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(state.copyWith(isDarkMode: isDarkMode));
  }
}