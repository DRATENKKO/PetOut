import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../models/place.dart';

/// ═══════════════════════════════════════════════════════
/// 📸 PhotoGalleryScreen - Galería de Fotos
/// ═══════════════════════════════════════════════════════
///
/// Pantalla de galería de fotos por actividad:
/// - Fotos antes/después de cada actividad
/// - Slideshow de "mejores momentos"
/// - Tomar foto directamente desde la app
/// - Almacenamiento local organizado
class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, List<ActivityPhoto>> _photosByActivity = {};
  String? _selectedActivity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    // Load existing photos from storage
    // In production, this would load from the file system
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _takePhoto(String activityId) async {
    HapticFeedback.mediumImpact();

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );

    if (image != null) {
      // Save to app's photo storage
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${activityId}_$timestamp.jpg';
      final savedPath = '${photosDir.path}/$fileName';

      await File(image.path).copy(savedPath);

      final newPhoto = ActivityPhoto(
        id: 'photo_$timestamp',
        activityId: activityId,
        imagePath: savedPath,
        takenAt: DateTime.now(),
      );

      setState(() {
        if (!_photosByActivity.containsKey(activityId)) {
          _photosByActivity[activityId] = [];
        }
        _photosByActivity[activityId]!.add(newPhoto);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.background,
            elevation: 0,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '📸 Galería de Fotos',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            ),
            actions: [
              IconButton(
                onPressed: () => _showActivityPicker(context, isDark),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add_a_photo, color: AppColors.beagleBrown),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Empty state
          if (_photosByActivity.isEmpty && !_isLoading)
            SliverFillRemaining(child: _buildEmptyState(isDark))
          else ...[
            // Activity tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildActivityChip('all', '📸 Todas', isDark),
                    ..._photosByActivity.keys.map(
                      (activityId) => _buildActivityChip(
                        activityId,
                        '📷 $activityId',
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Photo grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final allPhotos = _photosByActivity.values
                        .expand((p) => p)
                        .toList();
                    if (index >= allPhotos.length) return null;

                    final photo = allPhotos[index];
                    return _PhotoTile(
                      photo: photo,
                      isDark: isDark,
                      onTap: () => _openPhotoViewer(context, allPhotos, index),
                    );
                  },
                  childCount: _photosByActivity.values.expand((p) => p).length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),

      // FAB to take photo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActivityPicker(context, isDark),
        backgroundColor: AppColors.beagleBrown,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          'Tomar Foto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.avatarGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.beagleBrown.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📷', style: TextStyle(fontSize: 50)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¡Sin fotos todavía!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Toma fotos de los momentos\nfelices con tu mascota',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showActivityPicker(context, isDark),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.beagleBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar Primera Foto'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChip(String activityId, String label, bool isDark) {
    final isSelected =
        _selectedActivity == activityId ||
        (_selectedActivity == null && activityId == 'all');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(
          () => _selectedActivity = activityId == 'all' ? null : activityId,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.beagleBrown
              : (isDark ? AppColors.darkCard : Colors.white),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.beagleBrown.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  void _showActivityPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          color: isDark ? AppColors.darkCard : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¿Para qué actividad?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildActivityOption(
              'walk',
              '🚶 Paseo',
              'Foto durante el paseo',
              isDark,
            ),
            _buildActivityOption('bath', '🛁 Baño', 'Foto del baño', isDark),
            _buildActivityOption(
              'food',
              '🍖 Comida',
              'Foto de la hora de comer',
              isDark,
            ),
            _buildActivityOption('play', '🎾 Juego', 'Foto jugando', isDark),
            _buildActivityOption(
              'other',
              '⭐ Otro',
              'Otro momento especial',
              isDark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOption(
    String id,
    String emoji,
    String desc,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _takePhoto(id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.darkElevated : AppColors.beagleCream,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _openPhotoViewer(
    BuildContext context,
    List<ActivityPhoto> photos,
    int index,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _PhotoViewer(photos: photos, initialIndex: index),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// 🖼️ _PhotoTile - Tesela de Foto
/// ═══════════════════════════════════════════════════════
class _PhotoTile extends StatelessWidget {
  final ActivityPhoto photo;
  final bool isDark;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.photo,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? AppColors.darkCard : AppColors.beagleCream,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo.imagePath.isNotEmpty
                ? Image.file(
                    File(photo.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.beagleCream,
      child: Center(
        child: Text(
          '📷',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.beagleBrown.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// 🔍 _PhotoViewer - Visor de Fotos Full Screen
/// ═══════════════════════════════════════════════════════
class _PhotoViewer extends StatefulWidget {
  final List<ActivityPhoto> photos;
  final int initialIndex;

  const _PhotoViewer({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo page view
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return InteractiveViewer(
                child: Center(
                  child: Hero(
                    tag: 'photo_${photo.id}',
                    child: photo.imagePath.isNotEmpty
                        ? Image.file(File(photo.imagePath), fit: BoxFit.contain)
                        : const Text('📷', style: TextStyle(fontSize: 100)),
                  ),
                ),
              );
            },
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Text(
                    '${_currentIndex + 1}/${widget.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Share photo
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                    ).format(widget.photos[_currentIndex].takenAt),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'h:mm a',
                    ).format(widget.photos[_currentIndex].takenAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (widget.photos[_currentIndex].caption != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.photos[_currentIndex].caption!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
