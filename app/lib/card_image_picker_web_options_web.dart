import 'package:file_picker_web/file_picker_web.dart';

/// The web options that `CardImages.pick` passes to the file picker.
///
/// By default, the web picker reads every chosen file into memory before it
/// returns, so a player who chooses a whole folder of scans would hold all
/// of them at once. This leaves the files unread, so that `CardImages.load`
/// only reads the ones it uses.
///
/// `withData` is deprecated, and is due to be removed in file_picker v14,
/// once files are no longer read up front. Remove this file, and the
/// `file_picker_web` dependency, then.
const cardImagePickerWebOptions = FilePickerWebOptions(
  // ignore: deprecated_member_use
  withData: false,
);
