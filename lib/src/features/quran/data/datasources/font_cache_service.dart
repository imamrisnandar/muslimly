import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FontCacheService {
  final Dio _dio;
  // jsDelivr CDN for qpc-fonts
  final String _cdnBaseUrl =
      'https://cdn.jsdelivr.net/gh/nuqayah/qpc-fonts@master/mushaf-v2';

  FontCacheService(this._dio);

  Future<void> loadPageFont(int pageNumber) async {
    final String pageStr = pageNumber.toString().padLeft(3, '0');
    final String fontName = 'QCF_P$pageStr';
    // Repo uses QCF2001.ttf format inside mushaf-v2 (based on research)
    // or sometimes just P001. We'll stick to what worked or standarize.
    // Research said QCF2001.ttf is in mushaf-v2.
    final String fileName = 'QCF2$pageStr.ttf';

    try {
      // 1. Check if font is already loaded in Flutter engine
      // There is no direct API to check if font is loaded, but re-loading is safe-ish or we can track it.
      // Ideally we track it in a Set in memory.
      // For now, we proceed to ensure file exists and load it.

      // 2. Get local path
      final Directory docDir = await getApplicationDocumentsDirectory();
      final String localPath = '${docDir.path}/fonts/quran/$fileName';
      final File fontFile = File(localPath);

      if (!await fontFile.exists()) {
        // 3. Download if not exists
        await _downloadFont(fileName, localPath);
      }
      ;

      // 4. Load into Flutter
      final Uint8List fontData = await fontFile.readAsBytes();
      final ByteData byteData = ByteData.view(fontData.buffer);

      final fontLoader = FontLoader(fontName);
      fontLoader.addFont(Future.value(byteData));
      await fontLoader.load();

      print('✅ Font Loaded: $fontName');
    } catch (e) {
      print('❌ Error loading font $fontName: $e');
      // Rethrow to show actual error in UI
      throw Exception('Failed to load page $pageNumber: $e');
    }
  }

  Future<void> _downloadFont(String fileName, String savePath) async {
    // Construct the Direct CDN URL
    final String downloadUrl = '$_cdnBaseUrl/$fileName';

    try {
      print('⬇️ Downloading font from $downloadUrl...');

      // Ensure directory exists
      final File file = File(savePath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      await _dio.download(downloadUrl, savePath);
      print('✅ Download complete: $savePath');
    } catch (e) {
      print('❌ Download failed for $downloadUrl: $e');
      if (e is DioException) {
        print(
          'DioError: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      }
      rethrow;
    }
  }
}
