// Copyright 2021 BBK Development. All rights reserved.
// Use of this source code is governed by a GPL-style license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:vclip/constants/app_colors.dart';

class AppThemes {
  //themes
  static ThemeData mainTheme = ThemeData(
    fontFamily: 'RobotoMono',
    primaryColor: AppColors.primaryColor,
    primaryColorDark: AppColors.primaryColorDark,
    primaryColorLight: AppColors.primaryWhiteColor,
    scaffoldBackgroundColor: AppColors.primaryColorDark,
    cardColor: AppColors.primaryColorDark,
    shadowColor: Colors.transparent,
    iconTheme: const IconThemeData(color: AppColors.primaryWhiteColor),
    appBarTheme: const AppBarTheme(color: AppColors.primaryColor),
    textTheme: const TextTheme(
      displayLarge: TextStyle(),
      displayMedium: TextStyle(),
      displaySmall: TextStyle(),
      headlineMedium: TextStyle(),
      headlineSmall: TextStyle(),
      titleLarge: TextStyle(),
      titleMedium: TextStyle(),
      titleSmall: TextStyle(),
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
      bodySmall: TextStyle(),
      labelLarge: TextStyle(),
      labelSmall: TextStyle(),
    ).apply(
      bodyColor: AppColors.primaryWhiteColor,
      displayColor: AppColors.primaryWhiteColor,
    ),
    colorScheme: const ColorScheme.dark()
        .copyWith(
          primary: AppColors.primaryWhiteColor,
          secondary: AppColors.timelineControllerColor,
        )
        .copyWith(background: AppColors.primaryColor),
  );
}
