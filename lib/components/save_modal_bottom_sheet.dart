// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/edit_page_controller.dart';

class SaveModalBottomSheet extends StatelessWidget {
  SaveModalBottomSheet({super.key});
  final EditPageController _editPageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: const BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: AppSizes.iconSize),
                  const Text(
                    AppStrings.saveToAlbumText,
                    style: AppTextStyles.boldTextStyle,
                  ),
                  InkWell(
                    onTap: () {
                      if (_editPageController.getIsProgressCompleted) {
                        Get.back();
                      }
                    },
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    highlightColor: Colors.transparent,
                    child: Obx(() {
                      return _editPageController.getIsProgressCompleted
                          ? SvgPicture.asset(
                              AppAssets.closeIconPath,
                              width: AppSizes.iconSize,
                              color: AppColors.primaryWhiteColor.withOpacity(1),
                            )
                          : const SizedBox();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildTimeSlider(),
              const SizedBox(height: 32),
              Obx(() {
                return Text(
                  _editPageController.getIsProgressCompleted
                      ? AppStrings.successText
                      : AppStrings.waitText,
                  style: AppTextStyles.mediumTextStyle,
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _buildTimeSlider() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Obx(() {
        return Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              backgroundColor: AppColors.primaryWhiteColor.withOpacity(0.7),
              strokeWidth: 8,
              value: _editPageController.getProgressPercentage / 100,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primaryWhiteColor,
              ),
            ),
            Center(
              child: _editPageController.getIsProgressCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryWhiteColor,
                      size: AppSizes.iconSize,
                    )
                  : Text(
                      '${_editPageController.getProgressPercentage.round()}%',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.boldTextStyle
                          .copyWith(color: AppColors.primaryWhiteColor),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
