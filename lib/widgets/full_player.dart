import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';

import '../assets/fnt_styles.dart';
import '../assets/icos.dart';
import '../assets/imgs.dart';
import '../controllers/btn_controllers.dart';
import '../controllers/value_notifier.dart';
import '../models/progress_bar_status.dart';
import '../models/song_metadata.dart';
import '../services/audio_manager.dart';
import '../util/util_artwork.dart';
import 'button/btn_loop_mode.dart';
import 'button/btn_favourite.dart';
import 'button/btn_play_pause.dart';
import 'button/btn_skip_next.dart';
import 'button/btn_skip_previous.dart';
import 'button/tap_effect.dart';
import 'card/card_effective_playlist_item.dart';
import 'list/current_playlist_horizontal_list.dart';

class FullPlayer extends StatelessWidget {
  const FullPlayer({Key? key, required this.closeButtonOnTap})
      : super(key: key);

  final VoidCallback closeButtonOnTap;

  @override
  Widget build(BuildContext context) {
    Size size;
    size = MediaQuery.of(context).size;
    var _appearance = CircularSliderAppearance(
      size: size.width * 0.6 + 40,
      startAngle: 150,
      counterClockwise: true,
      angleRange: 120,
      animationEnabled: true,
      customWidths: CustomSliderWidths(
        handlerSize: 4,
        shadowWidth: 3 * 1.4,
        progressBarWidth: 3,
        trackWidth: 2,
      ),
      spinnerMode: false,
    );
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Imgs.img_default_music_cover),
              fit: BoxFit.cover,
            ),
          ),
          child: ValueListenableBuilder<Uint8List?>(
            valueListenable: currentSongArtworkNotifier,
            builder: (_, artworkData, __) => ClipRRect(
              child: getArtwork(artworkData: artworkData),
            ),
          ),
        ),
        Container(
          color: const Color.fromRGBO(0, 0, 0, 0.7),
          child: const GlassContainer(
            blur: 30,
            border: Border.fromBorderSide(BorderSide.none),
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(
                right: size.width * 0.1 - 27, top: size.width * 0.1),
            child: TapEffect(
              padding: const EdgeInsets.all(17),
              onTap: closeButtonOnTap,
              child: const Icon(
                Icos.dots,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<Uint8List?>(
              valueListenable: currentSongArtworkNotifier,
              builder: (_, artwork, __) {
                return Container(
                  height: size.height * 0.5,
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(1000)),
                    image: DecorationImage(
                      image: getArtwork(artworkData: artwork).image,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                );
              }),
        ),
        Padding(
          padding:
              EdgeInsets.only(top: size.height * 0.5 - size.width * 0.6 - 20),
          child: ValueListenableBuilder<ProgressBarStatus>(
            valueListenable: progressNotifier,
            builder: (_, progressData, __) {
              var totalSec = progressData.total.inSeconds.toDouble();
              var currentSec =
                  progressData.current.inSeconds.clamp(0, totalSec).toDouble();
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SleekCircularSlider(
                      appearance: _appearance,
                      innerWidget: (a) => const SizedBox(),
                      min: 0,
                      max: totalSec,
                      initialValue: currentSec,
                      onChangeEnd: (details) {
                        AudioManager().seek(Duration(seconds: details.toInt()));
                        isUpdateProgressNotifier = true;
                      },
                      onChangeStart: (details) {
                        isUpdateProgressNotifier = false;
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: size.width * 0.6 - 50,
                        left: size.width * 0.1,
                      ),
                      child: Text(
                        progressData.current.toString().substring(2, 7),
                        style: FntStyles.progressTimeLabelStyle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: size.width * 0.6 - 50,
                        right: size.width * 0.1,
                      ),
                      child: Text(
                        progressData.total.toString().substring(2, 7),
                        style: FntStyles.progressTimeLabelStyle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<SongMetadata>(
              valueListenable: currentSongMetaDataNotifier,
              builder: (_, metadata, __) {
                return FittedBox(
                  alignment: Alignment.topCenter,
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    height: size.height * 0.5,
                    width: size.width * 0.7,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: size.height * 0.5 - size.width * 0.3 + 20,
                            ),
                            child: ArcText(
                              text: metadata.title,
                              textStyle: GoogleFonts.rajdhani(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                              radius: size.width * 0.3 + 20,
                              placement: Placement.outside,
                              startAngle: 180 / 180 * pi,
                              startAngleAlignment: StartAngleAlignment.center,
                              direction: Direction.counterClockwise,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 30,
                            ),
                            child: ArcText(
                              text: metadata.artist,
                              textStyle: GoogleFonts.itim(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                              radius: size.width * 0.3 + 20,
                              placement: Placement.outside,
                              startAngle: 180 / 180 * pi,
                              startAngleAlignment: StartAngleAlignment.center,
                              direction: Direction.counterClockwise,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: size.height * 0.5 + 120),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Column(
                children: [
                  _btnsWidget(size),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: _extraBtnsWidget(size),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: CurrentPlaylistFullPlayer(),
          ),
        )
      ],
    );
  }

  Widget _extraBtnsWidget(Size size) {
    return Container(
      width: size.width * 0.6,
      height: size.width * 0.6 * 0.25,
      decoration: const BoxDecoration(
          color: Color.fromRGBO(96, 125, 139, 0.3),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const LoopButton(),
          BtnFavourite(),
          Icon(
            Icos.timer,
            size: 25,
            color: Colors.white.withOpacity(0.7),
          ),
          Icon(
            Icos.speed,
            size: 25,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _btnsWidget(Size size) {
    return SizedBox(
      width: size.width * 0.4,
      height: size.width * 0.12,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                BtnSkipPrevious(),
                BtnSkipNext(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: BtnPlayPause(size: size.width * 0.12),
          ),
        ],
      ),
    );
  }
}

class CurrentPlaylistFullPlayer extends StatefulWidget {
  const CurrentPlaylistFullPlayer({Key? key}) : super(key: key);

  @override
  State<CurrentPlaylistFullPlayer> createState() =>
      _CurrentPlaylistFullPlayerState();
}

class _CurrentPlaylistFullPlayerState extends State<CurrentPlaylistFullPlayer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SongMetadata>>(
      valueListenable: playlistNotifier,
      builder: (_, effectivePlaylist, __) {
        return HorizontalCardPager(
          initialPage:
              effectivePlaylist.indexOf(currentSongMetaDataNotifier.value),
          items: getPlaylistItems(effectivePlaylist),
          onPageChanged: (page) {
            if (page.toString().split(".")[1] == "0" && isOnChangeWork) {
              songItemTaped(index: page.toInt());
            }
          },
        );
      },
    );
  }

  List<CardItem> getPlaylistItems(List<SongMetadata> playlist) {
    return playlist
        .map((e) => CardEffectivePlaylistItem(
              songMetadata: e,
            ))
        .toList();
  }
}
