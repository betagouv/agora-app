import 'package:agora/bloc/consultation/question/consultation_questions_view_model.dart';
import 'package:agora/common/strings/consultation_strings.dart';
import 'package:agora/design/agora_button_style.dart';
import 'package:agora/design/agora_colors.dart';
import 'package:agora/design/agora_spacings.dart';
import 'package:agora/design/agora_text_styles.dart';
import 'package:agora/design/custom_view/button/agora_button.dart';
import 'package:agora/domain/consultation/questions/responses/consultation_question_response.dart';
import 'package:agora/pages/consultation/question/consultation_question_helper.dart';
import 'package:agora/pages/consultation/question/question_type_view/consultation_question_view.dart';
import 'package:flutter/material.dart';

class ConsultationQuestionOpenedView extends StatefulWidget {
  final ConsultationQuestionOpenedViewModel openedQuestion;
  final ConsultationQuestionResponses? previousResponses;
  final int totalQuestions;
  final Function(String, String) onOpenedResponseInput;
  final VoidCallback onBackTap;

  ConsultationQuestionOpenedView({
    Key? key,
    required this.openedQuestion,
    required this.previousResponses,
    required this.totalQuestions,
    required this.onOpenedResponseInput,
    required this.onBackTap,
  }) : super(key: key);

  @override
  State<ConsultationQuestionOpenedView> createState() => _ConsultationQuestionOpenedViewState();
}

class _ConsultationQuestionOpenedViewState extends State<ConsultationQuestionOpenedView> {
  String openedResponse = "";
  bool shouldResetPreviousResponses = true;
  late ConsultationQuestionOpenedViewModel openedQuestion;

  @override
  Widget build(BuildContext context) {
    openedQuestion = widget.openedQuestion;
    _resetPreviousResponses();
    return ConsultationQuestionView(
      order: openedQuestion.order,
      totalQuestions: widget.totalQuestions,
      questionProgress: openedQuestion.questionProgress,
      title: openedQuestion.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildOpenedChoiceResponse() +
            ConsultationQuestionHelper.buildBackButton(
              order: openedQuestion.order,
              onBackTap: widget.onBackTap,
            ),
      ),
    );
  }

  void _resetPreviousResponses() {
    if (shouldResetPreviousResponses) {
      openedResponse = "";
      final previousSelectedResponses = widget.previousResponses;
      if (previousSelectedResponses != null) {
        openedResponse = previousSelectedResponses.responseText;
      }
      shouldResetPreviousResponses = false;
    }
  }

  List<Widget> _buildOpenedChoiceResponse() {
    return [
      Text(ConsultationStrings.openedQuestionNotice, style: AgoraTextStyles.medium14),
      SizedBox(height: AgoraSpacings.base),
      SizedBox(
        width: double.infinity,
        height: 200,
        child: TextField(
          minLines: 1,
          maxLines: 20,
          scrollPadding: const EdgeInsets.only(bottom: AgoraSpacings.x3),
          maxLength: 400,
          keyboardType: TextInputType.multiline,
          style: AgoraTextStyles.light14,
          controller: TextEditingController(text: openedResponse),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(AgoraSpacings.base),
            filled: true,
            fillColor: AgoraColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 1, color: AgoraColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: AgoraColors.primaryGreen),
            ),
            hintText: ConsultationStrings.hintText,
            hintStyle: AgoraTextStyles.light14.copyWith(color: AgoraColors.orochimaru),
          ),
          onChanged: (openedResponseInput) {
            openedResponse = openedResponseInput;
          },
        ),
      ),
      SizedBox(height: AgoraSpacings.base),
      AgoraButton(
        label: ConsultationQuestionHelper.buildNextButtonLabel(
          order: openedQuestion.order,
          totalQuestions: widget.totalQuestions,
        ),
        style: AgoraButtonStyle.primaryButtonStyle,
        onPressed: () {
          widget.onOpenedResponseInput(openedQuestion.id, openedResponse);
          shouldResetPreviousResponses = true;
        },
      ),
    ];
  }
}
