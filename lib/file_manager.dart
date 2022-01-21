import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';

import 'audio_manager.dart';
import 'third_layer.dart';

part 'file_manager.g.dart';

@JsonSerializable()
class UserData {
  static UserData _instance = UserData._internal();

  UserData._internal();

  UserData.importLoadedData(UserData loadedData) {
    _instance = loadedData;
  }

  factory UserData() {
    return _instance;
  }

  //the attributes of the UserData Class
  List<AudioMetadata> audiosMetadata = <AudioMetadata>[];
  SongSortType songSortType = SongSortType.DATE_ADDED;
  int currentAudioFileID = 0;
}

@JsonSerializable()
class AudioMetadata {
  AudioMetadata({
    required this.id,
    required this.data,
    required this.title,
    required String? artist,
    required String? album,
    required Uint8List? artwork,
  })  : artist = artist ?? "Unknown",
        album = album ?? "Unknown",
        artwork = ((artwork != null && artwork.isNotEmpty) ? artwork : null);

  final int id;
  final String data;
  final String title;
  final String artist;
  final String album;

  @JsonKey(toJson: _artworkToString, fromJson: _stringToArtwork)
  final Uint8List? artwork;

  static String? _artworkToString(Uint8List? art) {
    if (art == null) return null;
    return String.fromCharCodes(art);
  }

  static Uint8List? _stringToArtwork(String? str) {
    if (str == null) return null;
    return Uint8List.fromList(str.codeUnits);
  }
}

Future<void> permissionsRequest() async {
  var state = await AudioManager().audioQuery.permissionsStatus();
  if (!state) {
    await AudioManager()
        .audioQuery
        .permissionsRequest()
        .whenComplete(() => loadUserData());
  }
}

void loadUserData() async {
  var sharedPreferences = await SharedPreferences.getInstance();
  String? data = sharedPreferences.getString("data");
  if (data != null) {
    if (kDebugMode) {
      var time = DateTime.now();
      print(
          "Loading UserData => time: ${time.minute}: ${time.second}: ${time.millisecond}");
    }

    UserData.importLoadedData(
        _$UserDataFromJson(jsonDecode(sharedPreferences.getString("data")!)));

    if (kDebugMode) {
      var time = DateTime.now();
      print(
          "Loading UserData Completed => time: ${time.minute}: ${time.second}: ${time.millisecond}");
    }
  } else {
    updateAudios();
  }
  ThirdLayerState.updateWidget();
}

Future<void> updateAudios() async {
  if (kDebugMode) {
    var time = DateTime.now();
    print(
        "Checking Storage => time: ${time.minute}: ${time.second}: ${time.millisecond}");
  }
  List<SongModel> tmpSongs = (await AudioManager().audioQuery.querySongs(
          sortType: UserData().songSortType,
          orderType: OrderType.DESC_OR_GREATER))
      .where((element) {
    if (element.duration == null ||
        !element.isMusic! ||
        element.duration! <= 60000) {
      return false;
    }
    return true;
  }).toList();

  List<AudioMetadata> audiosMetadata = <AudioMetadata>[];

  for (SongModel songModel in tmpSongs) {
    var art = await AudioManager()
        .audioQuery
        .queryArtwork(songModel.id, ArtworkType.AUDIO);
    audiosMetadata.add(AudioMetadata(
        id: songModel.id,
        data: songModel.data,
        title: songModel.title,
        artist: songModel.artist!,
        album: songModel.album!,
        artwork: art));
  }
  if (kDebugMode) {
    var time = DateTime.now();
    print(
        "Checking Storage Completed => time: ${time.minute}: ${time.second}: ${time.millisecond}");
  }

  if (kDebugMode) {
    var time = DateTime.now();
    print(
        "Updating UserData => time: ${time.minute}: ${time.second}: ${time.millisecond}");
  }
  UserData().audiosMetadata = audiosMetadata;
  var sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString("data", jsonEncode(_$UserDataToJson(UserData())));
  if (kDebugMode) {
    var time = DateTime.now();
    print(
        "Updating UserData Completed => time: ${time.minute}: ${time.second}: ${time.millisecond}");
  }
}