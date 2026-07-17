import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/pet_breeds.dart';
import '../cubit/theme_cubit.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
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
          'Temas',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final selectedBreedId = state is ThemeLoaded
              ? state.selectedBreedId
              : 'beagle';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elige tu estilo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona el tema que más te guste',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('🐕 Perros', isDark),
                const SizedBox(height: 16),
                _buildBreedsGrid(
                  PetBreeds.allBreeds
                      .where(
                        (b) => [
                          'beagle',
                          'husky',
                          'golden',
                          'pastor',
                          'bulldog',
                          'dalmata',
                          'kiltro',
                          'mezcla_chica',
                          'mezcla_grande',
                        ].contains(b.id),
                      )
                      .toList(),
                  isDark,
                  selectedBreedId,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('🐈 Gatos', isDark),
                const SizedBox(height: 16),
                _buildBreedsGrid(
                  PetBreeds.allBreeds
                      .where((b) => ['siames', 'persa'].contains(b.id))
                      .toList(),
                  isDark,
                  selectedBreedId,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('✨ Especiales', isDark),
                const SizedBox(height: 16),
                _buildBreedsGrid(
                  PetBreeds.allBreeds
                      .where(
                        (b) => [
                          'arcobal',
                          'nocturn',
                          'jungla',
                          'oceano',
                        ].contains(b.id),
                      )
                      .toList(),
                  isDark,
                  selectedBreedId,
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppColors.avatarGradient,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreedsGrid(
    List<PetBreed> breeds,
    bool isDark,
    String selectedBreedId,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: breeds.length,
      itemBuilder: (context, index) {
        final isSelected = selectedBreedId == breeds[index].id;
        return _BreedCard(
          breed: breeds[index],
          isSelected: isSelected,
          isDark: isDark,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<ThemeCubit>().selectBreed(breeds[index].id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tema ${breeds[index].name} aplicado'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}

class _BreedCard extends StatelessWidget {
  final PetBreed breed;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _BreedCard({
    required this.breed,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border.all(
            color: isSelected ? breed.colors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? breed.colors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        breed.colors.primary.withValues(alpha: 0.15),
                        breed.colors.secondary.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [breed.colors.primary, breed.colors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: breed.colors.primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        breed.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    breed.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    breed.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: breed.colors.primary,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
