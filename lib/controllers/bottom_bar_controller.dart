// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomBarController extends GetxController {
  late final RxInt _currentIndex;
  late final PageController _pageController;

  int get getCurrentIndex => _currentIndex.value;
  PageController get getPageController => _pageController;

  @override
  void onInit() {
    _currentIndex = 0.obs;
    _pageController = PageController();
    super.onInit();
  }

  @override
  void onClose() {
    _pageController.dispose();
    super.onClose();
  }

  void updateCurrentIndex(int index) {
    _currentIndex.value = index;
  }
}
