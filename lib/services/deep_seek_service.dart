import 'dart:async';
import 'dart:convert';

import 'package:calendar/model/horoscope_prompt_vo.dart';
import 'package:http/http.dart' as http;

class DeepSeekService {
  DeepSeekService({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiKey = String.fromEnvironment('DEEPSEEK_API_KEY');
  static const String _endpoint = String.fromEnvironment(
    'DEEPSEEK_API_URL',
    defaultValue: 'https://api.deepseek.com/chat/completions',
  );

  final http.Client _client;

  static bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> askHoroscope(HoroscopePromptVO prompt) async {
    final buffer = StringBuffer();
    await for (final chunk in streamHoroscope(prompt)) {
      buffer.write(chunk);
    }

    if (buffer.isEmpty) {
      return _buildPreviewResponse(prompt, error: 'DeepSeek chưa trả về nội dung hợp lệ.');
    }

    return buffer.toString();
  }

  Stream<String> streamHoroscope(HoroscopePromptVO prompt) async* {
    if (!isConfigured) {
      yield _buildPreviewResponse(prompt, includeSetupHint: true);
      return;
    }

    try {
      final request = http.Request('POST', Uri.parse(_endpoint))
        ..headers.addAll(<String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'text/event-stream',
        })
        ..body = jsonEncode(_buildRequestPayload(prompt, stream: true));

      final response = await _client.send(request).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        yield _buildPreviewResponse(prompt, error: 'DeepSeek chưa trả về nội dung hợp lệ.');
        return;
      }

      var yieldedContent = false;
      final rawBuffer = StringBuffer();
      final lineStream = response.stream
          .transform(utf8.decoder)
          .timeout(const Duration(seconds: 45))
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        rawBuffer.writeln(line);
        final trimmed = line.trim();
        if (!trimmed.startsWith('data:')) {
          continue;
        }

        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') {
          break;
        }

        try {
          final payload = jsonDecode(data) as Map<String, dynamic>;
          final choices = payload['choices'] as List<dynamic>? ?? <dynamic>[];
          if (choices.isEmpty) {
            continue;
          }

          final first = choices.first as Map<String, dynamic>;
          final delta = first['delta'] as Map<String, dynamic>?;
          final chunk = (delta?['content'] as String?) ?? '';
          if (chunk.isNotEmpty) {
            yieldedContent = true;
            yield chunk;
          }
        } catch (_) {
          continue;
        }
      }

