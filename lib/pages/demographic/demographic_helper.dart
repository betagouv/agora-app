import 'package:agora/common/strings/demographic_strings.dart';
import 'package:agora/design/custom_view/button/agora_button.dart';
import 'package:agora/design/style/agora_button_style.dart';
import 'package:agora/design/style/agora_colors.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DemographicHelper {
  static String getQuestionTitle(int step) {
    switch (step) {
      case 1:
        return DemographicStrings.question1;
      case 2:
        return DemographicStrings.question2;
      case 3:
        return DemographicStrings.question3;
      case 4:
        return DemographicStrings.question4;
      case 5:
        return DemographicStrings.question5;
      case 6:
        return DemographicStrings.question6;
      default:
        throw Exception("Demographic question title step not exists error");
    }
  }

  static Widget buildIgnoreButton({required VoidCallback onPressed}) {
    return AgoraButton(
      label: DemographicStrings.ignoreQuestion,
      style: AgoraButtonStyle.blueBorderButtonStyle,
      onPressed: onPressed,
    );
  }

  static List<Widget> buildBackButton({required int step, required VoidCallback onBackTap}) {
    if (step != 1) {
      return [
        SizedBox(height: AgoraSpacings.x1_5),
        InkWell(
          onTap: () => onBackTap(),
          child: Container(
            padding: EdgeInsets.only(bottom: AgoraSpacings.x0_25),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AgoraColors.primaryBlue, width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/ic_backward.svg"),
                SizedBox(width: AgoraSpacings.base),
                Flexible(
                  child: Text(
                    DemographicStrings.previousQuestion,
                    style: AgoraTextStyles.light16.copyWith(color: AgoraColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else {
      return [];
    }
  }
}
