import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'file_manager.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  final OnAudioQuery audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  //Notifiers
  final audioStatusNotifier = ValueNotifier<AudioStatus>(AudioStatus.paused);
  final progressNotifier = ValueNotifier<ProgressBarStatus>(ProgressBarStatus.zero());

  final currentSongMetaDataNotifier = ValueNotifier<AudioMetadata?>(null);
  final currentSongIDNotifier = ValueNotifier<int>(0);
  final currentSongTitleNotifier = ValueNotifier<String>("Unknown");
  final currentSongArtistNotifier = ValueNotifier<String>("Unknown");
  final currentSongArtworkNotifier = ValueNotifier<Uint8List?>(null);

  final playlistNotifier = ValueNotifier<List<String>>([]);
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final loopModeNotifier = ValueNotifier<LoopModeState>(LoopModeState.loopAll);

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _initPlayerStateStream();
    _initPositionStream();
    _initBufferPositionStream();
    _initDurationStream();
    _initSequenceStateStream();
  }

  Future<void> seek(Duration duration) async {
    await audioPlayer.seek(duration);
  }

  void pauseAudio() {
    try {
      audioPlayer.pause();
      // ignore: empty_catches
    } on Exception {}
  }

  void playAudio() {
    try {
      audioPlayer.play();
      // ignore: empty_catches
    } on Exception {}
  }

  void seekToPreviousAudio() {
    audioPlayer.seekToPrevious();
  }

  void seekToNextAudio() {
    audioPlayer.seekToNext();
  }

  void setLoopModeToLoopAll() {
    loopModeNotifier.value = LoopModeState.loopAll;
    audioPlayer.setShuffleModeEnabled(false);
    audioPlayer.setLoopMode(LoopMode.all);
  }

  void setLoopModeToLoopOne() {
    loopModeNotifier.value = LoopModeState.loopOne;
    audioPlayer.setLoopMode(LoopMode.one);
  }

  void setLoopModeToShuffle() {
    loopModeNotifier.value = LoopModeState.shuffle;
    audioPlayer.setShuffleModeEnabled(true);
    audioPlayer.setLoopMode(LoopMode.all);
  }

  void _initPlayerStateStream() {
    audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        // buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        audioStatusNotifier.value = AudioStatus.paused;
      } else if (processingState != ProcessingState.completed) {
        audioStatusNotifier.value = AudioStatus.playing;
      } else {
        audioPlayer.seek(Duration.zero);
        pauseAudio();
      }
    });
  }

  void _initPositionStream() {
    audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarStatus(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _initBufferPositionStream() {
    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarStatus(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _initDurationStream() {
    audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarStatus(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void _initSequenceStateStream() {
    audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;
      final currentItem = sequenceState.currentSource;
      final tag = currentItem?.tag as AudioMetadata?;
      if (tag != null) {
        currentSongMetaDataNotifier.value = tag;
        currentSongIDNotifier.value = tag.id;
        currentSongTitleNotifier.value = tag.title;
        currentSongArtistNotifier.value = tag.artist;
        currentSongArtworkNotifier.value = tag.artwork;
      }
      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;
      final playlist = sequenceState.effectiveSequence;
      if (playlist.isEmpty || currentItem == null) {
        isFirstSongNotifier.value = true;
        isLastSongNotifier.value = true;
      } else {
        isFirstSongNotifier.value = playlist.first == currentItem;
        isLastSongNotifier.value = playlist.last == currentItem;
      }
    });
  }
}

class ProgressBarStatus {
  late final Duration current;
  late final Duration buffered;
  late final Duration total;

  ProgressBarStatus({required this.current, required this.buffered, required this.total});

  ProgressBarStatus.zero() {
    current = Duration.zero;
    buffered = Duration.zero;
    total = Duration.zero;
  }
}

enum AudioStatus {
  playing,
  paused,
  // loading
}

enum LoopModeState {
  loopOne,
  loopAll,
  shuffle,
}
