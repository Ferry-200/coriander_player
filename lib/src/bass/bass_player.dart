import 'dart:async';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'bass.dart';
import 'dart:ffi' as ffi;

enum PlayerState {
  /// stop() has been called or the end of an audio has been reached
  stopped,

  /// start() has been called
  playing,

  /// pause() has been called
  paused,

  /// BASS_Pause() has been called or stopping unexpectedly (eg. a USB soundcard being disconnected).
  /// In either case, playback will be resumed by BASS_Start.
  pausedDevice,

  ///Playback of the stream has been stalled due to a lack of sample data.
  ///Playback will automatically resume once there is sufficient data to do so.
  stalled,

  /// the end of an audio has been reached
  completed,

  unknown,
}

class BassPlayer {
  late final ffi.DynamicLibrary _dyLib;
  late final Bass _bass;
  int? _fstream;
  late Timer _positionUpdater;
  late final StreamController<double> _positionStreamController;
  late final StreamController<PlayerState> _playerStateStreamController;

  /// store the plugin handle and we can free it when exit
  List<int> pluginHandles = [];

  /// audio's length in seconds
  double get length => _fstream == null
      ? double.maxFinite
      : _bass.BASS_ChannelBytes2Seconds(
          _fstream!, _bass.BASS_ChannelGetLength(_fstream!, BASS_POS_BYTE));

  /// current position in seconds
  double get position => _fstream == null
      ? 0.0
      : _bass.BASS_ChannelBytes2Seconds(
          _fstream!, _bass.BASS_ChannelGetPosition(_fstream!, BASS_POS_BYTE));

  PlayerState get playerState {
    if (_fstream == null) {
      return PlayerState.unknown;
    }

    switch (_bass.BASS_ChannelIsActive(_fstream!)) {
      case BASS_ACTIVE_STOPPED:
        return PlayerState.stopped;
      case BASS_ACTIVE_PLAYING:
        return PlayerState.playing;
      case BASS_ACTIVE_PAUSED:
        return PlayerState.paused;
      case BASS_ACTIVE_PAUSED_DEVICE:
        return PlayerState.pausedDevice;
      case BASS_ACTIVE_STALLED:
        return PlayerState.stalled;
      default:
        return PlayerState.unknown;
    }
  }

  double get volumeDsp {
    if (_fstream == null) return 0;

    final volDsp = malloc.allocate<ffi.Float>(ffi.sizeOf<ffi.Float>());
    _bass.BASS_ChannelGetAttribute(_fstream!, BASS_ATTRIB_VOLDSP, volDsp);
    return volDsp.value;
  }

  /// update every 33ms
  Stream<double> get positionStream => _positionStreamController.stream;

  Stream<PlayerState> get playerStateStream =>
      _playerStateStreamController.stream;

  Timer _getPositionUpdater() {
    return Timer.periodic(
      const Duration(milliseconds: 33),
      (timer) {
        _positionStreamController.add(position);

        /// check if the channel has completed
        if (playerState == PlayerState.stopped) {
          _playerStateStreamController.add(PlayerState.completed);
        }
      },
    );
  }

  /// load bass.dll from the exe's path
  /// ensure that there's bass.dll at path of .exe
  /// leave the device's output freq as it is
  BassPlayer() {
    final dyLibPath =
        path.join(path.dirname(Platform.resolvedExecutable), 'bass.dll');
    _dyLib = ffi.DynamicLibrary.open(dyLibPath);
    _bass = Bass(_dyLib);

    if (_bass.BASS_Init(1, 48000, 0, ffi.nullptr, ffi.nullptr) == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_DEVICE:
          throw const FormatException("device is invalid.");
        case BASS_ERROR_NOTAVAIL:
          throw const FormatException(
              "The BASS_DEVICE_REINIT flag cannot be used when device is -1. Use the real device number instead.");
        case BASS_ERROR_ALREADY:
          throw const FormatException(
              "The device has already been initialized. The BASS_DEVICE_REINIT flag can be used to request reinitialization.");
        case BASS_ERROR_ILLPARAM:
          throw const FormatException("win is not a valid window handle.");
        case BASS_ERROR_DRIVER:
          throw const FormatException("There is no available device driver.");
        case BASS_ERROR_BUSY:
          throw const FormatException(
              "Something else has exclusive use of the device.");
        case BASS_ERROR_FORMAT:
          throw const FormatException(
              "The specified format is not supported by the device. Try changing the freq parameter.");
        case BASS_ERROR_MEM:
          throw const FormatException("There is insufficient memory.");
        case BASS_ERROR_UNKNOWN:
          throw const FormatException("Some other mystery problem!");
      }
    }

