import 'package:calendar/model/HoroscopePromptVO.dart';
import 'package:calendar/services/DeepSeekService.dart';
import 'package:calendar/utils/lunar_solar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

enum _ChatRole { assistant, user }

class _ChatMessage {
  const _ChatMessage({
    required this.role,
    required this.content,
    this.isMarkdown = false,
  });

  final _ChatRole role;
  final String content;
  final bool isMarkdown;
}

class HoroscopeContainer extends StatefulWidget {
  const HoroscopeContainer({
    super.key,
    required this.selectedDate,
    required this.useGlassTheme,
  });

  final DateTime selectedDate;
  final bool useGlassTheme;

  @override
  State<HoroscopeContainer> createState() => _HoroscopeContainerState();
}

class _HoroscopeContainerState extends State<HoroscopeContainer> {
  static const List<String> _suggestedQuestions = <String>[
    'Lá số tử vi nói gì về đường tình duyên của tôi?',
    'Công việc hiện tại của tôi có phù hợp hay không?',
    'Tình hình tài chính của tôi trong tương lai như thế nào?',
    'Hôm nay tôi nên ưu tiên điều gì để mọi việc thuận hơn?',
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DeepSeekService _service = DeepSeekService();
  final List<_ChatMessage> _messages = <_ChatMessage>[];

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final initialDate = _birthDate ?? DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _birthDate = picked;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  HoroscopePromptVO _buildPrompt(String question) {
    final lunarDates = convertSolar2Lunar(
      widget.selectedDate.day,
      widget.selectedDate.month,
      widget.selectedDate.year,
      7,
    );
    final lunarDay = lunarDates[0] as int;
    final lunarMonth = lunarDates[1] as int;
    final lunarYear = lunarDates[2] as int;
    final jd = jdn(widget.selectedDate.day, widget.selectedDate.month, widget.selectedDate.year);
    final yearName = '${CAN[(lunarYear + 6) % 10]} ${CHI[(lunarYear + 8) % 12]}';
    final birthYearName = _birthDate == null
        ? null
        : '${CAN[(_birthDate!.year + 6) % 10]} ${CHI[(_birthDate!.year + 8) % 12]}';

    return HoroscopePromptVO(
      solarDate: widget.selectedDate,
      lunarDay: lunarDay,
      lunarMonth: lunarMonth,
      lunarYear: lunarYear,
      canChiDay: getCanDay(jd),
      canChiMonth: getCanChiMonth(lunarMonth, lunarYear),
      beginHour: getBeginHour(jd),
      question: question,
      yearName: yearName,
      birthDate: _birthDate,
      birthYearName: birthYearName,
    );
  }

  Future<void> _sendQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || _isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _messages.add(
        _ChatMessage(
          role: _ChatRole.user,
          content: trimmed,
        ),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    final answer = await _service.askHoroscope(_buildPrompt(trimmed));
    if (!mounted) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          role: _ChatRole.assistant,
          content: answer,
          isMarkdown: true,
        ),
      );
      _isLoading = false;
    });
    _scrollToBottom();
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final markdownStyle = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF2B2B34),
            height: 1.45,
          ),
      strong: const TextStyle(
        color: Color(0xFF1B1B1F),
        fontWeight: FontWeight.w800,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3DAB8)),
      ),
      child: MarkdownBody(
        data:
            '**Mình có thể giúp bạn:**\n'
            '- luận nhanh về **tình cảm**, **công việc**, **tài chính**\n'
            '- tóm tắt theo dạng **Markdown dễ đọc**\n'
            '- dùng thêm **ngày sinh** để cá nhân hoá phần luận giải\n'
            '- đưa ra **lời nhắc nhẹ nhàng** dựa trên lịch âm hôm nay',
        selectable: true,
        styleSheet: markdownStyle,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, _ChatMessage message, int index) {
    final isUser = message.role == _ChatRole.user;
    final labelColor = isUser ? const Color(0xFF3B82F6) : const Color(0xFF8C6A10);
    final markdownStyle = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1B1B1F),
            height: 1.5,
          ),
      strong: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w800,
      ),
      h2: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
      listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1B1B1F),
            height: 1.45,
          ),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('${message.role.name}-$index-${message.content}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        final dx = isUser ? 18 * (1 - value) : -18 * (1 - value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(dx, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    isUser ? 'Bạn' : 'Tử vi AI',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: labelColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFFEAF3FF)
                        : Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 6),
                      bottomRight: Radius.circular(isUser ? 6 : 18),
                    ),
                    border: Border.all(
                      color: isUser ? const Color(0xFFBFDBFE) : const Color(0xFFE3DAB8),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF1E3A8A),
                                height: 1.45,
                              ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: markdownStyle,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3DAB8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Đang luận giải...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6473),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool glass = widget.useGlassTheme;
    final headerColor = const Color(0xFF1B1B1F);
    final subColor = const Color(0xFF6B7280);
    final borderColor = glass ? const Color(0x33FFFFFF) : const Color(0xFFE3DAB8);
    final dateText = _formatDate(widget.selectedDate);
    final birthDateText = _birthDate == null ? 'Ngày sinh' : 'Ngày sinh: ${_formatDate(_birthDate!)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        image: glass
            ? const DecorationImage(
                image: AssetImage('assets/image_blue_blur.jpg'),
                fit: BoxFit.cover,
              )
            : null,
        gradient: glass
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFF8F4E8), Color(0xFFF6F7F2)],
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: glass
                ? <Color>[
                    const Color(0xFFF8F0D8).withValues(alpha: 0.92),
                    const Color(0xFFF5F7F1).withValues(alpha: 0.94),
                  ]
                : <Color>[
                    Colors.white.withValues(alpha: 0.72),
                    const Color(0xFFF8F7F1).withValues(alpha: 0.96),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFFFE7AE),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Thỉnh thầy tử vi',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: headerColor,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Chat tử vi theo kiểu đối thoại, hỗ trợ Markdown dễ đọc.',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: subColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0xFFE3DAB8)),
                                ),
                                child: Text(
                                  'Ngày xem: $dateText',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: const Color(0xFF2B2B34),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              ActionChip(
                                onPressed: _pickBirthDate,
                                backgroundColor: const Color(0xFFFBE7C2),
                                avatar: const Icon(
                                  Icons.cake_rounded,
                                  size: 18,
                                  color: Color(0xFF8C6A10),
                                ),
                                label: Text(
                                  birthDateText,
                                  style: const TextStyle(
                                    color: Color(0xFF6B4B00),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE7AE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  DeepSeekService.isConfigured ? 'DeepSeek online' : 'Preview mode',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6B4B00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _birthDate == null
                                ? 'Chọn ngày sinh để AI luận giải sát hơn theo bối cảnh cá nhân.'
                                : 'Đã thêm ngày sinh để cá nhân hoá phần luận giải tử vi.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: subColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                                children: <Widget>[
                                  if (_messages.isEmpty) ...<Widget>[
                                    _buildWelcomeCard(context),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Câu hỏi gợi ý',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _suggestedQuestions
                                          .map(
                                            (String item) => ActionChip(
                                              onPressed: _isLoading ? null : () => _sendQuestion(item),
                                              backgroundColor: const Color(0xFFFFE39A),
                                              labelStyle: const TextStyle(
                                                color: Color(0xFF2A2A2F),
                                                fontWeight: FontWeight.w700,
                                              ),
                                              avatar: const Icon(
                                                Icons.bolt_rounded,
                                                size: 18,
                                                color: Color(0xFF8C6A10),
                                              ),
                                              label: Text(item),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  ...List<Widget>.generate(
                                    _messages.length,
                                    (int index) => _buildMessageBubble(context, _messages[index], index),
                                  ),
                                  if (_isLoading) _buildTypingBubble(context),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(24),
                                ),
                                border: const Border(
                                  top: BorderSide(color: Color(0xFFE7DFC5)),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Expanded(
                                        child: TextField(
                                          controller: _controller,
                                          minLines: 2,
                                          maxLines: 4,
                                          textInputAction: TextInputAction.send,
                                          onSubmitted: _isLoading
                                              ? null
                                              : (String value) {
                                                  _controller.clear();
                                                  _sendQuestion(value);
                                                },
                                          decoration: InputDecoration(
                                            hintText: 'Nhập câu hỏi tử vi của bạn...',
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE3DAB8),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE3DAB8),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFFFB648),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () {
                                                final text = _controller.text;
                                                _controller.clear();
                                                _sendQuestion(text);
                                              },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFB648),
                                          foregroundColor: const Color(0xFF1B1B1F),
                                          minimumSize: const Size(52, 52),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF1B1B1F),
                                                ),
                                              )
                                            : const Icon(Icons.send_rounded),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      DeepSeekService.isConfigured
                                          ? 'Đang dùng DeepSeek để trả lời tử vi theo thời gian thực.'
                                          : 'Preview mode: thêm `DEEPSEEK_API_KEY` trong `.env` để bật trả lời online.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: subColor,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
