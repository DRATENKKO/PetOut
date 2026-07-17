import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';
import '../models/pet.dart';
import '../cubit/pet_cubit.dart';
import '../services/pet_image_service.dart';

class PetSelectorScreen extends StatefulWidget {
  const PetSelectorScreen({super.key});

  @override
  State<PetSelectorScreen> createState() => _PetSelectorScreenState();
}

class _PetSelectorScreenState extends State<PetSelectorScreen> {
  final PetImageService _imageService = PetImageService();
  bool _isPickingImage = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Mis Mascotas',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPetDialog(context, isDark),
        backgroundColor: AppColors.beagleBrown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<PetCubit, PetState>(
        builder: (context, state) {
          if (state is PetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PetLoaded) {
            if (state.pets.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: state.pets.length,
              itemBuilder: (context, index) {
                final pet = state.pets[index];
                final isSelected = state.selectedPet?.id == pet.id;

                return _buildPetCard(pet, isSelected, isDark);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: isDark ? Colors.white24 : AppColors.beagleTan,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes mascotas aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona + para añadir una',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<PetCubit>().selectPet(pet.id);
      },
      onLongPress: () => _showPetOptions(context, pet, isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected ? AppColors.avatarGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkCard : Colors.white),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? Colors.white12 : AppColors.beagleCream,
                ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.beagleBrown : Colors.black)
                  .withValues(alpha: isSelected ? 0.3 : 0.05),
              blurRadius: isSelected ? 20 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? null
                    : AppColors.avatarGradient.scale(0.3),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                            ? Colors.white24
                            : AppColors.beagleTan.withValues(alpha: 0.5)),
                  width: 2,
                ),
              ),
              child: Center(
                child:
                    pet.imagePath != null && File(pet.imagePath!).existsSync()
                    ? ClipOval(
                        child: Image.file(
                          File(pet.imagePath!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            pet.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      )
                    : Text(pet.emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPetTypeName(pet.type),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white70
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  String _getPetTypeName(PetType type) {
    switch (type) {
      case PetType.dog:
        return 'Perro';
      case PetType.cat:
        return 'Gato';
      case PetType.other:
        return 'Otra mascota';
    }
  }

  void _showAddPetDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();
    PetType selectedType = PetType.dog;
    String? pickedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                color: isDark ? AppColors.darkCard : Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isDark
                              ? Colors.white24
                              : AppColors.beagleCream,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nueva Mascota',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Photo preview
                    Center(
                      child: GestureDetector(
                        onTap: _isPickingImage
                            ? null
                            : () => _showImageSourcePicker(
                                context,
                                isDark,
                                pickedImagePath,
                                (path) =>
                                    setModalState(() => pickedImagePath = path),
                              ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.avatarGradient,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white24
                                  : AppColors.beagleCream,
                              width: 3,
                            ),
                          ),
                          child:
                              pickedImagePath != null &&
                                  File(pickedImagePath!).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(pickedImagePath!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        pickedImagePath != null
                            ? 'Toca para cambiar foto'
                            : 'Toca para agregar foto (opcional)',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej: Luna, Max, Bella',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : AppColors.beagleCream.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tipo de mascota',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTypeOption(
                          PetType.dog,
                          '🐕',
                          'Perro',
                          selectedType,
                          isDark,
                          () => setModalState(() => selectedType = PetType.dog),
                        ),
                        const SizedBox(width: 12),
                        _buildTypeOption(
                          PetType.cat,
                          '🐈',
                          'Gato',
                          selectedType,
                          isDark,
                          () => setModalState(() => selectedType = PetType.cat),
                        ),
                        const SizedBox(width: 12),
                        _buildTypeOption(
                          PetType.other,
                          '🐾',
                          'Otra',
                          selectedType,
                          isDark,
                          () =>
                              setModalState(() => selectedType = PetType.other),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) return;

                          if (context.mounted) {
                            context.read<PetCubit>().addPet(
                              name: nameController.text.trim(),
                              type: selectedType,
                              imagePath: pickedImagePath,
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.beagleBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Añadir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showImageSourcePicker(
    BuildContext context,
    bool isDark,
    String? currentImagePath,
    ValueChanged<String?> onImagePicked,
  ) async {
    setState(() => _isPickingImage = true);
    try {
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            color: isDark ? AppColors.darkCard : Colors.white,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isDark ? Colors.white24 : AppColors.beagleCream,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Foto de mascota',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.beagleBrown.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.beagleBrown,
                      ),
                    ),
                    title: const Text('Tomar foto'),
                    subtitle: const Text('Usa la cámara'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final path = await _imageService.pickFromCamera();
                        onImagePicked(path);
                      } on PetImageException catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.secondary.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: const Text('Elegir de galería'),
                    subtitle: const Text('Selecciona una foto existente'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final path = await _imageService.pickFromGallery();
                        onImagePicked(path);
                      } on PetImageException catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                  ),
                  if (currentImagePath != null) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red.withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      title: const Text(
                        'Quitar foto',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onImagePicked(null);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  Widget _buildTypeOption(
    PetType type,
    String emoji,
    String label,
    PetType selectedType,
    bool isDark,
    VoidCallback onTap,
  ) {
    final isSelected = type == selectedType;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected ? AppColors.avatarGradient : null,
            color: isSelected
                ? null
                : (isDark
                      ? AppColors.darkBackground
                      : AppColors.beagleCream.withValues(alpha: 0.5)),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white12
                        : AppColors.beagleTan.withValues(alpha: 0.5),
                  ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPetOptions(BuildContext context, Pet pet, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            color: isDark ? AppColors.darkCard : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isDark ? Colors.white24 : AppColors.beagleCream,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(pet.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.secondary.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.secondary),
                  ),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<PetCubit>().deletePet(pet.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
