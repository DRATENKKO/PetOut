import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/storage_service.dart';

abstract class ThemeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final String selectedBreedId;

  ThemeLoaded({required this.selectedBreedId});

  @override
  List<Object?> get props => [selectedBreedId];
}

class ThemeCubit extends Cubit<ThemeState> {
  final StorageService _storageService;
  static const String _defaultBreedId = 'beagle';

  ThemeCubit(this._storageService) : super(ThemeInitial());

  Future<void> loadTheme() async {
    try {
      final breedId = await _storageService.getSelectedBreedThemeId();
      emit(ThemeLoaded(selectedBreedId: breedId ?? _defaultBreedId));
    } catch (e) {
      emit(ThemeLoaded(selectedBreedId: _defaultBreedId));
    }
  }

  Future<void> selectBreed(String breedId) async {
    await _storageService.setSelectedBreedThemeId(breedId);
    emit(ThemeLoaded(selectedBreedId: breedId));
  }
}
