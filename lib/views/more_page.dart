// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vclip/components/vclip_app_bar.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/more_page_controller.dart';
import 'package:vclip/services/abstracts/launcer_service.dart';
import 'package:vclip/services/concretes/launcher_adapter.dart';

class MorePage extends StatelessWidget {
  MorePage({super.key}) {
    _morePageController = Get.find();
    _launcherService = LauncherAdapter();
  }
  late final MorePageController _morePageController;
  late final LauncherService _launcherService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VClipAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 4),
            _buildMorePageWidgets(),
            _buildBBKLogoAndCopyrightWidgets(),
          ],
        ),
      ),
    );
  }

  Expanded _buildMorePageWidgets() {
    return Expanded(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _morePageController.getMoreItemList.length + 1,
        itemBuilder: (context, index) {
          _morePageController.setStaggeredAnimation(index);
          return index == _morePageController.getMoreItemList.length
              ? const SizedBox()
              : AnimatedBuilder(
                  animation: _morePageController.getAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.2, 0),
                        end: const Offset(0, 0),
                      ).animate(
                        CurvedAnimation(
                          parent: _morePageController.getAnimation,
                          curve: Interval(
                            _morePageController.getBeginList[index],
                            _morePageController.getEndList[index],
                            curve: Curves.easeInOutCubic,
                          ),
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: InkWell(
                    onTap: () => _morePageController.onTappedItem(index),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    highlightColor: Colors.transparent,
                    child: ListTile(
                      leading: SvgPicture.asset(
                        _morePageController.getMoreItemList[index].iconPath,
                      ),
                      title: Text(
                        _morePageController.getMoreItemList[index].title,
                        style: AppTextStyles.semiBoldTextStyle,
                      ),
                    ),
                  ),
                );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            color: AppColors.primaryColor,
            thickness: 1,
            height: 4,
          );
        },
      ),
    );
  }

  Column _buildBBKLogoAndCopyrightWidgets() {
    return Column(
      children: [
        InkWell(
          onTap: () async =>
              await _launcherService.launchUrl(AppLinks.bbkDevelopmentOfficial),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          highlightColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _morePageController.getAnimation,
            builder: (BuildContext context, Widget? child) {
              return SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: _morePageController.getAnimation,
                  curve: Interval(
                    _morePageController.getEndList.isEmpty
                        ? 0.0
                        : _morePageController.getEndList.last,
                    1,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: child,
              );
            },
            child: Center(
              child: Image.asset(
                AppAssets.bbkLogoIconPath,
                height: AppSizes.iconSize * 2,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        AnimatedBuilder(
          animation: _morePageController.getAnimation,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: _morePageController.getAnimation,
                curve: Interval(
                  _morePageController.getEndList.isEmpty
                      ? 0.0
                      : _morePageController.getEndList.last,
                  1,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: child,
            );
          },
          child: const Center(
            child: Text(
              AppStrings.copyrightText,
              style: AppTextStyles.smallLightTextStyle,
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
