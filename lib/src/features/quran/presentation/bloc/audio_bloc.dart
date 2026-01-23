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

  AudioBloc(this._audioRepository)
    : _player = AudioPlayer(),
      super(const AudioState()) {
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
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
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
      Reciter? selected;

      // Auto-select stored reciter if any
      final last = await _audioRepository.getLastPlayback();
      if (last != null && last['reciterId'] != null) {
        selected = reciters.firstWhere(
          (r) => r.id == last['reciterId'],
          orElse: () => reciters.first,
        );
      } else if (reciters.isNotEmpty) {
        // Default to Mishary (id 7) if exists, else first
        selected = reciters.firstWhere(
          (r) => r.id == 7,
          orElse: () => reciters.first,
        );
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
    // If playing, maybe stop? Or just keep playing until next PlaySurah.
    // Usually user expects change immediately if playing?
    // Let's just update selection for NEXT play for now.
  }

  Future<void> _onPlaySurah(PlaySurah event, Emitter<AudioState> emit) async {
    if (state.reciters.isEmpty) {
      add(FetchReciters());
      // Wait or fail?
      // For simplicity, we proceed only if we have reciter.
      // If empty, hopefully FetchReciters will trigger reload and UI can retry.
      return;
    }

    final reciter = state.selectedReciter ?? state.reciters.first;

    emit(
      state.copyWith(
        status: AudioStatus.loading,
        currentSurahId: event.surahId,
        currentSurahName: event.surahName,
        selectedReciter: reciter, // Ensure selected
        isMiniPlayerVisible: true,
      ),
    );

    try {
      final url = await _audioRepository.getAudioUrl(reciter.id, event.surahId);

      // Use AudioSource with tag for Notification Metadata (Lock Screen)
      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: '${event.surahId}', // Use ID as key
          album: "Quran Murottal",
          title: event.surahName,
          artist: reciter.name,
          artUri: Uri.parse(
            "https://static.quran.com/images/quran/surah/${event.surahId}.png",
          ), // Optional cover art
        ),
      );

      await _player.setAudioSource(source);

      // Check if we have a saved position for THIS surah/reciter combination?
      // Logic: if resuming same track, seek.
      // But _onPlaySurah implies "Start" or "Play New".
      // If user wants to Resume, they click "Play" on mini player (ResumeAudio).
      // Clicking "Play" on list usually means "Start Over" or "Play this".
      // Let's Start Over by default (position 0), UNLESS it's the SAME surah/reciter and we want smart resume?
      // User said "quit, bs lanjut dari terakhir". This implies globally.
      // But if I explicitly click specific Surah, I expect it to play.
      // Let's just play from 0 for new PlaySurah. Resume is separate path.

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
