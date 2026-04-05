class HoroscopePromptVO {
  const HoroscopePromptVO({
    required this.solarDate,
    required this.lunarDay,
    required this.lunarMonth,
    required this.lunarYear,
    required this.canChiDay,
    required this.canChiMonth,
    required this.beginHour,
    required this.question,
    required this.yearName,
    this.birthDate,
    this.birthYearName,
  });

  final DateTime solarDate;
  final int lunarDay;
  final int lunarMonth;
  final int lunarYear;
  final String canChiDay;
  final String canChiMonth;
  final String beginHour;
  final String question;
  final String yearName;
  final DateTime? birthDate;
  final String? birthYearName;

  String get formattedSolarDate {
    final day = solarDate.day.toString().padLeft(2, '0');
    final month = solarDate.month.toString().padLeft(2, '0');
    return '$day/$month/${solarDate.year}';
  }

  String get formattedLunarDate => '$lunarDay/$lunarMonth/$lunarYear';

  String? get formattedBirthDate {
    if (birthDate == null) {
      return null;
    }

    final day = birthDate!.day.toString().padLeft(2, '0');
    final month = birthDate!.month.toString().padLeft(2, '0');
    return '$day/$month/${birthDate!.year}';
  }

  String toContextBlock() {
    final birthContext = formattedBirthDate == null
        ? '- Ngày sinh: chưa cung cấp'
        : '- Ngày sinh: $formattedBirthDate${birthYearName != null ? ' ($birthYearName)' : ''}';

    return '''
- Dương lịch: $formattedSolarDate
- Âm lịch: $formattedLunarDate
- Năm âm lịch: $yearName
- Can chi ngày: $canChiDay
- Can chi tháng: $canChiMonth
- Giờ mở đầu: $beginHour
$birthContext
- Câu hỏi người dùng: $question
''';
  }
}
