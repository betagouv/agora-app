import 'package:agora/common/strings/demographic_strings.dart';
import 'package:agora/common/strings/generic_strings.dart';
import 'package:agora/design/custom_view/agora_alert_dialog.dart';
import 'package:agora/design/custom_view/agora_demographic_simple_view.dart';
import 'package:agora/design/custom_view/button/agora_button.dart';
import 'package:agora/design/style/agora_button_style.dart';
import 'package:agora/design/style/agora_colors.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:agora/domain/demographic/demographic_response.dart';
import 'package:agora/pages/demographic/demographic_helper.dart';
import 'package:agora/pages/demographic/demographic_response_helper.dart';
import 'package:flutter/material.dart';

class DemographicCommonView extends StatelessWidget {
  final List<DemographicResponseChoice> responseChoices;
  final Function(String responseCode) onContinuePressed;
  final VoidCallback onIgnorePressed;
  final DemographicResponse? oldResponse;
  final bool showWhatAbout;
  final String? whatAboutText;

  const DemographicCommonView({
    super.key,
    required this.responseChoices,
    required this.onContinuePressed,
    required this.onIgnorePressed,
    required this.oldResponse,
    this.showWhatAbout = false,
    this.whatAboutText,
  }) : assert(showWhatAbout == false || (showWhatAbout == true && whatAboutText != null));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _handleResponse(context),
    );
  }

  List<Widget> _handleResponse(BuildContext context) {
    final List<Widget> widgets = [];
    if (showWhatAbout) {
      widgets.add(
        InkWell(
          onTap: () {
            showAgoraDialog(
              context: context,
              columnChildren: [
                Text(whatAboutText!, style: AgoraTextStyles.light16),
                SizedBox(height: AgoraSpacings.x0_75),
                AgoraButton(
                  label: GenericStrings.close,
                  style: AgoraButtonStyle.primaryButtonStyle,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
          child: Text(
            DemographicStrings.whatAbout,
            style: AgoraTextStyles.regular14Underline.copyWith(color: AgoraColors.primaryBlue),
          ),
        ),
      );
      widgets.add(SizedBox(height: AgoraSpacings.base));
    }
    for (final responseChoice in responseChoices) {
      widgets.add(
        AgoraDemographicResponseCard(
          responseLabel: responseChoice.responseLabel,
          isSelected: oldResponse != null && responseChoice.responseCode == oldResponse!.response,
          onTap: () => onContinuePressed(responseChoice.responseCode),
        ),
      );
      widgets.add(SizedBox(height: AgoraSpacings.x0_25));
    }
    widgets.add(SizedBox(height: AgoraSpacings.x1_25));
    widgets.add(DemographicHelper.buildIgnoreButton(onPressed: onIgnorePressed));
    return widgets;
  }
}
