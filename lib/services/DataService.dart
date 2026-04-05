import 'dart:convert';

import 'package:calendar/model/EventVO.dart';
import 'package:calendar/model/QuoteVO.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAssets(String name) async {
  return rootBundle.loadString(name);
}

Future<List<EventVO>> loadEventData() async {
  final jsonString = await loadAssets('assets/events.json');
  final List<dynamic> jsonData = jsonDecode(jsonString) as List<dynamic>;

  return jsonData.map((dynamic element) {
    final map = element as Map<String, dynamic>;
    final dateString = map['date'] as String;
    final name = map['name'] as String;
    final dateArr = dateString.split('/');
    final date = DateTime(1993, int.parse(dateArr[1]), int.parse(dateArr[0]));
    return EventVO(date, name);
  }).toList(growable: false);
}

Future<List<QuoteVO>> loadQuoteData() async {
  final jsonString = await loadAssets('assets/quotes.json');
  final List<dynamic> jsonData = jsonDecode(jsonString) as List<dynamic>;

  return jsonData.map((dynamic element) {
    final map = element as Map<String, dynamic>;
    return QuoteVO(
      map['content'] as String,
      map['author'] as String,
    );
  }).toList(growable: false);
}