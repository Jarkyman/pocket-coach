import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/analytics_service.dart';
import '../../../shared/services/connectivity_service.dart';

class AiException implements Exception {
  final String message;
  final String? type;
  AiException(this.message, {this.type});
}

class AiService {
  final ConnectivityService _connectivity;

  AiService(this._connectivity) {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      OpenAI.apiKey = apiKey;
    }
  }

  Future<String> getResponse({
    required String systemPrompt,
    required List<OpenAIChatCompletionChoiceMessageModel> messages,
  }) async {
    // Check connectivity first
    if (!await _connectivity.isConnected()) {
      throw AiException(
        "No internet connection. Please check your data or Wi-Fi.",
        type: 'connectivity',
      );
    }

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                systemPrompt,
              ),
            ],
          ),
          ...messages,
        ],
        // temperature: 0.7, // Only default (1.0) supported for this model
      );

      // Log token usage
      final usage = chatCompletion.usage;
      AnalyticsService.logTokensUsed(usage.totalTokens, "gpt-4o-mini");

      final content = chatCompletion.choices.first.message.content;
      if (content == null || content.isEmpty) {
        throw AiException("Empty response from AI", type: 'empty_response');
      }

      return content.first.text ?? "";
    } catch (e, stack) {
      // Log technical error details to analytics
      AnalyticsService.logError(
        e.toString(),
        type: 'ai_service_failure',
        stackTrace: stack.toString(),
      );

      if (e is AiException) rethrow;

      // Wrap other errors in a user-friendly exception
      throw AiException(
        "I'm having trouble thinking right now. Please try again in a moment.",
        type: 'technical_failure',
      );
    }
  }
}

final aiServiceProvider = Provider((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return AiService(connectivity);
});
