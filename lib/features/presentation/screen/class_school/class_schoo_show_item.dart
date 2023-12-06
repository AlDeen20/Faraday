import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hesham/features/domain/entities/courses.dart';
import 'package:pod_player/pod_player.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../business_logic/bloc/home/home_bloc.dart';

class ClassScreenShow extends StatelessWidget {
  const ClassScreenShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageClassScreenShow();
  }
}

class PageClassScreenShow extends StatelessWidget {
  const PageClassScreenShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => instance<HomeBloc>(),
      child: const ItemsShow(),
    );
  }
}

class ItemsShow extends StatelessWidget {
  const ItemsShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Lesson lesson = ModalRoute.of(context)!.settings.arguments as Lesson;
    return PlayVideoFromYoutube(
      lesson: lesson,
    );
  }
}

class PlayVideoFromYoutube extends StatefulWidget {
  final Lesson lesson;
  const PlayVideoFromYoutube({Key? key, required this.lesson})
      : super(key: key);

  @override
  State<PlayVideoFromYoutube> createState() => _PlayVideoFromYoutubeState();
}

class _PlayVideoFromYoutubeState extends State<PlayVideoFromYoutube> {
  late final PodPlayerController controller;
  final podPlayerConfig = const PodPlayerConfig(
      videoQualityPriority: [480, 720, 1080, 360, 240],
      isLooping: false,
      autoPlay: true,
      forcedVideoFocus: true);

  @override
  void initState() {
    super.initState();
    controller = PodPlayerController(
      podPlayerConfig: podPlayerConfig,
      playVideoFrom: PlayVideoFrom.youtube(widget.lesson.video),
    )..initialise();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !controller.isFullScreen
          ? AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      backgroundColor: ColorManager.blackColor,
      body: PodVideoPlayer(
          frameAspectRatio: 16 / 9,
          videoAspectRatio: 16 / 9,
          controller: controller),
    );
  }
}
