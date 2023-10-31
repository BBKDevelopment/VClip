// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/edit_page_controller.dart';

class SettingsModalBottomSheet extends StatelessWidget {
  SettingsModalBottomSheet({super.key});
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: AppSizes.iconSize),
                  const Text(
                    AppStrings.settingsText,
                    style: AppTextStyles.boldTextStyle,
                  ),
                  InkWell(
                    onTap: Get.back,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    highlightColor: Colors.transparent,
                    child: SvgPicture.asset(
                      AppAssets.closeIconPath,
                      width: AppSizes.iconSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                AppStrings.videoSoundText,
                style: AppTextStyles.regularTextStyle,
              ),
              const SizedBox(height: 32),
              Center(child: _buildSoundSwitch()),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  AppStrings.noticeText,
                  style: AppTextStyles.smallLightTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                AppStrings.videoSpeedText,
                style: AppTextStyles.regularTextStyle,
              ),
              const SizedBox(height: 32),
              _buildSpeedSlider(context),
              const SizedBox(height: 32),
              const Text(
                AppStrings.videoQualityText,
                style: AppTextStyles.regularTextStyle,
              ),
              const SizedBox(height: 32),
              _buildQualitySlider(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Obx _buildSoundSwitch() {
    return Obx(() {
      return ToggleSwitch(
        minWidth: 90,
        minHeight: 28,
        cornerRadius: 50,
        activeBgColor: const [AppColors.primaryWhiteColor],
        activeFgColor: AppColors.primaryColor,
        inactiveBgColor: AppColors.primaryWhiteColor.withOpacity(0.7),
        inactiveFgColor: AppColors.primaryColor,
        labels: const [AppStrings.offText, AppStrings.onText],
        icons: const [Icons.volume_mute_rounded, Icons.volume_down_rounded],
        iconSize: 22,
        onToggle: (index) {
          _editPageController.setSound(index ?? 0);
        },
        initialLabelIndex: _editPageController.getSoundValue != 1.0 ? 0 : 1,
        totalSwitches: 2,
      );
    });
  }

  SliderTheme _buildSpeedSlider(BuildContext context) {
    return _getSliderTheme(
      context: context,
      child: Obx(() {
        return Slider(
          value: _editPageController.getSpeedValue,
          max: 7,
          divisions: 7,
          label: _editPageController.getSpeedValueText,
          onChanged: _editPageController.setSpeed,
        );
      }),
    );
  }

  SliderTheme _buildQualitySlider(BuildContext context) {
    return _getSliderTheme(
      context: context,
      child: Obx(() {
        return Slider(
          value: _editPageController.getQualityValue,
          max: 6,
          divisions: 6,
          label: _editPageController.getQualityValueText,
          onChanged: _editPageController.setQuality,
        );
      }),
    );
  }

  SliderTheme _getSliderTheme({
    required BuildContext context,
    required Widget child,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primaryWhiteColor,
        inactiveTrackColor: AppColors.primaryWhiteColor,
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        thumbColor: AppColors.primaryWhiteColor,
        overlayColor: AppColors.primaryWhiteColor.withOpacity(0.3),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: AppColors.primaryWhiteColor,
        inactiveTickMarkColor: AppColors.primaryWhiteColor,
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: AppColors.primaryWhiteColor,
        valueIndicatorTextStyle: AppTextStyles.smallTextStyle
            .copyWith(color: AppColors.primaryColorDark),
      ),
      child: child,
    );
  }
}
