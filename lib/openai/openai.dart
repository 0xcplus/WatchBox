import 'dart:async';
import 'package:dart_openai/dart_openai.dart';

import 'chatmode.dart';

String rollString = "당신은 용접 결함 탐지 AI 모델, WatchBox입니다. 감지된 결함의 개수, 종류, 신뢰도를 토대로 즉각 조치를 취할 수 있도록 안내하세요. 100자 이내로 간결하고 신속하게, 그러나 공격적이지는 않게 전달하세요.";

//ChatGPT 함수
final requestMessages = [OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(
      rollString,
    ),
  ],
  role: OpenAIChatMessageRole.assistant,
)];

Future<void> fetchStreamedResponse(String inputMessage, String chatModel, StreamController<String> streamController) async {
  final userMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        inputMessage,
      ),
    ],
    role: OpenAIChatMessageRole.user,
  ); requestMessages.add(userMessage);

  String result = '';

  try{
    final chatStream = OpenAI.instance.chat.createStream(
      model: findChatVersion(chatModel),
      messages: requestMessages
    );

    await for (var streamChatCompletion in chatStream) {
      if (streamChatCompletion.choices.isNotEmpty){
        final content = streamChatCompletion.choices.first.delta.content;
        if (content != null && content.isNotEmpty) {
          for (var item in content) {
            if(item != null){
              final text = item.text??'';
              result += text;
              streamController.add(result);
            }
          }
        }
      }
    }
  } catch(e) {
    print('Error fetching streamed response : $e');
    streamController.add('오류 발생 : $e');
  } finally {
    streamController.close();
  }

  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
        result,
      ),
    ],
    role: OpenAIChatMessageRole.assistant,
  ); requestMessages.add(systemMessage);
}