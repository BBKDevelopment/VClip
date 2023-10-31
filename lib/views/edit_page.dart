// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vclip/components/vclip_app_bar.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/edit_page_controller.dart';
import 'package:vclip/utilities/time_formatter.dart';
import 'package:video_player/video_player.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late final EditPageController _editPageController;

  @override
  void initState() {
    super.initState();
    _editPageController = Get.find();
    //After Build Completed This Lines Will Work
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editPageController.initVideoPlayer();
    });
  }

  @override
  void dispose() {
    _editPageController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VClipAppBar(),
      body: Container(
        color: AppColors.primaryColorDark,
        child: Column(
          children: [
            Flexible(
              child: AnimatedBuilder(
                animation: _editPageController.getStaggeredAnimation,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _editPageController.getStaggeredAnimation,
                      curve: const Interval(
                        0.40,
                        0.70,
                        curve: Curves.easeInOutCubic,
                      ),
                    ),
                    child: child,
                  );
                },
                child: Obx(() {
                  return _editPageController.isVideoReady.value
                      ? _buildVideoPlayer()
                      : const Center(
                          child: Text(
                            AppStrings.selectVideoText,
                            style: AppTextStyles.semiBoldTextStyle,
                          ),
                        );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 22, bottom: 10),
              child: _buildControlPanel(context),
            ),
          ],
        ),
      ),
    );
  }

  Stack _buildVideoPlayer() {
    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            child: (_editPageController
                        .getVideoPlayerController.value.aspectRatio <
                    1)
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSizes.verticalVideoBorderRadius,
                      ),
                      child: SizedBox(
                        height: _editPageController
                            .getVideoPlayerController.value.size.height,
                        width: _editPageController
                            .getVideoPlayerController.value.size.width,
                        child: VideoPlayer(
                          _editPageController.getVideoPlayerController,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: _editPageController
                        .getVideoPlayerController.value.size.height,
                    width: _editPageController
                        .getVideoPlayerController.value.size.width,
                    child: VideoPlayer(
                      _editPageController.getVideoPlayerController,
                    ),
                  ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _editPageController.onTappedPlayButton();
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Obx(() {
                return _editPageController.getIsVideoPlaying
                    ? const SizedBox()
                    : Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryColorDark.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            //center is left:15
                            left: 17,
                            child: SvgPicture.asset(
                              AppAssets.playIconPath,
                            ),
                          ),
                        ],
                      );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Column _buildControlPanel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          color: AppColors.primaryColor,
          thickness: 1,
          height: 0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _editPageController.onTappedSettingsButton,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                highlightColor: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _editPageController.getStaggeredAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return _buildSlideTransition(
                      child,
                      beginOffset: const Offset(-4, 0),
                    );
                  },
                  child: SvgPicture.asset(
                    AppAssets.settingIconPath,
                    height: AppSizes.iconSize,
                    width: AppSizes.iconSize,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await _editPageController.onTappedSaveButton();
                },
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                highlightColor: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _editPageController.getStaggeredAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return _buildSlideTransition(
                      child,
                      beginOffset: const Offset(4, 0),
                    );
                  },
                  child: SvgPicture.asset(
                    AppAssets.saveIconPath,
                    height: AppSizes.iconSize,
                    width: AppSizes.iconSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.primaryColor,
          thickness: 1,
          height: 0,
        ),
        AnimatedBuilder(
          animation: _editPageController.getStaggeredAnimation,
          builder: (BuildContext context, Widget? child) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: _editPageController.getStaggeredAnimation,
                curve: const Interval(
                  0.70,
                  1,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: child,
            );
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      return Text(
                        TimeFormatter.format(
                          duration:
                              _editPageController.getCurrentPositionInSeconds,
                        ),
                        style: AppTextStyles.regularTextStyle,
                      );
                    }),
                    Obx(() {
                      return _editPageController.isVideoReady.value
                          ? Text(
                              TimeFormatter.format(
                                duration: _editPageController
                                    .getVideoPlayerController.value.duration,
                              ),
                              style: AppTextStyles.regularTextStyle,
                            )
                          : const Text(
                              '00:00',
                              style: AppTextStyles.regularTextStyle,
                            );
                    }),
                  ],
                ),
              ),
              _buildTimeline(),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: SizedBox(
                  height: 20,
                  child: Stack(
                    children: [
                      Obx(() {
                        return Positioned(
                          left:
                              _editPageController.getFirstControllersPosition <
                                      8
                                  ? 0
                                  : _editPageController
                                                  .getFirstControllersPosition +
                                              36 >
                                          _editPageController
                                              .getSecondControllerPosition
                                      ? _editPageController
                                              .getFirstControllersPosition -
                                          16
                                      : _editPageController
                                              .getFirstControllersPosition -
                                          8,
                          child: Text(
                            TimeFormatter.format(
                              duration: _editPageController.isVideoReady.value
                                  ? Duration(
                                      seconds: _editPageController
                                          .getFirstControllersTime,
                                    )
                                  : Duration.zero,
                            ),
                            style: AppTextStyles.regularTextStyle,
                          ),
                        );
                      }),
                      Obx(
                        () {
                          return Positioned(
                            left: _editPageController
                                        .getSecondControllerPosition >
                                    Get.width - 74
                                ? null
                                : _editPageController
                                                .getSecondControllerPosition -
                                            36 <
                                        _editPageController
                                            .getFirstControllersPosition
                                    ? _editPageController
                                        .getSecondControllerPosition
                                    : _editPageController
                                            .getSecondControllerPosition -
                                        8,
                            right: _editPageController
                                        .getSecondControllerPosition >
                                    Get.width - 74
                                ? 0
                                : null,
                            child: Text(
                              TimeFormatter.format(
                                duration: _editPageController.isVideoReady.value
                                    ? Duration(
                                        seconds: _editPageController
                                            .getSecondControllerTime,
                                      )
                                    : Duration.zero,
                              ),
                              style: AppTextStyles.regularTextStyle,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.primaryColor,
          thickness: 1,
          height: 0,
        ),
      ],
    );
  }

  Stack _buildTimeline() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.timelineLightColor,
            borderRadius: BorderRadius.circular(AppSizes.generalBorderRadius),
          ),
        ),
        Obx(() {
          return Positioned(
            left: _editPageController.getFirstControllersPosition + 20.0,
            child: Container(
              height: 100,
              width: _editPageController.getSecondControllerPosition -
                  _editPageController.getFirstControllersPosition -
                  20.0,
              color: AppColors.timelineDarkColor,
            ),
          );
        }),
        _buildFirstController(),
        _buildSecondController(),
        _verticalLine(),
      ],
    );
  }

  Obx _buildFirstController() {
    return Obx(() {
      return Positioned(
        top: -4,
        left: _editPageController.getFirstControllersPosition,
        child: Draggable(
          axis: Axis.horizontal,
          feedback: const SizedBox(),
          childWhenDragging: Container(
            height: 108,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppSizes.generalBorderRadius),
            ),
          ),
          onDragStarted: () {
            if (_editPageController.isVideoReady.value) {
              _editPageController.stopVideo();
            }
          },
          onDragUpdate: (details) {
            _editPageController
                .setFirstControllersPosition(details.localPosition.dx - 22.0);
          },
          onDragEnd: (details) {
            _editPageController.resetAnimation();
            /*_editPageController
                    .setVideoPosition(previewProvider.videoPlayerController);*/
          },
          child: Container(
            height: 108,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppSizes.generalBorderRadius),
            ),
          ),
        ),
      );
    });
  }

  Obx _buildSecondController() {
    return Obx(() {
      return Positioned(
        top: -4,
        left: _editPageController.getSecondControllerPosition,
        child: Draggable(
          axis: Axis.horizontal,
          feedback: const SizedBox(),
          childWhenDragging: Container(
            height: 108,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppSizes.generalBorderRadius),
            ),
          ),
          onDragStarted: () {
            if (_editPageController.isVideoReady.value) {
              _editPageController.stopVideo();
            }
          },
          onDragUpdate: (details) {
            _editPageController
                .setSecondControllerPosition(details.localPosition.dx - 22.0);
          },
          onDragEnd: (details) {
            _editPageController.resetAnimation();
            /*_editPageController
                    .setVideoPosition(previewProvider.videoPlayerController);*/
          },
          child: Container(
            height: 108,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppSizes.generalBorderRadius),
            ),
          ),
        ),
      );
    });
  }

  GetBuilder<EditPageController> _verticalLine() {
    return GetBuilder<EditPageController>(
      builder: (_) {
        return Positioned(
          left: _editPageController.getAnimation.value,
          child: Container(
            height: 100,
            width: 2,
            decoration: BoxDecoration(
              color: AppColors.primaryWhiteColor,
              borderRadius: BorderRadius.circular(AppSizes.generalBorderRadius),
            ),
          ),
        );
      },
    );
  }

  SlideTransition _buildSlideTransition(
    Widget? child, {
    required Offset beginOffset,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: const Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _editPageController.getStaggeredAnimation,
          curve: const Interval(
            0,
            0.40,
            curve: Curves.easeInOutCubic,
          ),
        ),
      ),
      child: child,
    );
  }
}
