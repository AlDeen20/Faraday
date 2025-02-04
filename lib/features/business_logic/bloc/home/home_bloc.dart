import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:hesham/core/extension/extension.dart';
import 'package:hesham/core/resources/app_constant.dart';
import 'package:hesham/features/data/model/mapper/app_response.dart';
import 'package:hesham/features/data/model/response/auth/app_response.dart';
import 'package:hesham/features/data/network/requests_entity/request_entity.dart';
import 'package:hesham/features/domain/entities/chat.dart';
import 'package:hesham/features/domain/entities/courses.dart';
import 'package:hesham/features/domain/entities/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../core/enum/enums.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../../core/services/permission.dart';
import '../../../domain/usecases/app_usecase.dart';
import 'package:screen_capture_event/screen_capture_event.dart';

part 'home_event.dart';
part 'home_state.dart';

const throttleDuration = Duration(milliseconds: AppValue.appValue100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUseCase homeUseCase;
  final SheetUseCase sheetUseCase;
  final AttendanceUseCase attendanceUseCase;
  final LogoutUseCase logoutUseCase;
  final PermissionHandling permissionHandling;
  final ScreenCaptureEvent screenListener = ScreenCaptureEvent();
  HomeBloc(
      {required this.logoutUseCase,
      required this.homeUseCase,
      required this.attendanceUseCase,
      required this.sheetUseCase,
      required this.permissionHandling})
      : super(const HomeState()) {
    on<GetHomeData>(_onGetHomeData);
    on<GetDeomHomeData>(_onGetDeomHomeData);
    on<SelectedSubject>(_onSelectedSubject);
    on<SheetLessonEvent>(_onSheetLessonEvent);
    on<RecordingEvent>(_onRecordingEvent);
    on<AttendanceLessonEvent>(_onAttendanceLessonEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<PickFile>(_onPickFile);
    screenListener
        .addScreenRecordListener((recorded) => add(RecordingEvent(recorded)));
    screenListener.watch();
  }

  void _onLogoutEvent(LogoutEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(statePage: StatePage.loading));
    await logoutUseCase.execute(unit);
    emit(state.copyWith(logout: true));
  }

  void _onRecordingEvent(RecordingEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isRecording: event.isRecord));
  }

  void _onAttendanceLessonEvent(
      AttendanceLessonEvent event, Emitter<HomeState> emit) async {
    await attendanceUseCase.execute(LessonRequest(event.lesson.id));
  }

  void _onSheetLessonEvent(
      SheetLessonEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(statePage: StatePage.loading));
    final result =
        await sheetUseCase.execute(SheetRequest(event.lesson.id, event.file));
    result.fold(
        (failure) =>
            emit(state.copyWith(failure: failure, statePage: StatePage.error)),
        (homeData) =>
            emit(state.copyWith(statePage: StatePage.data, isUploaded: true)));
  }

  void _onSelectedSubject(
      SelectedSubject event, Emitter<HomeState> emit) async {
    emit(state.copyWith(selected: event.id, subject: event.subject));
  }

  void _onPickFile(PickFile event, Emitter<HomeState> emit) async {
    final hasPermission =
        await permissionHandling.checkPermission(Permission.storage);
    if (hasPermission == DataSourcePermission.allow) {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'pdf',
          'png',
          'jpeg',
          'jfif',
          'pjpeg',
          'pjp',
          'tiff',
          'tif'
        ],
      );

      if (result == null) {
        return null;
      } else {
        File file = File(result.files.single.path!);
        emit(state.copyWith(file: file));
      }
    } else {
      emit(state.copyWith(
          statePage: StatePage.error,
          failure: DataSourcePermission.permissionDenied.getFailure()));
    }
  }

  void _onGetHomeData(GetHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(statePage: StatePage.loading));
    final result = await homeUseCase.execute(unit);
    result.fold(
        (failure) =>
            emit(state.copyWith(failure: failure, statePage: StatePage.error)),
        (homeData) {
      if ((AppConstants.versionIos < homeData.data.iosVersion &&
              Platform.isIOS) ||
          (AppConstants.versionAndroid < homeData.data.androidVersion &&
              !Platform.isIOS)) {
        emit(state.copyWith(
            failure: AppConstants.updateFailure, statePage: StatePage.error));
      } else {
        Subject subject = homeData.data.subjects.isNotEmpty
            ? homeData.data.subjects.first
            : const Subject.empty();
        emit(state.copyWith(
            homeData: homeData,
            statePage: StatePage.data,
            subject: subject,
            images: homeData.data.images,
            selected: subject.id));
      }
    });
  }

  void _onGetDeomHomeData(
      GetDeomHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(statePage: StatePage.loading));
    final homeData = HomeSubjectResponse.fromJson(json).toDomain();
    Subject subject = homeData.data.subjects.isNotEmpty
        ? homeData.data.subjects.first
        : const Subject.empty();
    emit(state.copyWith(
        homeData: homeData,
        statePage: StatePage.data,
        subject: subject,
        images: homeData.data.images,
        selected: subject.id));
  }

  @override
  Future<void> close() {
    screenListener.dispose();
    return super.close();
  }
}

const Map<String, dynamic> json = {
  "success": true,
  "status": 1,
  "message": "code send successfully",
  "data": {
    "subjects": [
      {
        "id": 7,
        "title": "الكيمياء",
        "description": null,
        "state": "shown",
        "courses": [
          {
            "id": 1,
            "subject_id": "1",
            "title": " مراجعات المركزة الوزارية المجانية",
            "description": 'مراجعات',
            "lessons": [
              {
                "id": 1,
                "course_id": "2",
                "title": "فصل ١",
                "description": null,
                "video": "https://youtu.be/C61i5uk8NXA",
                "attachments": []
              },
              {
                "id": 2,
                "course_id": "2",
                "title": "فصل 2",
                "description": null,
                "video": "https://youtu.be/uPMEGOhS3kw",
                "attachments": []
              },
            ]
          }
        ]
      },
    ],
    "images": [
      "https://rtltec.com//storage/app/mock4.jpg",
      "https://rtltec.com//storage/app/mock2.jpg",
      "https://rtltec.com//storage/app/mock3.jpg"
    ],
    "android_version": 1,
    "ios_version": 1
  },
  "errorId": ""
};
