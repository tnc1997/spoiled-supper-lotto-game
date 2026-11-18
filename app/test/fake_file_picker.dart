import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A file picker that, instead of asking the player, answers each call to
/// `FilePicker.pickFiles` with the next of its [picks].
///
/// Install one with [FakeFilePicker.install], which puts the real one back
/// after the test.
class FakeFilePicker extends Fake
    with MockPlatformInterfaceMixin
    implements FilePickerPlatform {
  /// The answers to the calls to `FilePicker.pickFiles`, in turn, each
  /// returning the files the player chose, none if they cancelled, or an
  /// error if picking failed.
  final List<Future<List<PlatformFile>> Function()> picks;

  /// The `type` of each call to `FilePicker.pickFiles`, in turn.
  final types = <FileType>[];

  /// The `allowedExtensions` of each call to `FilePicker.pickFiles`, in
  /// turn.
  final allowedExtensions = <List<String>?>[];

  FakeFilePicker._(this.picks);

  /// Uses a fake file picker answering with [picks] until the end of the
  /// test, and returns it.
  static FakeFilePicker install(
    List<Future<List<PlatformFile>> Function()> picks,
  ) {
    final original = FilePickerPlatform.instance;
    addTearDown(() => FilePickerPlatform.instance = original);

    return FilePickerPlatform.instance = FakeFilePicker._(picks);
  }

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) {
    types.add(type);
    this.allowedExtensions.add(allowedExtensions);

    return picks.removeAt(0)();
  }
}

/// A file the player chose with a [FakeFilePicker], held in memory.
///
/// Extends, rather than fakes, [PlatformFile], since it's a `base` class,
/// which can't be implemented outside of its library.
final class FakePlatformFile extends PlatformFile {
  final Uint8List _bytes;

  @override
  final String name;

  /// A file called [name], holding [bytes].
  FakePlatformFile(this.name, this._bytes);

  @override
  Uri get uri => Uri.file(name);

  @override
  XFile get xFile => XFile.fromData(_bytes, name: name, path: name);

  @override
  int? lengthSync() => _bytes.length;

  @override
  Future<int?> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}
