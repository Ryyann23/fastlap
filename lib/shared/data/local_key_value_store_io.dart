import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_key_value_store.dart';

LocalKeyValueStore createStore() => FileLocalKeyValueStore();

class FileLocalKeyValueStore implements LocalKeyValueStore {
  File? _file;

  Future<File> _resolveFile() async {
    final cached = _file;
    if (cached != null) return cached;

    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File(
      '${directory.path}${Platform.pathSeparator}fastlap_local_store.json',
    );
    _file = file;
    return file;
  }

  @override
  Future<String?> read() async {
    final file = await _resolveFile();
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(String value) async {
    final file = await _resolveFile();
    await file.writeAsString(value, flush: true);
  }

  @override
  Future<void> clear() async {
    final file = await _resolveFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
