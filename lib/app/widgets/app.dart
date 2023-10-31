// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vclip/constants/animation_duration.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/bottom_bar_controller.dart';
import 'package:vclip/controllers/edit_page_controller.dart';
import 'package:vclip/controllers/home_page_controller.dart';
import 'package:vclip/controllers/more_page_controller.dart';
import 'package:vclip/utilities/app_themes.dart';
import 'package:vclip/views/edit_page.dart';
import 'package:vclip/views/home_page.dart';
import 'package:vclip/views/more_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppThemes.mainTheme,
      home: VClipPageView(),
    );
  }
}

class VClipPageView extends StatelessWidget {
  VClipPageView({super.key}) {
    _bottomBarController = Get.put(BottomBarController());
    _homePageController = Get.put(HomePageController());
    _editPageController = Get.put(EditPageController());
    _morePageController = Get.put(MorePageController());
  }
  late final BottomBarController _bottomBarController;
  late final HomePageController _homePageController;
  late final EditPageController _editPageController;
  late final MorePageController _morePageController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _bottomBarController.getPageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) async {
            _bottomBarController.updateCurrentIndex(index);
            if (_editPageController.getNeedRefresh) {
              _editPageController.setRefresh(false);
              await _homePageController.fetchData();
            }
            if (index == 0) {
              _homePageController.getAnimationController.duration =
                  AnimationDuration.homePageIn;
              await _homePageController.getAnimationController.forward();
            }
            if (index == 1) {
              _editPageController.getStaggeredAnimationController.duration =
                  AnimationDuration.editPageIn;
              await _editPageController.getStaggeredAnimationController
                  .forward();
            }
            if (index == 2) {
              _morePageController.getBeginList.clear();
              _morePageController.getEndList.clear();
              _morePageController.getAnimationController.duration =
                  AnimationDuration.morePageIn;
              await _morePageController.getAnimationController.forward();
            }
          },
          children: <Widget>[
            HomePage(),
            const EditPage(),
            MorePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        color: AppColors.primaryColor,
        child: Obx(() {
          return BottomNavyBar(
            selectedIndex: _bottomBarController.getCurrentIndex,
            onItemSelected: (index) async {
              if (_bottomBarController.getCurrentIndex == 0 && index != 0) {
                _homePageController.getAnimationController.duration =
                    AnimationDuration.homePageOut;
                await _homePageController.getAnimationController.reverse();
              }
              if (_bottomBarController.getCurrentIndex == 1 && index != 1) {
                _editPageController.getStaggeredAnimationController.duration =
                    AnimationDuration.editPageOut;
                await _editPageController.getStaggeredAnimationController
                    .reverse();
              }
              if (_bottomBarController.getCurrentIndex == 2 && index != 2) {
                _morePageController.getAnimationController.duration =
                    AnimationDuration.morePageOut;
                await _morePageController.getAnimationController.reverse();
              }

              _bottomBarController.updateCurrentIndex(index);
              _bottomBarController.getPageController.jumpToPage(index);
            },
            backgroundColor: AppColors.primaryColor,
            items: <BottomNavyBarItem>[
              BottomNavyBarItem(
                activeColor: AppColors.primaryWhiteColor,
                inactiveColor: AppColors.primaryWhiteColor,
                title:
                    const Text('Home', style: AppTextStyles.semiBoldTextStyle),
                textAlign: TextAlign.center,
                icon: SvgPicture.asset(AppAssets.homeIconPath),
              ),
              BottomNavyBarItem(
                activeColor: AppColors.primaryWhiteColor,
                inactiveColor: AppColors.primaryWhiteColor,
                title:
                    const Text('Edit', style: AppTextStyles.semiBoldTextStyle),
                textAlign: TextAlign.center,
                icon: SvgPicture.asset(AppAssets.cutIconPath),
              ),
              BottomNavyBarItem(
                activeColor: AppColors.primaryWhiteColor,
                inactiveColor: AppColors.primaryWhiteColor,
                title:
                    const Text('More', style: AppTextStyles.semiBoldTextStyle),
                textAlign: TextAlign.center,
                icon: SvgPicture.asset(AppAssets.moreIconPath),
              ),
            ],
          );
        }),
      ),
    );
  }
}
