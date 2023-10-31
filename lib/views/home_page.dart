// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:vclip/components/vclip_app_bar.dart';
import 'package:vclip/components/video_thumbnail.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/home_page_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key}) {
    _homePageController = Get.find();
  }
  late final HomePageController _homePageController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VClipAppBar(),
      body: Obx(
        () {
          return Container(
            color: AppColors.primaryColorDark,
            child: _homePageController.getIsAlbumReady
                ? _buildAnimatedGridView()
                : Container(),
          );
        },
      ),
    );
  }

  //ToDo: Swipe to refresth eklenebilinir.
  AnimatedBuilder _buildAnimatedGridView() {
    return AnimatedBuilder(
      animation: _homePageController.getAnimation,
      builder: (BuildContext context, Widget? child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _homePageController.getAnimation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        );
      },
      child: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        childAspectRatio: AppSizes.gridViewItemAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: List.generate(
          _homePageController.getVideos.length,
          (index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: Duration.zero,
              columnCount: 3,
              child: ScaleAnimation(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 50),
                child: VideoThumbnail(
                  _homePageController.getVideos[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
