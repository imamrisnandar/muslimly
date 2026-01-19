import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/ayah_model.dart';
import '../models/surah_model.dart';

part 'quran_remote_data_source.g.dart';

@RestApi()
abstract class QuranRemoteDataSource {
  factory QuranRemoteDataSource(Dio dio) = _QuranRemoteDataSource;

  @GET('/quran/surahs')
  Future<SurahResponse> getSurahs();

  @GET('/quran/ayahs')
  Future<AyahResponse> getAyahs(@Query('surah_id') int surahId);
}

// Wrapper classes to handle the API response structure "data": [...]
class SurahResponse {
  final List<SurahModel> data;
  SurahResponse({required this.data});

  factory SurahResponse.fromJson(Map<String, dynamic> json) {
    return SurahResponse(
      data: (json['data'] as List)
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AyahResponse {
  final List<AyahModel> data;
  AyahResponse({required this.data});

  factory AyahResponse.fromJson(Map<String, dynamic> json) {
    return AyahResponse(
      data: (json['data'] as List)
          .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
