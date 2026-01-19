import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/city_model.dart';

part 'prayer_remote_data_source.g.dart';

@RestApi(baseUrl: "https://api.myquran.com/v2")
abstract class PrayerRemoteDataSource {
  factory PrayerRemoteDataSource(Dio dio, {String baseUrl}) =
      _PrayerRemoteDataSource;

  @GET('/sholat/jadwal/{cityId}/{year}/{month}/{day}')
  Future<PrayerScheduleResponse> getPrayerSchedule(
    @Path("cityId") String cityId,
    @Path("year") String year,
    @Path("month") String month,
    @Path("day") String day,
  );

  @GET('/sholat/kota/cari/{keyword}')
  Future<CitySearchResponse> searchCity(@Path("keyword") String keyword);
}

class PrayerScheduleResponse {
  final bool status;
  final PrayerScheduleData? data;

  PrayerScheduleResponse({required this.status, this.data});

  factory PrayerScheduleResponse.fromJson(Map<String, dynamic> json) {
    return PrayerScheduleResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? PrayerScheduleData.fromJson(json['data'])
          : null,
    );
  }
}

class PrayerScheduleData {
  final Map<String, dynamic> jadwal;

  PrayerScheduleData({required this.jadwal});

  factory PrayerScheduleData.fromJson(Map<String, dynamic> json) {
    return PrayerScheduleData(jadwal: json['jadwal'] ?? {});
  }
}

class CitySearchResponse {
  final bool status;
  final List<CityModel>? data;

  CitySearchResponse({required this.status, this.data});

  factory CitySearchResponse.fromJson(Map<String, dynamic> json) {
    return CitySearchResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((e) => CityModel.fromJson(e)).toList()
          : [],
    );
  }
}
