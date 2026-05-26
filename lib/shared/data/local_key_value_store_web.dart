// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'local_key_value_store.dart';

LocalKeyValueStore createStore() => WebLocalKeyValueStore();

class WebLocalKeyValueStore implements LocalKeyValueStore {
  static const _key = 'fastlap_local_store';

  @override
  Future<String?> read() async {
    return html.window.localStorage[_key];
  }

  @override
  Future<void> write(String value) async {
    html.window.localStorage[_key] = value;
  }

  @override
  Future<void> clear() async {
    html.window.localStorage.remove(_key);
  }
}
