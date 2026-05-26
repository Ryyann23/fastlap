import 'local_key_value_store.dart';

class MemoryLocalKeyValueStore implements LocalKeyValueStore {
  MemoryLocalKeyValueStore([this._value]);

  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async {
    _value = value;
  }

  @override
  Future<void> clear() async {
    _value = null;
  }
}
