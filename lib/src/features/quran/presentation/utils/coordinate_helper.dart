import 'dart:convert';
import 'package:flutter/services.dart';

class PageCoordinates {
  final List<AyahCoordinates> ayahs;

  PageCoordinates({required this.ayahs});

  factory PageCoordinates.fromJson(List<dynamic> json) {
    return PageCoordinates(
      ayahs: json.map((e) => AyahCoordinates.fromJson(e)).toList(),
    );
  }
}

class AyahCoordinates {
  final int suraId;
  final int ayaId;
  final List<Segment> segments;

  AyahCoordinates({
    required this.suraId,
    required this.ayaId,
    required this.segments,
  });

  factory AyahCoordinates.fromJson(Map<String, dynamic> json) {
    return AyahCoordinates(
      suraId: json['sura_id'],
      ayaId: json['aya_id'],
      segments: (json['segs'] as List).map((e) => Segment.fromJson(e)).toList(),
    );
  }
}

class Segment {
  final int x;
  final int y;
  final int w;
  final int h;

  Segment({required this.x, required this.y, required this.w, required this.h});

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(x: json['x'], y: json['y'], w: json['w'], h: json['h']);
  }
}

class CoordinateService {
  Future<PageCoordinates> getPageCoordinates(int pageNumber) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/quran/json/page_$pageNumber.json',
      );
      final List<dynamic> data = json.decode(jsonString);
      return PageCoordinates.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load coordinates for page $pageNumber: $e');
    }
  }
}