    // load bassflac add-on to avoid using os codec
    final flacPluginPath =
        "bassflac.dll".toNativeUtf16() as ffi.Pointer<ffi.Char>;
    final hplugin = _bass.BASS_PluginLoad(flacPluginPath, BASS_UNICODE);

    if (hplugin == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_FILEOPEN:
          throw const FormatException("The file could not be opened.");
        case BASS_ERROR_FILEFORM:
          throw const FormatException("The file is not a plugin.");
        case BASS_ERROR_VERSION:
          throw const FormatException(
              "The plugin requires a different BASS version.");
        case BASS_ERROR_ALREADY:
          throw const FormatException("The plugin is already loaded.");
      }
    } else {
      pluginHandles.add(hplugin);
    }

    _positionStreamController = StreamController.broadcast(
      onCancel: () {
        _positionUpdater.cancel();
      },
    );

    _playerStateStreamController = StreamController.broadcast(
      onListen: () {
        _playerStateStreamController.add(PlayerState.stopped);
      },
    );
  }

  /// if setSource has been called once,
  /// it will pause current channel and free current stream.
  void setSource(String path) {
    if (_fstream != null) {
      _positionUpdater.cancel();
      freeFStream();
    }
    final pathPointer = path.toNativeUtf16() as ffi.Pointer<ffi.Void>;

    /// 设置 flags 为 BASS_UNICODE 才可以找到文件。
    _fstream = _bass.BASS_StreamCreateFile(
      FALSE,
      pathPointer,
      0,
      0,
      BASS_UNICODE | BASS_SAMPLE_FLOAT | BASS_ASYNCFILE,
    );

    if (_fstream == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_INIT:
          throw const FormatException(
              "BASS_Init has not been successfully called.");
        case BASS_ERROR_NOTAVAIL:
          throw const FormatException(
              "The BASS_STREAM_AUTOFREE flag cannot be combined with the BASS_STREAM_DECODE flag.");
        case BASS_ERROR_ILLPARAM:
          throw const FormatException(
              "The length must be specified when streaming from memory.");
        case BASS_ERROR_FILEOPEN:
          throw const FormatException("The file could not be opened.");
        case BASS_ERROR_FILEFORM:
          throw const FormatException(
              "The file's format is not recognised/supported.");
        case BASS_ERROR_NOTAUDIO:
          throw const FormatException(
              "The file does not contain audio, or it also contains video and videos are disabled.");
        case BASS_ERROR_CODEC:
          throw const FormatException(
              "The file uses a codec that is not available/supported. This can apply to WAV and AIFF files.");
        case BASS_ERROR_FORMAT:
          throw const FormatException("The sample format is not supported.");
        case BASS_ERROR_SPEAKER:
          throw const FormatException(
              "The specified SPEAKER flags are invalid.");
        case BASS_ERROR_MEM:
          throw const FormatException("There is insufficient memory.");
        case BASS_ERROR_NO3D:
          throw const FormatException("Could not initialize 3D support.");
        case BASS_ERROR_UNKNOWN:
          throw const FormatException("Some other mystery problem!");
      }
    }
  }

  /// [BASS_ATTRIB_VOLDSP] attribute does have direct effect on decoding/recording channels.
  void setVolumeDsp(double volume) {
    if (_fstream == null) return;

    if (_bass.BASS_ChannelSetAttribute(
          _fstream!,
          BASS_ATTRIB_VOLDSP,
          volume,
        ) ==
        0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_HANDLE:
          throw const FormatException("handle is not a valid channel.");
        case BASS_ERROR_ILLTYPE:
          throw const FormatException("attrib is not valid.");
        case BASS_ERROR_ILLPARAM:
          throw const FormatException("value is not valid.");
      }
    }
  }

  /// start/resume channel
  ///
  /// do nothing if [setSource] hasn't been called
  void start() {
    if (_fstream == null) return;

    if (_bass.BASS_ChannelStart(_fstream!) == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_HANDLE:
          throw const FormatException("handle is not a valid channel.");
        case BASS_ERROR_DECODE:
          throw const FormatException(
              "handle is a decoding channel, so cannot be played.");
        case BASS_ERROR_START:
          throw const FormatException(
              "The output is paused/stopped, use BASS_Start to start it.");
      }
    }

    _playerStateStreamController.add(PlayerState.playing);
    _positionUpdater = _getPositionUpdater();
  }

  /// pause channel, call [start] to resume channel
  ///
  /// do nothing if [setSource] hasn't been called
  void pause() {
    if (_fstream == null) return;

    if (_bass.BASS_ChannelPause(_fstream!) == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_HANDLE:
          throw const FormatException("handle is not a valid channel.");
        case BASS_ERROR_DECODE:
          throw const FormatException(
              "handle is a decoding channel, so cannot be played or paused.");
        case BASS_ERROR_NOPLAY:
          throw const FormatException("The channel is not playing.");
      }
    }

    _playerStateStreamController.add(PlayerState.paused);
    _positionUpdater.cancel();
  }

  /// pause channel. can't resume by calling [start]
  ///
  /// do nothing if [setSource] hasn't been called
  void stop() {
    if (_fstream == null) return;

    if (_bass.BASS_ChannelStop(_fstream!) == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_HANDLE:
          throw const FormatException("handle is not a valid channel.");
      }
    }

    _playerStateStreamController.add(PlayerState.stopped);
    _positionUpdater.cancel();
  }

  /// set channel's position to given [position]
  /// don't check if the position is valid.
  ///
  /// do nothing if [setSource] hasn't been called
  void seek(double position) {
    if (_fstream == null) return;

    if (_bass.BASS_ChannelSetPosition(
          _fstream!,
          _bass.BASS_ChannelSeconds2Bytes(_fstream!, position),
          BASS_POS_BYTE,
        ) ==
        0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_HANDLE:
          throw const FormatException("handle is not a valid channel.");
        case BASS_ERROR_NOTFILE:
          throw const FormatException("The stream is not a file stream.");
        case BASS_ERROR_POSITION:
          throw const FormatException(
              "The requested position is invalid, eg. it is beyond the end or the download has not yet reached it.");
        case BASS_ERROR_NOTAVAIL:
          throw const FormatException(
              "The requested mode is not available. Invalid flags are ignored and do not result in this error.");
        case BASS_ERROR_UNKNOWN:
          throw const FormatException("Some other mystery problem!");
      }
    }
  }

  /// It is not necessary to individually free the samples/streams/musics
  /// as these are all automatically freed after [setSource] or [free] is called.
  ///
  /// do nothing if [setSource] hasn't been called
  void freeFStream() {
    if (_fstream == null) return;

    if (_bass.BASS_StreamFree(_fstream!) == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_HANDLE:
          throw const FormatException("handle is not valid.");
        case BASS_ERROR_NOTAVAIL:
          throw const FormatException(
              "Device streams (STREAMPROC_DEVICE) cannot be freed.");
      }
    }
  }

  /// Frees all resources used by the output device,
  /// including all its samples, streams and MOD musics.
  ///
  /// Also free the bass.dll.
  void free() {
    for (var hplugin in pluginHandles) {
      _bass.BASS_PluginFree(hplugin);
    }
    if (_bass.BASS_Free() == 0) {
      switch (_bass.BASS_ErrorGetCode()) {
        case BASS_ERROR_INIT:
          throw const FormatException(
              "BASS_Init has not been successfully called.");
        case BASS_ERROR_BUSY:
          throw const FormatException(
              "The device is currently being reinitialized.");
      }
    }

    _dyLib.close();
    _playerStateStreamController.close();
    _positionStreamController.close();
    _positionUpdater.cancel();
  }
}
