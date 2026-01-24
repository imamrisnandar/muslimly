import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../data/repositories/audio_repository.dart';
import '../../domain/entities/reciter.dart';
import 'audio_event.dart';
import 'audio_state.dart';

@injectable
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _audioRepository;
  final AudioPlayer _player;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  AudioBloc(this._audioRepository, this._player) : super(const AudioState()) {
    on<InitAudio>(_onInitAudio);
    on<FetchReciters>(_onFetchReciters);
    on<SelectReciter>(_onSelectReciter);
    on<PlaySurah>(_onPlaySurah);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<CloseAudio>(_onCloseAudio);
    on<UpdatePosition>(
      (event, emit) => emit(state.copyWith(position: event.position)),
    );
    on<UpdateDuration>(
      (event, emit) => emit(state.copyWith(duration: event.duration)),
    );
    on<AudioComplete>(_onAudioComplete);
    on<UpdateCurrentAyah>(
      (event, emit) => emit(
        state.copyWith(
          currentAyahNumber: event.ayahNumber,
          clearCurrentAyah: event.ayahNumber == null,
        ),
      ),
    );

    // Subscribe to streams
    _positionSubscription = _player.positionStream.listen((pos) {
      add(UpdatePosition(pos));
    });
    _durationSubscription = _player.durationStream.listen((dur) {
      if (dur != null) add(UpdateDuration(dur));
    });
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        add(AudioComplete());
      }
    });

    // Listen to Sequence State for Ayah tracking
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource?.tag != null) {
        final tag = sequenceState!.currentSource!.tag as MediaItem;
        // Tag ID format: "SurahID" or "SurahID_AyahNumber"
        final parts = tag.id.split('_');
        if (parts.length == 2) {
          final ayahNum = int.tryParse(parts[1]);
          if (ayahNum != null) {
            add(UpdateCurrentAyah(ayahNum));
          }
        } else {
          // Tag is likely just SurahID (Gapless Playback).
          // We must clear the Ayah number to switch UI to Surah Mode.
          if (state.currentAyahNumber != null) {
            add(UpdateCurrentAyah(null));
          }
        }
      }
    });
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    // Do not dispose _player as it is a singleton managed by DI
    return super.close();
  }

  Future<void> _onInitAudio(InitAudio event, Emitter<AudioState> emit) async {
    // 1. Fetch Reciters
    add(FetchReciters());

    // 2. Load Last Playback
    final last = await _audioRepository.getLastPlayback();
    if (last != null) {
      // We can't fully restore user-friendly text (Reciter Name, Surah Name) if we haven't loaded them.
      // But we can store ID.
      // For now, let's just restore IDs. UI will need to handle if names are missing or wait for RecitersLoaded.
      emit(
        state.copyWith(
          currentSurahId: last['surahId'],
          // position: Duration(milliseconds: last['positionMs'] ?? 0),
          // We set position but don't seek yet until played?
          // Or we show mini player in paused state.
          // isMiniPlayerVisible: true, // Don't auto-show on restart
          status: AudioStatus.paused,
        ),
      );
    }
  }

  Future<void> _onFetchReciters(
    FetchReciters event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.loading));
    try {
      final reciters = await _audioRepository.fetchReciters();
      // Preserve existing selection if already set (e.g. by concurrent PlaySurah)
      Reciter? selected = state.selectedReciter;

      if (selected == null) {
        // Auto-select stored reciter if any
        final last = await _audioRepository.getLastPlayback();
        if (last != null && last['reciterId'] != null) {
          selected = reciters.firstWhere(
            (r) => r.id == last['reciterId'],
            orElse: () => reciters.first,
          );
        } else if (reciters.isNotEmpty) {
          // User Request: Default to first data (Full Surah) for Play Surah
          selected = reciters.first;
        }
      }

      emit(
        state.copyWith(
          status: AudioStatus.ready,
          reciters: reciters,
          selectedReciter: selected,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioStatus.error,
          errorMessage: 'Failed to load reciters',
        ),
      );
    }
  }

  void _onSelectReciter(SelectReciter event, Emitter<AudioState> emit) {
    emit(state.copyWith(selectedReciter: event.reciter));

    // Auto Replay with new Qori if context is active
    if (state.currentSurahId != null) {
      final isChapterSource =
          event.reciter.source == AudioSourceType.quranComChapter;
      add(
        PlaySurah(
          surahId: state.currentSurahId!,
          surahName: state.currentSurahName ?? '',
          startAyah: isChapterSource ? null : state.currentAyahNumber,
        ),
      );
    }
  }

  Future<void> _onPlaySurah(PlaySurah event, Emitter<AudioState> emit) async {
    var currentReciters = state.reciters;
    if (currentReciters.isEmpty) {
      // Try fetching immediately
      emit(state.copyWith(status: AudioStatus.loading));
      try {
        currentReciters = await _audioRepository.fetchReciters();
        emit(state.copyWith(reciters: currentReciters));
      } catch (e) {
        // Ignore error here, check emptiness below
      }

      if (currentReciters.isEmpty) {
        emit(
          state.copyWith(
            status: AudioStatus.error,
            errorMessage: 'Gagal memuat data Qori. Periksa internet Anda.',
          ),
        );
        add(FetchReciters()); // Retry in background
        return;
      }
    }

    var reciter = state.selectedReciter ?? currentReciters.first;

    // Enforce Compatibility
    if (event.startAyah != null && event.startAyah! > 0) {
      // Verse Mode: Require Verse-by-Verse
      if (reciter.source == AudioSourceType.quranComChapter) {
        final verseReciter = currentReciters.firstWhere(
          (r) =>
              r.source == AudioSourceType.alQuranCloudVerse &&
              r.id == 'ar.alafasy',
          orElse: () => currentReciters.firstWhere(
            (r) => r.source == AudioSourceType.alQuranCloudVerse,
            orElse: () => reciter,
          ),
        );
        reciter = verseReciter;
      }
    } else {
      // Surah Mode: Prefer Gapless (Full Surah)
      if (reciter.source == AudioSourceType.alQuranCloudVerse) {
        final chapterReciter = currentReciters.firstWhere(
          (r) => r.source == AudioSourceType.quranComChapter,
          orElse: () => reciter,
        );
        reciter = chapterReciter;
      }
    }

    emit(
      state.copyWith(
        status: AudioStatus.loading,
        currentSurahId: event.surahId,
        currentSurahName: event.surahName,
        currentAyahNumber: event.startAyah, // Reset or Set Ayah Number
        clearCurrentAyah: event.startAyah == null, // Explicitly Clear if null
        selectedReciter: reciter, // Update global selection
        isMiniPlayerVisible: true,
      ),
    );

    try {
      // 1. Fetch URLs for all Ayahs in Surah
      final urls = await _audioRepository.getSurahAudioUrls(
        reciter.id,
        event.surahId,
      );

      if (urls.isEmpty) throw Exception('No audio URLs found');

      // 2. Determine Mode (Full Surah vs Playlist)
      if (urls.length == 1) {
        // Full Surah Mode
        final url = urls.first;
        final source = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: '${event.surahId}',
            album: "Quran Recitation",
            title: event.surahName,
            artist: reciter.name,
            artUri: Uri.parse(
              "https://static.quran.com/images/quran/surah/${event.surahId}.png",
            ),
          ),
        );
        await _player.setAudioSource(source);
      } else {
        // Verse-by-Verse Mode
        final playlist = ConcatenatingAudioSource(
          children: urls.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            final ayahNumber = index + 1;

            return AudioSource.uri(
              Uri.parse(url),
              tag: MediaItem(
                id: '${event.surahId}_$ayahNumber',
                album: "Quran Murottal",
                title: "${event.surahName} : Ayah $ayahNumber",
                artist: reciter.name,
                artUri: Uri.parse(
                  "https://static.quran.com/images/quran/surah/${event.surahId}.png",
                ),
              ),
            );
          }).toList(),
        );

        final initialIndex = (event.startAyah != null && event.startAyah! > 0)
            ? event.startAyah! - 1
            : 0;

        await _player.setAudioSource(
          playlist,
          initialIndex: initialIndex < urls.length ? initialIndex : 0,
          initialPosition: Duration.zero,
        );
      }

      _player.play();
      emit(state.copyWith(status: AudioStatus.playing));

      // Save that we started
      _saveState();
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioStatus.error,
          errorMessage: 'Failed to play audio: $e',
        ),
      );
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) async {
    await _player.pause();
    emit(state.copyWith(status: AudioStatus.paused));
    _saveState();
  }

  Future<void> _onResumeAudio(
    ResumeAudio event,
    Emitter<AudioState> emit,
  ) async {
    // If player has source, just play.
    if (_player.audioSource != null) {
      _player.play();
      emit(state.copyWith(status: AudioStatus.playing));
    } else {
      // If no source (app restart), we need to RELOAD from saved state.
      if (state.currentSurahId != null && state.selectedReciter != null) {
        // Re-trigger play logic but seek to saved position?
        // Complex. For now, assume _onPlaySurah handles new source.
        // If we want to resume content that was loaded in Init but not set to player:
        add(
          PlaySurah(
            surahId: state.currentSurahId!,
            surahName:
                state.currentSurahName ?? 'Surah ${state.currentSurahId}',
          ),
        );
        // Logic gap: We lost the exact position if we just PlaySurah (0).
        // Fix: In _onPlaySurah, allow seeking?
        // Or dedicated _RestoreSession event?
      }
    }
  }

  Future<void> _onCloseAudio(CloseAudio event, Emitter<AudioState> emit) async {
    await _player.stop();
    emit(
      state.copyWith(
        status: AudioStatus.ready,
        isMiniPlayerVisible: false,
        position: Duration.zero,
      ),
    );
    // Clear persisted maybe? No, keep history.
  }

  void _onAudioComplete(AudioComplete event, Emitter<AudioState> emit) {
    emit(
      state.copyWith(
        status: AudioStatus.paused, // Or ready
        position: Duration.zero,
      ),
    );
    _saveState(); // Save finished state (pos 0 or close to end)
  }

  Future<void> _saveState() async {
    if (state.currentSurahId != null && state.selectedReciter != null) {
      await _audioRepository.saveLastPlayback(
        state.currentSurahId!,
        state.selectedReciter!.id,
        state.position.inMilliseconds,
      );
    }
  }
}
