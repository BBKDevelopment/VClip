// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vclip/components/save_modal_bottom_sheet.dart';
import 'package:vclip/components/settings_modal_bottom_sheet.dart';
import 'package:vclip/constants/animation_duration.dart';
import 'package:vclip/utilities/time_formatter.dart';
import 'package:video_player/video_player.dart';

class EditPageController extends GetxController
    with SingleGetTickerProviderMixin {
  late final FlutterFFmpeg _flutterFFmpeg;
  late final FlutterFFmpegConfig _fFmpegConfig;
  late final Rx<Duration> _currentPositionInSeconds;
  late final RxDouble _firstControllersPosition;
  late final RxDouble _secondControllerPosition;
  late final RxDouble _soundValue;
  late final RxDouble _speedValue;
  late final RxDouble _qualityValue;
  late final RxDouble _progressPercentage;
  late final RxInt _firstControllersTime;
  late final RxInt _secondControllerTime;
  late final RxBool isVideoReady;
  late final RxBool _isVideoPlaying;
  late final RxBool _isProgressCompleted;
  late final AnimationController _staggeredAnimationController;
  late final AnimationController _timelineAnimationController;
  late final Animation<double> _staggeredAnimation;
  late final Animation<double> _timelineAnimation;
  late final Tween<double> _tween;
  late VideoPlayerController _videoPlayerController;
  late File _file;
  late String _qualityValueText;
  late String _speedValueText;
  late double _totalWidth;
  late double _widthPerSecond;
  late int _durationInSeconds;
  late bool _needRefresh;

  AnimationController get getStaggeredAnimationController =>
      _staggeredAnimationController;
  Animation<double> get getStaggeredAnimation => _staggeredAnimation;
  Animation<double> get getAnimation => _timelineAnimation;
  VideoPlayerController get getVideoPlayerController => _videoPlayerController;
  File get getFile => _file;
  Duration get getCurrentPositionInSeconds => _currentPositionInSeconds.value;
  String get getSpeedValueText => _speedValueText;
  String get getQualityValueText => _qualityValueText;
  double get getFirstControllersPosition => _firstControllersPosition.value;
  double get getSecondControllerPosition => _secondControllerPosition.value;
  double get getSoundValue => _soundValue.value;
  double get getSpeedValue => _speedValue.value;
  double get getQualityValue => _qualityValue.value;
  double get getProgressPercentage => _progressPercentage.value;
  int get getFirstControllersTime => _firstControllersTime.value;
  int get getSecondControllerTime => _secondControllerTime.value;
  bool get getIsVideoPlaying => _isVideoPlaying.value;
  bool get getIsProgressCompleted => _isProgressCompleted.value;
  bool get getNeedRefresh => _needRefresh;

  @override
  void onInit() {
    _flutterFFmpeg = FlutterFFmpeg();
    _fFmpegConfig = FlutterFFmpegConfig();
    _file = File('');
    isVideoReady = false.obs;
    _firstControllersPosition = 0.0.obs;
    _secondControllerPosition = 300.0.obs;
    _currentPositionInSeconds = Duration.zero.obs;
    _firstControllersTime = 0.obs;
    _secondControllerTime = 0.obs;
    _isVideoPlaying = false.obs;
    _soundValue = 1.0.obs;
    _speedValueText = '1.00';
    _speedValue = 3.0.obs;
    _qualityValueText = 'Default';
    _qualityValue = 6.0.obs;
    _progressPercentage = 0.0.obs;
    _isProgressCompleted = false.obs;
    _needRefresh = false;
    _videoPlayerController = VideoPlayerController.asset('');
    _staggeredAnimationController = AnimationController(
      vsync: this,
      duration: AnimationDuration.editPageIn,
    );
    _staggeredAnimation =
        Tween<double>(begin: 0, end: 1).animate(_staggeredAnimationController);
    _timelineAnimationController = AnimationController(
      vsync: this,
      duration: Duration.zero,
    );
    _tween = Tween(begin: 20, end: 100);
    _timelineAnimation = _tween.animate(_timelineAnimationController)
      ..addListener(update);
    super.onInit();
  }

  @override
  void onClose() {
    _videoPlayerController.dispose();
    _timelineAnimationController.dispose();
    _staggeredAnimationController.dispose();
    super.onClose();
  }

  Future<void> setFile(Future<File?> file) async {
    _file = await file ?? File('');
  }

  Future<void> close() async {
    if (_file.path == '') return;
    _isVideoPlaying.value = false;
    _removeVideoListener();
    isVideoReady.value = false;
    _currentPositionInSeconds.value = Duration.zero;
    _firstControllersPosition.value = 0.0;
    _secondControllerPosition.value = Get.width - 64.0;
    _totalWidth = 0.0;
    _durationInSeconds = 0;
    _widthPerSecond = 0.0;
    _firstControllersTime.value = 0;
    _secondControllerTime.value = 0;
    _timelineAnimationController.stop();
    await _videoPlayerController.dispose();
  }

  Future<void> initVideoPlayer() async {
    if (_file.path == '') return;
    _videoPlayerController = VideoPlayerController.file(_file);
    await _videoPlayerController.initialize();
    _removeVideoListener();
    isVideoReady.value = true;
    _secondControllerTime.value =
        _videoPlayerController.value.duration.inSeconds;
    _timeCalculator();
    resetAnimation();
  }

  void _addVideoListener() {
    _videoPlayerController.addListener(() async {
      if (_currentPositionInSeconds.value.inSeconds !=
          _videoPlayerController.value.position.inSeconds) {
        _currentPositionInSeconds.value = _videoPlayerController.value.position;
      }
      if (_videoPlayerController.value.position ==
          _videoPlayerController.value.duration) {
        await _videoPlayerController
            .seekTo(Duration(seconds: _firstControllersTime.value));
        await _videoPlayerController.pause();
        resetAnimation();
        _isVideoPlaying.value = false;
      }
      if (_videoPlayerController.value.position.inSeconds ==
          Duration(seconds: _secondControllerTime.value).inSeconds) {
        await _videoPlayerController
            .seekTo(Duration(seconds: _firstControllersTime.value));
        await _videoPlayerController.pause();
        resetAnimation();
        _isVideoPlaying.value = false;
      }
    });
  }

  void _removeVideoListener() {
    _videoPlayerController.removeListener(() async {
      if (_currentPositionInSeconds.value.inSeconds !=
          _videoPlayerController.value.position.inSeconds) {
        _currentPositionInSeconds.value = _videoPlayerController.value.position;
      }
      if (_videoPlayerController.value.position ==
          _videoPlayerController.value.duration) {
        await _videoPlayerController
            .seekTo(Duration(seconds: _firstControllersTime.value));
        await _videoPlayerController.pause();
        resetAnimation();
        _isVideoPlaying.value = false;
      }
      if (_videoPlayerController.value.position.inSeconds ==
          Duration(seconds: _secondControllerTime.value).inSeconds) {
        await _videoPlayerController
            .seekTo(Duration(seconds: _firstControllersTime.value));
        await _videoPlayerController.pause();
        resetAnimation();
        _isVideoPlaying.value = false;
      }
    });
  }

  void _timeCalculator() {
    //screen width - spaces - left distance - right distance
    _totalWidth = (Get.width - 44.0) - 20.0 - 20.0;
    _durationInSeconds = _videoPlayerController.value.duration.inSeconds;
    _widthPerSecond = _totalWidth / _durationInSeconds;
  }

  int _controllerTimeCalculator(double position) {
    return (position / _widthPerSecond).round();
  }

  Future<void> setFirstControllersPosition(double position) async {
    if (!isVideoReady.value) return;
    if (position < 0 || position > Get.width - 64.0) return;
    if (position > _secondControllerPosition.value - 20.0) return;
    if (_controllerTimeCalculator(position) >=
        _controllerTimeCalculator(_secondControllerPosition.value)) return;
    _firstControllersPosition.value = position;
    _firstControllersTime.value = _controllerTimeCalculator(position);
    _currentPositionInSeconds.value =
        Duration(seconds: _controllerTimeCalculator(position));
    await _videoPlayerController
        .seekTo(Duration(seconds: _firstControllersTime.value));
    _isVideoPlaying.value = false;
  }

  Future<void> setSecondControllerPosition(double position) async {
    if (!isVideoReady.value) return;
    if (position < 0 || position > Get.width - 64.0) return;
    if (position < _firstControllersPosition.value + 20.0) return;
    if (_controllerTimeCalculator(position) <=
        _controllerTimeCalculator(_firstControllersPosition.value)) return;
    _secondControllerPosition.value = position;
    _secondControllerTime.value = _controllerTimeCalculator(position);
    await _videoPlayerController
        .seekTo(Duration(seconds: _firstControllersTime.value));
    _isVideoPlaying.value = false;
  }

  void resetAnimation() {
    if (!isVideoReady.value) return;

    _timelineAnimationController.duration = Duration(
      milliseconds: (double.parse(
                ((_secondControllerTime.value - _firstControllersTime.value) *
                        (1 / _videoPlayerController.value.playbackSpeed))
                    .toStringAsFixed(3),
              ) *
              1000)
          .toInt(),
    );

    _timelineAnimationController.reset();
    _tween.begin = _firstControllersPosition.value + 20.0;
    _tween.end = _secondControllerPosition.value - 2.0;
  }

  Future<void> stopVideo() async {
    _isVideoPlaying.value = false;
    _removeVideoListener();
    _timelineAnimationController.stop();
    await _videoPlayerController.pause();
  }

  Future<void> onTappedPlayButton() async {
    if (_videoPlayerController.value.isPlaying) {
      _isVideoPlaying.value = false;
      _removeVideoListener();
      _timelineAnimationController.stop();
      await _videoPlayerController.pause();
    } else {
      _isVideoPlaying.value = true;
      _addVideoListener();
      await _timelineAnimationController.forward();
      await _videoPlayerController.play();
    }
  }

  Future<void> setSound(int sound) async {
    switch (sound) {
      case 0:
        await _videoPlayerController.setVolume(0);
      case 1:
        await _videoPlayerController.setVolume(1);
        _speedValueText = '1.00';
        await _videoPlayerController.setPlaybackSpeed(1);
        _speedValue.value = 3.0;
      default:
        break;
    }
    await _videoPlayerController
        .seekTo(Duration(seconds: _firstControllersTime.value));
    resetAnimation();
    _soundValue.value = sound.toDouble();
  }

  Future<void> setSpeed(double speed) async {
    switch (speed.round()) {
      case 0:
        _speedValueText = '0.25';
        await _videoPlayerController.setPlaybackSpeed(0.25);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      case 1:
        _speedValueText = '0.50';
        await _videoPlayerController.setPlaybackSpeed(0.50);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      case 2:
        _speedValueText = '0.75';
        await _videoPlayerController.setPlaybackSpeed(0.75);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      case 3:
        _speedValueText = '1.00';
        await _videoPlayerController.setPlaybackSpeed(1);
      case 4:
        _speedValueText = '1.25';
        await _videoPlayerController.setPlaybackSpeed(1.25);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      case 5:
        _speedValueText = '1.50';
        await _videoPlayerController.setPlaybackSpeed(1.50);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      case 6:
        _speedValueText = '1.75';
        await _videoPlayerController.setPlaybackSpeed(1.75);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      case 7:
        _speedValueText = '2.00';
        await _videoPlayerController.setPlaybackSpeed(2);
        await _videoPlayerController.setVolume(0);
        _soundValue.value = _videoPlayerController.value.volume;
      default:
        break;
    }
    await _videoPlayerController
        .seekTo(Duration(seconds: _firstControllersTime.value));
    resetAnimation();
    _speedValue.value = speed;
  }

  void setQuality(double quality) {
    switch (quality.round()) {
      case 0:
        _qualityValueText = '240p';
      case 1:
        _qualityValueText = '480p';
      case 2:
        _qualityValueText = '720p';
      case 3:
        _qualityValueText = '1080p';
      case 4:
        _qualityValueText = '1440p';
      case 5:
        _qualityValueText = '2160p';
      case 6:
        _qualityValueText = 'Default';
      default:
        break;
    }
    _qualityValue.value = quality;
  }

  Future<void> onTappedSettingsButton() async {
    if (!isVideoReady.value) return;
    await stopVideo();
    await showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      useRootNavigator: true,
      elevation: 4,
      builder: (context) => SettingsModalBottomSheet(),
    );
  }

  Future<void> _callSaveBottomSheet() async {
    await showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      useRootNavigator: true,
      elevation: 4,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: SaveModalBottomSheet(),
      ),
    );
  }

  Future<void> onTappedSaveButton() async {
    if (!isVideoReady.value) return;
    await stopVideo();

    await _callSaveBottomSheet();

    var rc = 0;
    _isProgressCompleted.value = false;

    Directory appDocDirectory;
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = (await getExternalStorageDirectory())!;
    }

    final safeOriginalVideoPath = '"${_file.path}"';

    final midVideoPath = join(appDocDirectory.path, 'Video-Temp.mp4');
    final safeMidVideoPath = '"$midVideoPath"';

    var finalVideoPath = '';

    final audioCommand =
        _videoPlayerController.value.volume == 0.0 ? '-an' : '';

    final qualityCommand = _qualityValueText == 'Default'
        ? ''
        : '-vf scale=${_qualityValueText.substring(0, _qualityValueText.length - 1)}:-2,setsar=1:1';

    final startPositionCommand = '-ss ${TimeFormatter.formatHHmmss(
      duration: Duration(seconds: _firstControllersTime.value),
    )}';

    final outputVideoDurationCommand = '-t ${TimeFormatter.formatHHmmss(
      duration: Duration(
        seconds: _secondControllerTime.value - _firstControllersTime.value,
      ),
    )}';

    final speedCommand = _videoPlayerController.value.playbackSpeed == 1.0
        ? ''
        : '-filter:v setpts=PTS/${_videoPlayerController.value.playbackSpeed}';

    /*"-filter_complex " +
        '"[0:v]setpts=PTS/${_videoPlayerController.value.playbackSpeed}[v]; [0:a]atempo=${_videoPlayerController.value.playbackSpeed}[a]" ' +
        "-map " +
        '"[v]" ' +
        "-map " +
        '"[a]"';*/

    /*_videoPlayerController.value.playbackSpeed ==
            1.0
        ? ""
        : "-filter:v setpts=PTS/${_videoPlayerController.value.playbackSpeed}";*/

    double tempPercentage;

    await _fFmpegConfig.enableStatistics();
    _fFmpegConfig.enableStatisticsCallback((statistics) {
      tempPercentage = (statistics.time / 10) /
          ((_secondControllerTime.value - _firstControllersTime.value));
      _progressPercentage.value = tempPercentage > 100 ? 100 : tempPercentage;
    });

    //ToDo: Gif olarak kaydetme imkanı sunulabilinir.
    try {
      rc = await _flutterFFmpeg.execute(
        '$audioCommand $startPositionCommand -i $safeOriginalVideoPath $outputVideoDurationCommand -y -safe 0 -vcodec libx264 -crf 18 $qualityCommand $safeMidVideoPath',
      );
    } on Exception catch (exception) {
      log(
        'Try Catch for FFMPEG Execution $exception',
        name: 'EXCEPTION on FFMPEG',
      );
    } catch (error) {
      log('Try Catch for FFMPEG Execution $error', name: 'ERROR on FFMPEG');
    }

    _fFmpegConfig.enableStatisticsCallback((statistics) {
      tempPercentage = (statistics.time / 10) /
          ((_secondControllerTime.value - _firstControllersTime.value) /
              double.parse(_speedValueText));
      _progressPercentage.value = tempPercentage > 100 ? 100 : tempPercentage;
    });

    if (speedCommand != '') {
      finalVideoPath = join(
        appDocDirectory.path,
        'Video-${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      final safeFinalOutputPath = '"$finalVideoPath"';
      try {
        rc = await _flutterFFmpeg.execute(
          '-i $safeMidVideoPath -y -safe 0 -vcodec libx264 -crf 18 $speedCommand $safeFinalOutputPath',
        );
      } on Exception catch (exception) {
        log(
          'Try Catch for FFMPEG Execution $exception',
          name: 'EXCEPTION on FFMPEG',
        );
      } catch (error) {
        log('Try Catch for FFMPEG Execution $error', name: 'ERROR on FFMPEG');
      }
    }

    await _fFmpegConfig.disableStatistics();

    await _saveToGallery(finalVideoPath == '' ? midVideoPath : finalVideoPath);
    _progressPercentage.value = 100.0;
    _isProgressCompleted.value = true;

    _needRefresh = rc == 0 ? true : false;
    await _fFmpegConfig.disableStatistics();
  }

  void setRefresh(bool state) {
    _needRefresh = false;
  }

  Future<void> _saveToGallery(String path) async {
    //ToDo: Başarı durumu için ayrı bir kontrol yapılıp olumsuz icon gösterilerilebilinir.
    await ImageGallerySaver.saveFile(path);
    try {
      final dir = Directory(path);
      dir.deleteSync(recursive: true);
    } on Exception catch (exception) {
      log(
        'Try Catch for FFMPEG Execution $exception',
        name: 'EXCEPTION on FFMPEG',
      );
    } catch (error) {
      log('Try Catch for FFMPEG Execution $error', name: 'ERROR on FFMPEG');
    }
  }
}
