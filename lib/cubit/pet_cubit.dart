import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../models/pet.dart';
import '../services/storage_service.dart';

abstract class PetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PetInitial extends PetState {}

class PetLoading extends PetState {}

class PetLoaded extends PetState {
  final List<Pet> pets;
  final Pet? selectedPet;

  PetLoaded({required this.pets, this.selectedPet});

  @override
  List<Object?> get props => [pets, selectedPet];
}

class PetError extends PetState {
  final String message;

  PetError(this.message);

  @override
  List<Object?> get props => [message];
}

class PetCubit extends Cubit<PetState> {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  PetCubit(this._storageService) : super(PetInitial());

  StorageService get storage => _storageService;

  Future<void> loadPets() async {
    emit(PetLoading());
    try {
      final pets = await _storageService.getPets();
      final selectedPetId = await _storageService.getSelectedPetId();
      Pet? selectedPet;

      if (pets.isNotEmpty) {
        if (selectedPetId != null) {
          selectedPet = pets.firstWhere(
            (p) => p.id == selectedPetId,
            orElse: () => pets.first,
          );
        } else {
          selectedPet = pets.first;
          await _storageService.setSelectedPetId(selectedPet.id);
        }
      }

      emit(PetLoaded(pets: pets, selectedPet: selectedPet));
    } catch (e) {
      emit(PetError(e.toString()));
    }
  }

  Future<void> addPet({
    required String name,
    required PetType type,
    String? imagePath,
  }) async {
    final pet = Pet(
      id: _uuid.v4(),
      name: name,
      type: type,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    await _storageService.addPet(pet);

    if (state is PetLoaded) {
      final currentState = state as PetLoaded;
      if (currentState.selectedPet == null) {
        await _storageService.setSelectedPetId(pet.id);
      }
    }

    await loadPets();
  }

  Future<void> updatePet(Pet pet) async {
    await _storageService.updatePet(pet);
    await loadPets();
  }

  Future<void> deletePet(String petId) async {
    await _storageService.deletePet(petId);
    final currentState = state;
    if (currentState is PetLoaded && currentState.selectedPet?.id == petId) {
      final pets = await _storageService.getPets();
      if (pets.isNotEmpty) {
        await _storageService.setSelectedPetId(pets.first.id);
      }
    }
    await loadPets();
  }

  Future<void> selectPet(String petId) async {
    await _storageService.setSelectedPetId(petId);
    await loadPets();
  }

  Future<bool> hasPets() async {
    final pets = await _storageService.getPets();
    return pets.isNotEmpty;
  }
}
