// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:vclip/constants/animation_duration.dart';

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final RxList<AssetEntity> _videos;
  late final RxBool _isAlbumReady;

  AnimationController get getAnimationController => _animationController;
  Animation<double> get getAnimation => _animation;
  List<AssetEntity> get getVideos => _videos;
  bool get getIsAlbumReady => _isAlbumReady.value;

  @override
  Future<void> onInit() async {
    _isAlbumReady = false.obs;
    _videos = <AssetEntity>[].obs;
    await fetchData();
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationDuration.homePageIn,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    await _animationController.forward();
    super.onInit();
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  Future<void> fetchData() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      final videoAssetPathEntityList =
          await PhotoManager.getAssetPathList(type: RequestType.video);
      final recentAlbumPathEntity = videoAssetPathEntityList.isNotEmpty
          ? videoAssetPathEntityList[0]
          : null;
      _videos.value = recentAlbumPathEntity != null
          ? await recentAlbumPathEntity.getAssetListRange(
              start: 0,
              end: 1000000,
            )
          : <AssetEntity>[];
      _isAlbumReady.value = true;
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }
}
