import 'package:agora/bloc/qag/details/qag_details_view_model.dart';
import 'package:agora/bloc/qag/support/qag_support_bloc.dart';
import 'package:agora/bloc/qag/support/qag_support_event.dart';
import 'package:agora/bloc/qag/support/qag_support_state.dart';
import 'package:agora/common/strings/qag_strings.dart';
import 'package:agora/design/custom_view/agora_error_view.dart';
import 'package:agora/design/custom_view/button/agora_rounded_button.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QagDetailsSupportView extends StatelessWidget {
  final String qagId;
  final QagDetailsSupportViewModel support;
  final Function(int supportCount, bool? isSupported) onSupportChange;

  const QagDetailsSupportView({
    super.key,
    required this.qagId,
    required this.support,
    required this.onSupportChange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QagSupportBloc, QagSupportState>(
      builder: (context, supportState) {
        final isSupported = support.isSupported;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Row(
                  children: [
                    AgoraRoundedButton(
                      icon: _buildButtonIcon(isSupported, supportState),
                      label: _buildButtonLabel(isSupported, supportState),
                      style: _buildButtonStyle(isSupported, supportState),
                      isLoading: supportState is QagSupportLoadingState || supportState is QagDeleteSupportLoadingState,
                      contentAlignment: _buildButtonAlignment(isSupported, supportState),
                      onPressed: () {
                        _buildOnPressed(context, qagId, isSupported, supportState);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SvgPicture.asset("assets/${_buildIcon(isSupported, supportState)}"),
                    SizedBox(width: AgoraSpacings.x0_25),
                    Text(
                      _buildCount(support, supportState),
                      style: AgoraTextStyles.medium14,
                    ),
                    SizedBox(width: AgoraSpacings.x0_5),
                  ],
                ),
              ],
            ),
            if (supportState is QagSupportErrorState || supportState is QagDeleteSupportErrorState) ...[
              SizedBox(height: AgoraSpacings.base),
              AgoraErrorView(),
            ]
          ],
        );
      },
    );
  }

  String _buildCount(QagDetailsSupportViewModel serverSupportViewModel, QagSupportState supportState) {
    final isSupported = serverSupportViewModel.isSupported;
    final supportCount = serverSupportViewModel.count;
    if (!isSupported && supportState is QagSupportSuccessState) {
      final newSupportCount = supportCount + 1;
      onSupportChange(newSupportCount, true);
      return (newSupportCount).toString();
    } else if (isSupported && supportState is QagDeleteSupportSuccessState) {
      final newSupportCount = supportCount - 1;
      onSupportChange(newSupportCount, false);
      return (newSupportCount).toString();
    }
    onSupportChange(supportCount, null);
    return supportCount.toString();
  }

  String _buildButtonIcon(bool isSupported, QagSupportState supportState) {
    if (supportState is QagSupportInitialState) {
      if (isSupported) {
        return "ic_confirmation_green.svg";
      } else {
        return "ic_heart_white.svg";
      }
    } else {
      if (supportState is QagSupportSuccessState || supportState is QagDeleteSupportErrorState) {
        return "ic_confirmation_green.svg";
      } else if (supportState is QagSupportErrorState || supportState is QagDeleteSupportSuccessState) {
        return "ic_heart_white.svg";
      }
    }
    return ""; // value not important
  }

  CrossAxisAlignment _buildButtonAlignment(bool isSupported, QagSupportState supportState) {
    if (supportState is QagSupportInitialState) {
      if (isSupported) {
        return CrossAxisAlignment.center;
      } else {
        return CrossAxisAlignment.end;
      }
    } else {
      if (supportState is QagSupportSuccessState || supportState is QagDeleteSupportErrorState) {
        return CrossAxisAlignment.center;
      } else if (supportState is QagSupportErrorState || supportState is QagDeleteSupportSuccessState) {
        return CrossAxisAlignment.end;
      }
    }
    return CrossAxisAlignment.center; // value not important
  }

  String _buildIcon(bool isSupported, QagSupportState supportState) {
    if (supportState is QagSupportInitialState || supportState is QagSupportLoadingState) {
      if (isSupported) {
        return "ic_heart_full.svg";
      } else {
        return "ic_heart.svg";
      }
    } else {
      if (supportState is QagSupportSuccessState || supportState is QagDeleteSupportErrorState) {
        return "ic_heart_full.svg";
      } else if (supportState is QagSupportErrorState || supportState is QagDeleteSupportSuccessState) {
        return "ic_heart.svg";
      }
    }
    return ""; // value not important
  }

  String _buildButtonLabel(bool isSupported, QagSupportState supportState) {
    if (supportState is QagSupportInitialState) {
      if (isSupported) {
        return QagStrings.questionSupported;
      } else {
        return QagStrings.supportQuestion;
      }
    } else {
      if (supportState is QagSupportSuccessState || supportState is QagDeleteSupportErrorState) {
        return QagStrings.questionSupported;
      } else if (supportState is QagSupportErrorState || supportState is QagDeleteSupportSuccessState) {
        return QagStrings.supportQuestion;
      }
    }
    return ""; // value not important
  }

  AgoraRoundedButtonStyle _buildButtonStyle(bool isSupported, QagSupportState supportState) {
    if (supportState is QagSupportInitialState) {
      if (isSupported) {
        return AgoraRoundedButtonStyle.secondaryButton;
      } else {
        return AgoraRoundedButtonStyle.primaryButton;
      }
    } else {
      if (supportState is QagSupportSuccessState || supportState is QagDeleteSupportErrorState) {
        return AgoraRoundedButtonStyle.secondaryButton;
      } else if (supportState is QagSupportErrorState || supportState is QagDeleteSupportSuccessState) {
        return AgoraRoundedButtonStyle.primaryButton;
      }
    }
    return AgoraRoundedButtonStyle.secondaryButton; // value not important
  }

  void _buildOnPressed(BuildContext context, String qagId, bool isSupported, QagSupportState supportState) {
    final qagSupportBloc = context.read<QagSupportBloc>();
    if (supportState is QagSupportInitialState) {
      if (isSupported) {
        qagSupportBloc.add(DeleteSupportQagEvent(qagId: qagId));
      } else {
        qagSupportBloc.add(SupportQagEvent(qagId: qagId));
      }
    } else {
      if (supportState is QagSupportSuccessState || supportState is QagDeleteSupportErrorState) {
        qagSupportBloc.add(DeleteSupportQagEvent(qagId: qagId));
      } else if (supportState is QagSupportErrorState || supportState is QagDeleteSupportSuccessState) {
        qagSupportBloc.add(SupportQagEvent(qagId: qagId));
      }
    }
  }
}
