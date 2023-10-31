// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:vclip/constants/constants.dart';
import 'package:vclip/controllers/bottom_bar_controller.dart';
import 'package:vclip/controllers/edit_page_controller.dart';
import 'package:vclip/utilities/time_formatter.dart';

class VideoThumbnail extends StatelessWidget {
  VideoThumbnail(this.assetEntity, {super.key});

  final AssetEntity assetEntity;
  final EditPageController _editPageController = Get.find();
  final BottomBarController _bottomBarController = Get.find();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future:
          assetEntity.thumbnailDataWithSize(const ThumbnailSize.square(256)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return _loadingGridViewItem();
        return InkWell(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          highlightColor: Colors.transparent,
          onTap: () async {
            await _editPageController.setFile(assetEntity.loadFile());
            _bottomBarController.getPageController.jumpToPage(1);
            /*Navigator.pushNamed(context, PreviewScreen.PATH,
                    arguments: {'file': assetEntity.loadFile()})
                .then((value) => videoProvider.fetchAssets());*/
          },
          child: _gridViewItem(bytes),
        );
      },
    );
  }

  Container _loadingGridViewItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.gridViewItemsBorderRadius),
        border: Border.all(
          color: AppColors.primaryColor,
        ),
      ),
      child: const Center(
        child: SizedBox(
          height: AppSizes.iconSize,
          width: AppSizes.iconSize,
          child: CircularProgressIndicator(color: AppColors.primaryWhiteColor),
        ),
      ),
    );
  }

  ClipRRect _gridViewItem(Uint8List bytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.gridViewItemsBorderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
          Container(
            height: 14,
            color: AppColors.primaryColor,
            alignment: Alignment.center,
            child: Text(
              TimeFormatter.format(
                duration: Duration(seconds: assetEntity.duration),
              ),
              style: AppTextStyles.smallTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
