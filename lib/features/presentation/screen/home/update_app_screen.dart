import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hesham/core/extension/extension.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/resources/app_constant.dart';
import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/font_manager.dart';
import '../../../../core/resources/strings_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../business_logic/cubit/langauge/localization/app_localizations.dart';

class UpdateAppScreen extends StatelessWidget {
  const UpdateAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        body: SizedBox(height: context.height,width: context.width,child:
        Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(JsonAssetManager.maintain),
            const SizedBox(height: AppSize.appSize20,),
            Padding(
              padding: const EdgeInsets.all(AppPadding.appPadding16),
              child: Text(AppLocalizationsImpl.of(context)!.translate(AppStrings.updateAppMessage),textAlign: TextAlign.center,style: Theme.of(context).textTheme.displaySmall!.copyWith(color: ColorManager.secondColor,fontSize: FontSize.fontSize16,),),
            )
           ,const _UpdateButton()
          ],
        ),),

      ),
    );
  }
}
class _UpdateButton extends StatelessWidget {
  const _UpdateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width * AppSize.appSize0_80,
      height: AppSize.appSize40,
      child: ElevatedButton(
        onPressed: () {
          launchUrl(
            Uri.parse(
            Platform.isIOS?
          AppConstants.iosAppUrlLauncher:
          AppConstants.androidAppUrlLauncher
          ),mode: LaunchMode.externalApplication);
        },
        child: Text(
            AppLocalizationsImpl.of(context)!.translate(AppStrings.updateApp)),
      ),
    );
  }
}
