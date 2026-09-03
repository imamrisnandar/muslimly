import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:path_provider/path_provider.dart';

import '../../../../core/config/app_urls.dart';

/// Downloads the QPC v2 per-page mushaf fonts (`QCF2001.ttf` .. `QCF2604.ttf`)
/// on demand, caches them on disk, and registers each one with the Flutter
/// engine as the font family `QCF_P001` .. `QCF_P604`.
///
/// Register this as a **singleton** (see `di_container`) so the in-memory
/// bookkeeping and the HTTP client are reused by every mushaf / hafalan page —
/// previously each page built its own `FontCacheService(Dio())`, which meant no
/// dedupe and a fresh client per page.
///
/// It keeps its own plain [Dio] rather than the injected API one: the API client
/// carries a `LogInterceptor` (debug) that consumes `download()` stream
/// responses, an `application/json` content type, and — irrelevant here — the
/// `api.muslimly.id` base URL. The QPC fonts are public static assets on the
/// CDN, so a bare client is both correct and simpler.
class FontCacheService {
  FontCacheService() : _dio = Dio();

  final Dio _dio;

  /// Asset version — also the path segment on the CDN (`.../qpc/v2/...`) and the
  /// on-disk cache folder. Bump both together when the fonts are re-cut.
  static const String _version = 'v2';
  static const int _totalPages = 604;
  static const int _minFontBytes = 2000;

  /// Pages whose font is already registered with the engine this session.
  final Set<int> _installed = <int>{};

  /// In-flight installs, so concurrent callers (an on-screen page + its
  /// prefetched neighbours, or fast swiping) share one future instead of
  /// racing on the same download.
  final Map<int, Future<void>> _inFlight = <int, Future<void>>{};

  Directory? _dir;

  bool isPageInstalled(int page) => _installed.contains(page);

  /// Ensures the font for [pageNumber] is downloaded and registered.
  ///
  /// Returns immediately if it was already installed this session. Throws only
  /// when the font is neither cached nor downloadable — callers surface that as
  /// a "check your connection / retry" state.
  Future<void> loadPageFont(int pageNumber) {
    if (pageNumber < 1 || pageNumber > _totalPages) {
      return Future.error(ArgumentError.value(pageNumber, 'pageNumber'));
    }
    if (_installed.contains(pageNumber)) return Future<void>.value();

    final existing = _inFlight[pageNumber];
    if (existing != null) return existing;

    // NB: the whenComplete callback must have a block body — an arrow body
    // would *return* `Map.remove`'s result (the very future we're building),
    // and whenComplete would then wait on it, deadlocking the future forever.
    final future = _install(pageNumber).whenComplete(() {
      _inFlight.remove(pageNumber);
    });
    _inFlight[pageNumber] = future;
    return future;
  }

  /// Fire-and-forget: warm the cache for the pages around [pageNumber] so the
  /// next swipe renders instantly. Best effort — failures are swallowed.
  void prefetchAround(int pageNumber, {int radius = 1}) {
    for (var d = 1; d <= radius; d++) {
      for (final p in <int>[pageNumber - d, pageNumber + d]) {
        if (p < 1 || p > _totalPages || _installed.contains(p)) continue;
        if (_inFlight.containsKey(p)) continue;
        unawaited(loadPageFont(p).catchError((_) {}));
      }
    }
  }

  Future<void> _install(int pageNumber) async {
    final fileName = _fileFor(pageNumber);
    final family = _familyFor(pageNumber);
    final file = File('${(await _cacheDir()).path}/$fileName');

    if (!await _isUsable(file)) {
      await _adoptLegacyFile(fileName, file);
    }
    if (!await _isUsable(file)) {
      await _download(fileName, file);
    }

    var bytes = await file.readAsBytes();
    if (!_looksLikeSfnt(bytes)) {
      // Corrupt cache entry — drop it and pull a fresh copy once.
      await file.delete().catchError((_) => file);
      await _download(fileName, file);
      bytes = await file.readAsBytes();
      if (!_looksLikeSfnt(bytes)) {
        throw Exception('page $pageNumber font is not a valid font file');
      }
    }

    final loader = FontLoader(family)
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
    _installed.add(pageNumber);
  }

  Future<void> _download(String fileName, File dest) async {
    final url = '${AppUrls.qpcFontsCdn}/$fileName';
    await dest.parent.create(recursive: true);
    final tmp = File('${dest.path}.tmp');
    try {
      await _dio.download(
        url,
        tmp.path,
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );
      if (await tmp.length() < _minFontBytes) {
        throw Exception('downloaded $fileName is too small (${await tmp.length()} B)');
      }
      if (await dest.exists()) await dest.delete();
      await tmp.rename(dest.path);
    } catch (_) {
      await tmp.delete().catchError((_) => tmp);
      rethrow;
    }
  }

  /// Older app versions cached fonts in the (iCloud-backed, user-visible on iOS)
  /// documents directory. Move any such file into the current cache dir so
  /// updating users don't re-download ~200 MB of fonts.
  Future<void> _adoptLegacyFile(String fileName, File dest) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final legacy = File('${docs.path}/fonts/quran/$fileName');
      if (!await _isUsable(legacy)) return;
      await dest.parent.create(recursive: true);
      try {
        await legacy.rename(dest.path);
      } on FileSystemException {
        // Different volume — copy then remove the original.
        await legacy.copy(dest.path);
        await legacy.delete().catchError((_) => legacy);
      }
    } catch (_) {
      // Best effort; a failed migration just means a re-download.
    }
  }

  Future<Directory> _cacheDir() async {
    final cached = _dir;
    if (cached != null) return cached;
    Directory base;
    try {
      base = await getApplicationCacheDirectory();
    } catch (_) {
      base = await getApplicationSupportDirectory();
    }
    final dir = Directory('${base.path}/quran_fonts/$_version');
    await dir.create(recursive: true);
    return _dir = dir;
  }

  Future<bool> _isUsable(File f) async {
    try {
      return await f.exists() && await f.length() >= _minFontBytes;
    } catch (_) {
      return false;
    }
  }

  String _fileFor(int page) => 'QCF2${page.toString().padLeft(3, '0')}.ttf';

  String _familyFor(int page) => 'QCF_P${page.toString().padLeft(3, '0')}';

  /// True if [b] starts with a known SFNT magic number (TrueType / OpenType).
  bool _looksLikeSfnt(Uint8List b) {
    if (b.length < 4) return false;
    final tag = (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3];
    return tag == 0x00010000 || // TrueType outlines
        tag == 0x74727565 || // 'true'
        tag == 0x4F54544F || // 'OTTO' (CFF outlines)
        tag == 0x74746366; // 'ttcf' (font collection)
  }
}
