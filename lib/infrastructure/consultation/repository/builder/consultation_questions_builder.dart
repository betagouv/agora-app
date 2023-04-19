import 'package:agora/domain/consultation/questions/consultation_question.dart';
import 'package:agora/domain/consultation/questions/consultation_question_response_choice.dart';

class ConsultationQuestionsBuilder {
  static List<ConsultationQuestion> buildQuestions({
    required List<dynamic> uniqueChoiceQuestions,
    required List<dynamic> openedQuestions,
    required List<dynamic> multipleChoicesQuestions,
    required List<dynamic> chapters,
  }) {
    return _buildUniqueChoiceQuestions(uniqueChoiceQuestions) +
        _buildOpenedQuestions(openedQuestions) +
        _buildMultipleChoicesQuestions(multipleChoicesQuestions) +
        _buildChapters(chapters);
  }

  static List<ConsultationQuestion> _buildUniqueChoiceQuestions(List<dynamic> questionsUniqueChoice) {
    final List<ConsultationQuestion> questions = [];
    for (final questionUniqueChoice in questionsUniqueChoice) {
      questions.add(
        ConsultationQuestionUnique(
          id: questionUniqueChoice["id"] as String,
          title: questionUniqueChoice["title"] as String,
          order: questionUniqueChoice["order"] as int,
          questionProgress: questionUniqueChoice["questionProgress"] as String,
          responseChoices: (questionUniqueChoice["possibleChoices"] as List)
              .map(
                (responseChoice) => ConsultationQuestionResponseChoice(
                  id: responseChoice["id"] as String,
                  label: responseChoice["label"] as String,
                  order: responseChoice["order"] as int,
                ),
              )
              .toList(),
        ),
      );
    }
    return questions;
  }

  static List<ConsultationQuestion> _buildOpenedQuestions(List<dynamic> questionsOpened) {
    final List<ConsultationQuestion> questions = [];
    for (final questionOpened in questionsOpened) {
      questions.add(
        ConsultationQuestionOpened(
          id: questionOpened["id"] as String,
          title: questionOpened["title"] as String,
          order: questionOpened["order"] as int,
          questionProgress: questionOpened["questionProgress"] as String,
        ),
      );
    }
    return questions;
  }

  static List<ConsultationQuestion> _buildMultipleChoicesQuestions(List<dynamic> questionsMultipleChoices) {
    final List<ConsultationQuestion> questions = [];
    for (final questionMultipleChoices in questionsMultipleChoices) {
      questions.add(
        ConsultationQuestionMultiple(
          id: questionMultipleChoices["id"] as String,
          title: questionMultipleChoices["title"] as String,
          order: questionMultipleChoices["order"] as int,
          questionProgress: questionMultipleChoices["questionProgress"] as String,
          maxChoices: questionMultipleChoices["maxChoices"] as int,
          responseChoices: (questionMultipleChoices["possibleChoices"] as List)
              .map(
                (responseChoice) => ConsultationQuestionResponseChoice(
                  id: responseChoice["id"] as String,
                  label: responseChoice["label"] as String,
                  order: responseChoice["order"] as int,
                ),
              )
              .toList(),
        ),
      );
    }
    return questions;
  }

  static List<ConsultationQuestion> _buildChapters(List<dynamic> chapters) {
    final List<ConsultationQuestion> questions = [];
    for (final chapter in chapters) {
      questions.add(
        ConsultationQuestionChapter(
          id: chapter["id"] as String,
          title: chapter["title"] as String,
          order: chapter["order"] as int,
          description: chapter["description"] as String,
        ),
      );
    }
    return questions;
  }
}
