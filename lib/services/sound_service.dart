import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _barkTimer;
  bool _isBarking = false;
  bool? _assetAvailable;

  Future<void> init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _checkAssetAvailability();
  }

  Future<void> _checkAssetAvailability() async {
    try {
      await rootBundle.load('assets/sounds/dog_bark.mp3');
      _assetAvailable = true;
    } catch (_) {
      _assetAvailable = false;
    }
  }

  bool get isDogBarkAssetAvailable => _assetAvailable ?? false;

  Future<void> playDogBark() async {
    if (_assetAvailable != true) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/dog_bark.mp3'));
    } catch (e) {
      // Silently fail if audio can't play
    }
  }

  void startBarkingRepeat({int intervalSeconds = 4}) {
    if (_isBarking) return;
    if (_assetAvailable != true) return;
    _isBarking = true;

    playDogBark();

    _barkTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => playDogBark(),
    );
  }

  void stopBarking() {
    _isBarking = false;
    _barkTimer?.cancel();
    _barkTimer = null;
    _audioPlayer.stop();
  }

  Future<void> dispose() async {
    stopBarking();
    await _audioPlayer.dispose();
  }
}
