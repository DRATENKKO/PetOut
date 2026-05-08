import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'services/pet_image_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final soundService = SoundService();
  await soundService.init();

  // Attempt to recover lost image data from killed Android activity
  final imageService = PetImageService();
  await imageService.retrieveLostData();

  runApp(
    PetOutApp(
      storageService: storageService,
      notificationService: notificationService,
      soundService: soundService,
    ),
  );
}
