import 'package:agora/bloc/consultation/details/consultation_details_bloc.dart';
import 'package:agora/bloc/consultation/details/consultation_details_event.dart';
import 'package:agora/bloc/consultation/details/consultation_details_state.dart';
import 'package:agora/bloc/consultation/details/consultation_details_view_model.dart';
import 'package:agora/common/analytics/analytics_event_names.dart';
import 'package:agora/common/analytics/analytics_screen_names.dart';
import 'package:agora/common/helper/notification_helper.dart';
import 'package:agora/common/helper/platform_helper.dart';
import 'package:agora/common/helper/thematique_helper.dart';
import 'package:agora/common/helper/tracker_helper.dart';
import 'package:agora/common/manager/repository_manager.dart';
import 'package:agora/common/strings/consultation_strings.dart';
import 'package:agora/design/custom_view/agora_error_view.dart';
import 'package:agora/design/custom_view/agora_html.dart';
import 'package:agora/design/custom_view/agora_participants_progress_bar.dart';
import 'package:agora/design/custom_view/agora_rounded_card.dart';
import 'package:agora/design/custom_view/agora_scaffold.dart';
import 'package:agora/design/custom_view/agora_toolbar.dart';
import 'package:agora/design/style/agora_colors.dart';
import 'package:agora/design/style/agora_corners.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:agora/pages/consultation/question/consultation_question_page.dart';
import 'package:agora/pages/consultation/summary/consultation_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConsultationDetailsArguments {
  final String consultationId;
  final String? notificationTitle;
  final String? notificationDescription;

  ConsultationDetailsArguments({
    required this.consultationId,
    this.notificationTitle,
    this.notificationDescription,
  });
}

class ConsultationDetailsPage extends StatefulWidget {
  static const routeName = "/consultationDetailsPage";

  final String consultationId;
  final String? notificationTitle;
  final String? notificationDescription;

  const ConsultationDetailsPage({
    super.key,
    required this.consultationId,
    this.notificationTitle,
    this.notificationDescription,
  });

  @override
  State<ConsultationDetailsPage> createState() => _ConsultationDetailsPageState();
}

class _ConsultationDetailsPageState extends State<ConsultationDetailsPage> {
  @override
  void initState() {
    super.initState();
    NotificationHelper.displayNotificationWithDialog(
      context: context,
      notificationTitle: widget.notificationTitle,
      notificationDescription: widget.notificationDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ConsultationDetailsBloc(
        consultationRepository: RepositoryManager.getConsultationRepository(),
      )..add(FetchConsultationDetailsEvent(consultationId: widget.consultationId)),
      child: BlocConsumer<ConsultationDetailsBloc, ConsultationDetailsState>(
        listener: (previousState, currentState) {
          if (currentState is ConsultationDetailsFetchedState && currentState.viewModel.hasAnswered) {
            Navigator.pushNamed(
              context,
              ConsultationSummaryPage.routeName,
              arguments: ConsultationSummaryArguments(
                consultationId: widget.consultationId,
                shouldReloadConsultationsWhenPop: false,
              ),
            ).then((value) => Navigator.pop(context));
          }
        },
        builder: (context, state) {
          if (state is ConsultationDetailsFetchedState) {
            return _handleFetchState(context, state);
          } else if (state is ConsultationDetailsInitialLoadingState) {
            return _buildCommonContent(context, CircularProgressIndicator());
          } else {
            return _buildCommonContent(context, AgoraErrorView());
          }
        },
      ),
    );
  }

  Widget _handleFetchState(BuildContext context, ConsultationDetailsFetchedState state) {
    return AgoraScaffold(
      floatingActionButton: Theme(
        data: Theme.of(context).copyWith(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(AgoraCorners.rounded)),
            extendedSizeConstraints: BoxConstraints.tightFor(height: 38),
            extendedPadding: EdgeInsets.symmetric(horizontal: AgoraSpacings.x0_75),
            extendedTextStyle: AgoraTextStyles.primaryButton,
          ),
        ),
        child: FloatingActionButton.extended(
          backgroundColor: AgoraColors.primaryBlue,
          label: Text(ConsultationStrings.beginButton),
          onPressed: () {
            TrackerHelper.trackClick(
              clickName: "${AnalyticsEventNames.startConsultation} ${widget.consultationId}",
              widgetName: AnalyticsScreenNames.consultationDetailsPage,
            );
            Navigator.pushNamed(
              context,
              ConsultationQuestionPage.routeName,
              arguments: state.viewModel.id,
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      child: Column(
        children: [
          AgoraToolbar(),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSuccessContent(context, state.viewModel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonContent(BuildContext context, Widget widget) {
    return AgoraScaffold(
      child: Column(
        children: [
          AgoraToolbar(),
          SizedBox(height: MediaQuery.of(context).size.height / 10 * 4),
          Center(child: widget),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, ConsultationDetailsViewModel viewModel) {
    const columnPadding = AgoraSpacings.horizontalPadding;
    const spacing = AgoraSpacings.x0_5;
    const icPersonIconSize = 21;
    return Column(
      children: [
        Image.network(viewModel.coverUrl),
        Padding(
          padding: const EdgeInsets.all(columnPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThematiqueHelper.buildCard(context, viewModel.thematique),
              SizedBox(height: AgoraSpacings.x0_5),
              Text(viewModel.title, style: AgoraTextStyles.medium19),
              SizedBox(height: AgoraSpacings.x1_5),
              _buildInformationItem(
                image: "ic_calendar.svg",
                text: viewModel.endDate,
                textStyle: AgoraTextStyles.regularItalic14,
              ),
              SizedBox(height: AgoraSpacings.x1_5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: _buildInformationItem(image: "ic_timer.svg", text: viewModel.estimatedTime)),
                  SizedBox(width: AgoraSpacings.x0_75),
                  Flexible(child: _buildInformationItem(image: "ic_query.svg", text: viewModel.questionCount)),
                ],
              ),
              SizedBox(height: AgoraSpacings.x1_5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset("assets/ic_person.svg"),
                  SizedBox(width: spacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.participantCountText,
                        style: AgoraTextStyles.light14,
                      ),
                      SizedBox(height: AgoraSpacings.x0_5),
                      AgoraParticipantsProgressBar(
                        currentNbParticipants: viewModel.participantCount,
                        objectiveNbParticipants: viewModel.participantCountGoal,
                        minusPadding: columnPadding * 2 + spacing + icPersonIconSize,
                      ),
                      SizedBox(height: AgoraSpacings.x0_5),
                      Text(
                        viewModel.participantCountGoalText,
                        style: AgoraTextStyles.light14,
                      ),
                      SizedBox(height: AgoraSpacings.x0_5),
                    ],
                  ),
                ],
              ),
              Divider(height: AgoraSpacings.x1_5, color: AgoraColors.divider, thickness: 1),
              AgoraHtml(data: viewModel.description),
              SizedBox(height: AgoraSpacings.base),
              AgoraRoundedCard(
                cardColor: AgoraColors.cascadingWhite,
                padding: const EdgeInsets.all(AgoraSpacings.base),
                child: AgoraHtml(data: viewModel.tipsDescription),
              ),
              if (PlatformStaticHelper.isAndroid())
                SizedBox(height: AgoraSpacings.x3_25)
              else
                SizedBox(height: AgoraSpacings.x5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationItem({
    required String image,
    required String text,
    TextStyle textStyle = AgoraTextStyles.light14,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset("assets/$image"),
        SizedBox(width: AgoraSpacings.x0_5),
        Expanded(child: Text(text, style: textStyle)),
      ],
    );
  }
}
