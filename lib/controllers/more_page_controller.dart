// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vclip/constants/animation_duration.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/models/more_item.dart';
import 'package:vclip/services/abstracts/launcer_service.dart';
import 'package:vclip/services/concretes/launcher_adapter.dart';

class MorePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final LauncherService _launcherService;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final List<MoreItem> _moreItemList;
  late final List<double> _beginList;
  late final List<double> _endList;

  AnimationController get getAnimationController => _animationController;
  Animation<double> get getAnimation => _animation;
  List<MoreItem> get getMoreItemList => _moreItemList;
  List<double> get getBeginList => _beginList;
  List<double> get getEndList => _endList;

  @override
  void onInit() {
    _launcherService = LauncherAdapter();
    _moreItemList = <MoreItem>[];
    _beginList = <double>[];
    _endList = <double>[];
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationDuration.morePageIn,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _createItemsForMorePage();
    super.onInit();
  }

  @override
  void onClose() {
    _moreItemList.clear();
    _animationController.dispose();
    super.onClose();
  }

  void _createItemsForMorePage() {
    _moreItemList.add(MoreItem(AppAssets.starIconPath, AppStrings.rateText));
    _moreItemList
        .add(MoreItem(AppAssets.mailIconPath, AppStrings.contactsText));
    _moreItemList.add(MoreItem(AppAssets.termsIconPath, AppStrings.termsText));
    _moreItemList
        .add(MoreItem(AppAssets.privacyIconPath, AppStrings.privacyText));
    _moreItemList
        .add(MoreItem(AppAssets.licenseIconPath, AppStrings.licenseText));
  }

  void setStaggeredAnimation(int index) {
    _beginList.add(index / getMoreItemList.length / 2);
    _endList.add((index + 1) / getMoreItemList.length / 2);
  }

  Future<void> onTappedItem(int item) async {
    switch (item) {
      case 0:
        await LaunchReview.launch(androidAppId: AppConfigs.androidAppId);
      case 1:
        await _launcherService.sendMail();
      case 2:
        await _launcherService.launchUrl(AppLinks.termsAndConditions);
      case 3:
        await _launcherService.launchUrl(AppLinks.privacyPolicy);
      case 4:
        final packageInfo = await PackageInfo.fromPlatform();
        showLicensePage(
          context: Get.context!,
          applicationName: AppStrings.appName,
          applicationIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SvgPicture.asset(
              AppAssets.appLogoPath,
              height: AppSizes.iconSize * 4,
            ),
          ),
          applicationVersion: packageInfo.version,
          applicationLegalese: AppStrings.copyrightText,
        );
    }
  }
}