      if (!yieldedContent) {
        final nonStreamContent = _tryParseNonStreamingContent(rawBuffer.toString());
        if (nonStreamContent != null && nonStreamContent.isNotEmpty) {
          yield nonStreamContent;
        } else {
          yield _buildPreviewResponse(prompt, error: 'DeepSeek chưa trả về nội dung hợp lệ.');
        }
      }
    } on TimeoutException {
      yield _buildPreviewResponse(prompt, error: 'DeepSeek phản hồi quá chậm. Vui lòng thử lại.');
    } catch (_) {
      yield _buildPreviewResponse(prompt, error: 'Không kết nối được tới DeepSeek ngay lúc này.');
    }
  }

  String? _tryParseNonStreamingContent(String raw) {
    try {
      final payload = jsonDecode(raw.trim()) as Map<String, dynamic>;
      final choices = payload['choices'] as List<dynamic>? ?? <dynamic>[];
      if (choices.isEmpty) {
        return null;
      }

      final first = choices.first as Map<String, dynamic>;
      final message = first['message'] as Map<String, dynamic>?;
      return (message?['content'] as String?)?.trim();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildRequestPayload(HoroscopePromptVO prompt, {required bool stream}) {
    return <String, dynamic>{
      'model': 'deepseek-chat',
      'temperature': 0.8,
      'max_tokens': 500,
      'stream': stream,
      'messages': <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'Bạn là thầy tử vi số hiện đại, trả lời bằng tiếng Việt tự nhiên, ấm áp, ngắn gọn nhưng hữu ích. '
              'Không khẳng định chắc chắn tương lai, không đưa lời khuyên y tế/pháp lý/tài chính chuyên môn. '
              'Nếu có ngày sinh thì dùng nó như ngữ cảnh tham khảo để cá nhân hoá câu trả lời một cách nhẹ nhàng. '
              'Hãy trả lời bằng Markdown rõ ràng, ưu tiên các mục `## Tổng quan`, `## Điểm sáng`, `## Lời nhắc hôm nay`, '
              'và nếu phù hợp thì thêm gạch đầu dòng ngắn để người dùng dễ đọc.',
        },
        <String, String>{
          'role': 'user',
          'content': 'Dựa trên bối cảnh sau, hãy luận giải tử vi ngắn gọn và có cấu trúc:\n${prompt.toContextBlock()}',
        },
      ],
    };
  }

  String _buildPreviewResponse(
    HoroscopePromptVO prompt, {
    String? error,
    bool includeSetupHint = false,
  }) {
    final lowerQuestion = prompt.question.toLowerCase();
    String focus;

    if (lowerQuestion.contains('tình') || lowerQuestion.contains('yêu')) {
      focus =
          'Về tình cảm, hôm nay hợp với cách trò chuyện mềm mỏng và chủ động lắng nghe. Nếu đang chờ tín hiệu từ ai đó, đừng vội thúc ép; nhịp chậm sẽ giúp mối quan hệ rõ ràng hơn.';
    } else if (lowerQuestion.contains('công việc') || lowerQuestion.contains('sự nghiệp')) {
      focus =
          'Về công việc, đây là ngày hợp để chốt những việc còn dang dở và ưu tiên sự ổn định. Một bước nhỏ nhưng chắc chắn sẽ hiệu quả hơn việc ôm quá nhiều việc cùng lúc.';
    } else if (lowerQuestion.contains('tài') || lowerQuestion.contains('tiền')) {
      focus =
          'Về tài chính, nên ưu tiên kiểm soát chi tiêu và tránh quyết định cảm tính. Nếu có kế hoạch mua sắm hoặc đầu tư, hãy xem lại mục tiêu dài hạn trước khi chốt.';
    } else {
      focus =
          'Năng lượng hôm nay nghiêng về sự cân bằng và sắp xếp lại ưu tiên. Càng rõ điều mình thật sự muốn, bạn càng dễ gặp cơ hội phù hợp.';
    }

    final setupHint = includeSetupHint
        ? '\n\n> 🔧 Để bật DeepSeek thật, sao chép `.env.example` thành `.env` rồi chạy với `--dart-define-from-file=.env`.'
        : '';
    final prefix = error == null
        ? '## Tổng quan\nĐây là bản xem trước tử vi thông minh dựa trên lịch âm của bạn.'
        : '> $error\n\n## Tổng quan\nTạm thời hiển thị bản xem trước dựa trên lịch âm.';

    final birthLine = prompt.formattedBirthDate == null
        ? '- **Ngày sinh:** chưa chọn'
        : '- **Ngày sinh:** ${prompt.formattedBirthDate}${prompt.birthYearName != null ? ' (${prompt.birthYearName})' : ''}';

    return '$prefix\n\n$focus\n\n## Bối cảnh hôm nay\n- **Dương lịch:** ${prompt.formattedSolarDate}\n- **Âm lịch:** ${prompt.formattedLunarDate}\n- **Can chi ngày:** ${prompt.canChiDay}\n- **Can chi tháng:** ${prompt.canChiMonth}\n$birthLine\n\n## Lời nhắc hôm nay\n- Chọn một ưu tiên quan trọng nhất và giữ nhịp sinh hoạt đều đặn.\n- Đừng quyết định vội khi cảm xúc còn dao động.$setupHint';
  }
}
